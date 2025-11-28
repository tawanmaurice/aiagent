import os
import json
import time
import hashlib
from typing import List, Dict, Any

import boto3
import requests
from openai import OpenAI

# ---- Environment variables (set via Terraform) ----
DDB_TABLE_NAME = os.environ["DDB_TABLE_NAME"]
OPENAI_API_KEY = os.environ["OPENAI_API_KEY"]
GOOGLE_API_KEY = os.environ["GOOGLE_API_KEY"]
GOOGLE_CX_ID = os.environ["GOOGLE_CX_ID"]

# ---- AWS + OpenAI clients ----
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(DDB_TABLE_NAME)

openai_client = OpenAI(api_key=OPENAI_API_KEY)

# ---- Search queries tuned to you (you can edit/expand these) ----
SEARCH_QUERIES: List[str] = [
    '"student leadership conference" "call for proposals" site:.edu',
    '"student leadership summit" "student life" site:.edu',
    '"community college" "student leadership" "conference" site:.edu',
    '"emerging leaders conference" "student activities" site:.edu',
    '"first year experience" "student leadership" "conference" site:.edu',
]


def handler(event, context):
    """
    AWS Lambda entry point.
    Runs through the SEARCH_QUERIES, calls Google Custom Search,
    scrapes pages, extracts data with GPT, and writes to DynamoDB.
    """
    print("Starting speaking-agent run...")

    total_urls_processed = 0
    leads_saved = 0

    for query in SEARCH_QUERIES:
        urls = google_search(query, num_results=5)  # adjust per query if you want
        print(f"Query: {query} -> {len(urls)} URLs")

        for url in urls:
            total_urls_processed += 1
            print(f"Processing URL: {url}")

            text = fetch_page_text(url)
            if not text:
                print(f"Skipping URL (no text): {url}")
                continue

            record = extract_with_llm(url, text)
            if not record:
                print(f"LLM returned nothing for: {url}")
                continue

            if not record.get("is_relevant"):
                print(f"Not relevant: {record.get('reason', '')}")
                continue

            # Basic validation: must at least have event_name and org or contact
            if not record.get("event_name") and not record.get("organization_name"):
                print("Skipping: missing both event_name and organization_name")
                continue

            save_to_dynamodb(url, record)
            leads_saved += 1

            # Gentle throttle to avoid hammering APIs
            time.sleep(0.5)

    print(f"Run complete. URLs processed: {total_urls_processed}, leads saved: {leads_saved}")

    return {
        "statusCode": 200,
        "body": json.dumps({
            "urls_processed": total_urls_processed,
            "leads_saved": leads_saved
        })
    }


# -------------------------
# Google Programmable Search
# -------------------------

def google_search(query: str, num_results: int = 5) -> List[str]:
    """
    Call Google Programmable Search API and return a list of result URLs.
    """
    url = "https://www.googleapis.com/customsearch/v1"
    params = {
        "key": GOOGLE_API_KEY,
        "cx": GOOGLE_CX_ID,
        "q": query,
        "num": min(num_results, 10)  # Google max per request is 10
    }

    try:
        resp = requests.get(url, params=params, timeout=15)
        resp.raise_for_status()
        data = resp.json()
    except Exception as e:
        print(f"Error calling Google Custom Search: {e}")
        return []

    items = data.get("items", []) or []
    links = [item.get("link") for item in items if "link" in item]
    return links


# -------------------------
# Page fetching
# -------------------------

def fetch_page_text(url: str, max_chars: int = 15000) -> str:
    """
    Fetch a webpage and return plain text.
    You can improve this later with better HTML-to-text extraction.
    """
    headers = {
        "User-Agent": "Mozilla/5.0 (compatible; SpeakingAgentBot/1.0; +https://example.com)"
    }

    try:
        resp = requests.get(url, headers=headers, timeout=20)
        resp.raise_for_status()
        html = resp.text
    except Exception as e:
        print(f"Error fetching {url}: {e}")
        return ""

    # Very simple HTML strip (for Lambda), you can replace with BeautifulSoup if bundled
    text = strip_html_naive(html)

    # Truncate to avoid huge prompts
    if len(text) > max_chars:
        text = text[:max_chars]

    return text


def strip_html_naive(html: str) -> str:
    """
    Naive HTML cleaner using simple replacements.
    For better results, bundle BeautifulSoup in your deployment package.
    """
    import re

    text = re.sub(r"<script[^>]*>.*?</script>", " ", html, flags=re.DOTALL | re.IGNORECASE)
    text = re.sub(r"<style[^>]*>.*?</style>", " ", text, flags=re.DOTALL | re.IGNORECASE)
    text = re.sub(r"<[^>]+>", " ", text)
    text = re.sub(r"\s+", " ", text)
    return text.strip()


# -------------------------
# LLM extraction
# -------------------------

def extract_with_llm(url: str, text: str) -> Dict[str, Any]:
    """
    Use GPT-4.1 mini (or similar) to extract:
        - contact_name
        - contact_email
        - event_name
        - event_year
        - organization_name
    And a flag is_relevant.
    """
    system_prompt = (
        "You are a research assistant that finds student leadership speaking opportunities.\n"
        "Given a webpage, extract information about leadership-related events.\n"
        "Return ONLY a JSON object with this exact schema:\n\n"
        "{\n"
        '  \"is_relevant\": true or false,\n'
        '  \"reason\": \"short reason why it is or is not relevant\",\n'
        '  \"contact_name\": \"full name or empty string\",\n'
        '  \"contact_email\": \"email or empty string\",\n'
        '  \"event_name\": \"name of the event or empty string\",\n'
        '  \"event_year\": \"4-digit year like 2024 or empty string\",\n'
        '  \"organization_name\": \"school or organization name or empty string\"\n'
        "}\n\n"
        "Relevance rules:\n"
        "- is_relevant = true only if the page clearly describes a leadership-related conference, summit, "
        "workshop, retreat, or program for students (college or community college), student leaders, "
        "student government, first-year experience, or student affairs.\n"
        "- If there are multiple people, choose the contact most likely responsible for booking speakers "
        "(e.g., Director of Student Life, Student Leadership Coordinator, Student Activities, etc.).\n"
        "- If you can't find a field, use an empty string.\n"
    )

    user_prompt = (
        f"URL: {url}\n\n"
        "Webpage text:\n"
        f"{text}\n\n"
        "Now output the JSON object."
    )

    try:
        response = openai_client.chat.completions.create(
            model="gpt-4.1-mini",
            response_format={"type": "json_object"},
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt},
            ],
            temperature=0.1,
        )
        content = response.choices[0].message.content
        data = json.loads(content)
        return data
    except Exception as e:
        print(f"Error calling OpenAI: {e}")
        return {}


# -------------------------
# DynamoDB save
# -------------------------

def save_to_dynamodb(source_url: str, record: Dict[str, Any]) -> None:
    """
    Save the extracted record into DynamoDB.
    Uses a hash of URL + event_name as the primary key to avoid duplicates.
    """

    event_name = (record.get("event_name") or "").strip()
    org_name = (record.get("organization_name") or "").strip()
    contact_name = (record.get("contact_name") or "").strip()
    contact_email = (record.get("contact_email") or "").strip()
    event_year = (record.get("event_year") or "").strip()

    # Make a reasonably stable ID from URL and event name
    id_source = f"{source_url}|{event_name}|{org_name}"
    item_id = hashlib.sha256(id_source.encode("utf-8")).hexdigest()

    item = {
        "id": item_id,
        "source_url": source_url,
        "event_name": event_name,
        "event_year": event_year,
        "organization_name": org_name,
        "contact_name": contact_name,
        "contact_email": contact_email,
        # You can add more fields later if needed
        "created_at": int(time.time())
    }

    try:
        table.put_item(Item=item)
        print(f"Saved lead: {event_name} ({org_name})")
    except Exception as e:
        print(f"Error saving to DynamoDB: {e}")
