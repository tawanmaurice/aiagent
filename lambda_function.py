import os
import json
import logging
import uuid
import re
from typing import Any, Dict, List, Optional

import boto3
import requests

# ---------------------------------------------------------
# Logging setup
# ---------------------------------------------------------
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# ---------------------------------------------------------
# Environment variables
# ---------------------------------------------------------
OPENAI_API_KEY = os.environ.get("OPENAI_API_KEY")
OPENAI_MODEL = os.environ.get("OPENAI_MODEL", "gpt-4.1-mini")

GOOGLE_API_KEY = os.environ.get("GOOGLE_API_KEY")
GOOGLE_CX = os.environ.get("GOOGLE_CX")

DDB_TABLE_NAME = os.environ.get("DDB_TABLE_NAME")  # optional, for saving leads

if not OPENAI_API_KEY:
    logger.warning("OPENAI_API_KEY is not set in environment variables.")

if not GOOGLE_API_KEY or not GOOGLE_CX:
    logger.warning("GOOGLE_API_KEY or GOOGLE_CX is not set. Google search will not work.")

# DynamoDB client (lazy-init)
_dynamodb = None
_ddb_table = None


def get_ddb_table():
    """
    Lazy-load DynamoDB table object if DDB_TABLE_NAME is configured.
    """
    global _dynamodb, _ddb_table

    if not DDB_TABLE_NAME:
        return None

    if _dynamodb is None:
        _dynamodb = boto3.resource("dynamodb")
        _ddb_table = _dynamodb.Table(DDB_TABLE_NAME)

    return _ddb_table


# ---------------------------------------------------------
# OpenAI helper (using requests, NOT the openai SDK)
# ---------------------------------------------------------
def call_openai(prompt: str) -> str:
    """
    Call the OpenAI Responses API with a simple text prompt
    and return the model's text output (first message).
    """
    if not OPENAI_API_KEY:
        raise RuntimeError("OPENAI_API_KEY is not configured.")

    url = "https://api.openai.com/v1/responses"
    headers = {
        "Authorization": f"Bearer {OPENAI_API_KEY}",
        "Content-Type": "application/json",
    }
    payload = {
        "model": OPENAI_MODEL,
        "input": prompt,
    }

    logger.info("Sending request to OpenAI model=%s", OPENAI_MODEL)
    resp = requests.post(url, headers=headers, json=payload, timeout=45)

    # Handle rate limit nicely
    if resp.status_code == 429:
        logger.error("OpenAI rate limit hit: %s", resp.text)
        raise RuntimeError("OpenAI rate limit / quota exceeded (429).")

    resp.raise_for_status()
    data = resp.json()

    # Responses API returns: output[0].content[0].text
    try:
        text = data["output"][0]["content"][0]["text"]
    except (KeyError, IndexError) as e:
        logger.error("Unexpected OpenAI response format: %s", data)
        raise RuntimeError(f"Unexpected OpenAI response format: {e}")

    logger.info("Received response from OpenAI (length=%d)", len(text))
    return text


# ---------------------------------------------------------
# Google search helper (real web search)
# ---------------------------------------------------------
def google_search_conferences(topic: str, num_results: int = 10) -> List[Dict[str, Any]]:
    """
    Use Google Custom Search JSON API to find real pages about
    student leadership conferences.

    Returns a list of dicts with: title, link, snippet.
    """
    if not GOOGLE_API_KEY or not GOOGLE_CX:
        raise RuntimeError("GOOGLE_API_KEY or GOOGLE_CX not configured.")

    # Bias the query toward .edu domains and conferences
    query = f"{topic} site:.edu student leadership conference"

    url = "https://www.googleapis.com/customsearch/v1"
    params = {
        "key": GOOGLE_API_KEY,
        "cx": GOOGLE_CX,
        "q": query,
        "num": min(num_results, 10),
    }

    logger.info("Calling Google CSE with query=%s", query)
    resp = requests.get(url, params=params, timeout=30)
    resp.raise_for_status()
    data = resp.json()

    items = data.get("items", []) or []
    results = []

    for item in items:
        results.append(
            {
                "title": item.get("title"),
                "link": item.get("link"),
                "snippet": item.get("snippet"),
            }
        )

    logger.info("Google search returned %d results", len(results))
    return results


# ---------------------------------------------------------
# Basic web-page fetch + email scraping helpers
# ---------------------------------------------------------

EMAIL_REGEX = re.compile(
    r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}", re.IGNORECASE
)


def fetch_page(url: str, max_chars: int = 50000) -> Optional[str]:
    """
    Fetch a single web page and return a truncated HTML/text string.

    We keep it very small and simple so Lambda doesn't work too hard.
    This is NOT a full crawler—just a first-page fetch for email scraping.
    """
    try:
        logger.info("Fetching page for email scraping: %s", url)
        resp = requests.get(
            url,
            timeout=15,
            headers={"User-Agent": "Mozilla/5.0 (speaking-agent)"},
        )
    except Exception as e:
        logger.warning("Error fetching %s: %s", url, e)
        return None

    content_type = resp.headers.get("Content-Type", "")
    if "text" not in content_type and "html" not in content_type:
        logger.info("Skipping non-HTML content for %s (Content-Type=%s)", url, content_type)
        return None

    text = resp.text
    if len(text) > max_chars:
        text = text[:max_chars]
    return text


def looks_like_real_email(email: str) -> bool:
    """
    Very simple email validator:
    - matches general pattern (already ensured by regex)
    - excludes obvious junk like image/query strings.
    """
    email = email.strip()
    if len(email) > 254:
        return False

    # Avoid stuff embedded in URLs like .png?foo=bar
    if any(ext in email.lower() for ext in [".png", ".jpg", ".gif", ".css", ".js"]):
        return False

    # Avoid 'example.com' type placeholders
    if "example.com" in email.lower():
        return False

    # Basic structural checks
    if "@" not in email:
        return False
    local, domain = email.rsplit("@", 1)
    if not local or not domain or "." not in domain:
        return False

    return True


def scrape_emails_from_url(url: str) -> List[str]:
    """
    Fetch a URL and return a de-duplicated, validated list of emails
    found on the page.
    """
    html = fetch_page(url)
    if not html:
        return []

    raw_emails = EMAIL_REGEX.findall(html)
    unique: List[str] = []
    seen = set()

    for e in raw_emails:
        e_norm = e.strip()
        if e_norm.lower() in seen:
            continue
        if looks_like_real_email(e_norm):
            seen.add(e_norm.lower())
            unique.append(e_norm)

    logger.info("Found %d unique emails on %s", len(unique), url)
    return unique


# ---------------------------------------------------------
# Use OpenAI to transform search results into clean JSON
# ---------------------------------------------------------
def structure_conferences_from_search(
    topic: str, search_results: List[Dict[str, Any]]
) -> Dict[str, Any]:
    """
    Give the model real Google search results (title + link + snippet),
    and ask it to build a clean, deduped JSON list of conferences.

    NOTE: At this stage we are NOT hallucinating emails.
    We only include fields that clearly come from the search results.
    """
    if not search_results:
        return {"conferences": [], "topic": topic}

    search_json = json.dumps(search_results, ensure_ascii=False, indent=2)

    prompt = f"""
You are an assistant that helps a professional speaker find REAL student leadership conferences.

You are given ACTUAL Google search results in JSON form. Each result has:
- "title"
- "link"
- "snippet"

The topic is: "{topic}".

Search results:

{search_json}

From ONLY this data, build a clean JSON object with this structure:

{{
  "conferences": [
    {{
      "id": "short-stable-id-based-on-name-and-school",
      "name": "Conference name",
      "school": "School or host (from title/snippet/link)",
      "type": "university" | "community college" | "other",
      "location": "City, State (if clearly mentioned, otherwise empty string)",
      "website": "the direct link from the search result",
      "conference_dates": "dates if clearly mentioned, otherwise empty string",
      "address": "address if clearly mentioned, otherwise empty string",
      "notes": "One sentence on why this is relevant for student leaders and what kind of event it is."
    }}
  ]
}}

Rules:
- ONLY use conferences that clearly look like events for student leaders, student government, student affairs, etc.
- If you are not sure something is a conference, leave it out.
- DO NOT invent conferences, schools, or URLs that are not in the search results.
- If location, dates, or address are not clearly present, leave the field as an empty string.
- Do not add any text outside the JSON.
"""

    raw = call_openai(prompt)

    try:
        data = json.loads(raw)
    except json.JSONDecodeError:
        logger.warning("Model output was not valid JSON. Wrapping in fallback.")
        data = {
            "conferences": [],
            "raw_text": raw,
        }

    # Attach topic for traceability
    if isinstance(data, dict):
        data.setdefault("topic", topic)

    return data


# ---------------------------------------------------------
# Enrich conferences with scraped emails
# ---------------------------------------------------------
def enrich_conferences_with_emails(conference_data: Dict[str, Any]) -> Dict[str, Any]:
    """
    For each conference, fetch the website and scrape for email addresses.
    Adds:
      - primary_email: str
      - emails: List[str]
    Also filters duplicates by website within this run.
    """
    conferences = conference_data.get("conferences", []) or []
    deduped: List[Dict[str, Any]] = []
    seen_websites = set()

    for conf in conferences:
        website = (conf.get("website") or "").strip()
        if not website:
            continue

        # Per-run duplicate filtering: skip if we've already seen this website
        if website.lower() in seen_websites:
            logger.info("Skipping duplicate website: %s", website)
            continue
        seen_websites.add(website.lower())

        emails = scrape_emails_from_url(website)
        conf["emails"] = emails
        conf["primary_email"] = emails[0] if emails else ""

        deduped.append(conf)

    conference_data["conferences"] = deduped
    return conference_data


# ---------------------------------------------------------
# Save conferences to DynamoDB
# ---------------------------------------------------------
def save_conferences_to_dynamodb(conference_data: Dict[str, Any]) -> int:
    """
    Save each conference into DynamoDB table specified by DDB_TABLE_NAME.
    Returns number of items saved.

    We treat 'id' as the primary key; if it's missing, we generate one.
    """
    table = get_ddb_table()
    if table is None:
        logger.info("DDB_TABLE_NAME not set; skipping DynamoDB save.")
        return 0

    conferences = conference_data.get("conferences", []) or []
    topic = conference_data.get("topic", "")

    saved = 0
    for conf in conferences:
        conf_id = conf.get("id") or uuid.uuid4().hex

        item = {
            "id": conf_id,
            "topic": topic,
            "name": conf.get("name", ""),
            "school": conf.get("school", ""),
            "type": conf.get("type", ""),
            "location": conf.get("location", ""),
            "website": conf.get("website", ""),
            "conference_dates": conf.get("conference_dates", ""),
            "address": conf.get("address", ""),
            "notes": conf.get("notes", ""),
            "primary_email": conf.get("primary_email", ""),
            "emails": conf.get("emails", []),
        }

        # Best-effort write; if an item with this id already exists,
        # we'll just overwrite it. You could add a ConditionExpression
        # if you want strict "no overwrite" behavior.
        table.put_item(Item=item)
        saved += 1

    logger.info("Saved %d conferences to DynamoDB", saved)
    return saved


# ---------------------------------------------------------
# High-level research function (real search + scraping)
# ---------------------------------------------------------
def run_research_agent(topic: str) -> Dict[str, Any]:
    """
    Full pipeline:
    - Call Google search (real web)
    - Use OpenAI to structure results into conferences
    - Crawl each conference website's first page to find contact emails
    - Optionally save to DynamoDB
    """
    # 1) Real Google search
    search_results = google_search_conferences(topic, num_results=10)

    # 2) Model cleans & structures conferences based on real results
    structured = structure_conferences_from_search(topic, search_results)

    # 3) Crawl websites to find emails and add them to each conference
    structured = enrich_conferences_with_emails(structured)

    # 4) Save to DynamoDB (if table configured)
    saved_count = save_conferences_to_dynamodb(structured)
    structured["saved_count"] = saved_count
    structured["search_result_count"] = len(search_results)

    return structured


# ---------------------------------------------------------
# Lambda handler
# ---------------------------------------------------------
def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Main Lambda handler.

    Example events:
    1) Simple health check / ping:
       { "action": "ping" }

    2) Run the research agent:
       {
         "action": "research",
         "topic": "student leadership conferences at community colleges in the Midwest"
       }
    """
    logger.info("Received event: %s", json.dumps(event))

    action = event.get("action", "ping")

    try:
        if action == "ping":
            # Simple connectivity + OpenAI smoke test
            prompt = "Reply with a short sentence confirming the Lambda function is working."
            reply = call_openai(prompt)
            body = {
                "message": "Lambda is alive.",
                "openai_reply": reply,
            }
            status_code = 200

        elif action == "research":
            topic = event.get(
                "topic",
                "student leadership conferences at universities and community colleges in the United States",
            )

            result = run_research_agent(topic)
            body = {
                "message": "Research completed.",
                "topic": topic,
                "result": result,
            }
            status_code = 200

        else:
            body = {
                "message": f"Unknown action '{action}'. Use 'ping' or 'research'.",
            }
            status_code = 400

    except Exception as e:
        logger.exception("Error while handling request.")
        body = {
            "error": str(e),
            "action": action,
        }
        status_code = 500

    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
        },
        "body": json.dumps(body),
    }
