import os
import json
import uuid
import re
import logging
from datetime import datetime, timezone
from typing import List, Optional

import boto3
import urllib.request
import urllib.error
import urllib.parse

logger = logging.getLogger()
logger.setLevel(logging.INFO)

DDB_TABLE_NAME = os.getenv("DDB_TABLE_NAME")
GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")
GOOGLE_CX = os.getenv("GOOGLE_CX")

# e.g. "sga-agent", "orientation-agent", etc.
AGENT_SOURCE = os.getenv("AGENT_SOURCE", "generic-agent")

# Multiple queries separated by ||
DEFAULT_QUERY = "Student Government Association leadership retreat site:.edu"
SEARCH_QUERIES = os.getenv("SEARCH_QUERIES", DEFAULT_QUERY).split("||")

MAX_RESULTS = int(os.getenv("MAX_RESULTS", "10"))

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(DDB_TABLE_NAME)


def http_get(url: str, timeout: int = 15) -> str:
    """Simple HTTP GET using standard library."""
    logger.info(f"[http_get] GET {url}")
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            return resp.read().decode("utf-8", errors="ignore")
    except Exception as e:
        logger.warning(f"[http_get] Error fetching {url}: {e}")
        return ""


def google_search(query: str) -> List[dict]:
    """Call Google Custom Search API and return items list."""
    if not GOOGLE_API_KEY or not GOOGLE_CX:
        logger.error("[google_search] GOOGLE_API_KEY or GOOGLE_CX not set.")
        return []

    params = urllib.parse.urlencode(
        {
            "key": GOOGLE_API_KEY,
            "cx": GOOGLE_CX,
            "q": query,
        }
    )
    url = f"https://www.googleapis.com/customsearch/v1?{params}"
    logger.info(f"[google_search] Querying Google CSE: {query}")

    try:
        body = http_get(url, timeout=20)
        data = json.loads(body) if body else {}
    except Exception as e:
        logger.warning(f"[google_search] Error calling Google CSE: {e}")
        return []

    items = data.get("items", []) or []
    logger.info(f"[google_search] Got {len(items)} results for query: {query}")
    return items


def fetch_emails_from_url(url: str) -> List[str]:
    """Fetch a page and extract email addresses."""
    html = http_get(url, timeout=20)
    if not html:
        return []

    email_pattern = r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}"
    emails = re.findall(email_pattern, html)
    unique_emails = sorted(set(emails))
    logger.info(f"[fetch_emails_from_url] Found {len(unique_emails)} emails on {url}")
    return unique_emails


def choose_primary_email(url: str, emails: List[str]) -> Optional[str]:
    if not emails:
        return None

    # Grab domain from URL
    domain_match = re.search(r"https?://([^/]+)/?", url)
    page_domain = domain_match.group(1).lower() if domain_match else ""

    # 1) .edu + contains site domain
    for e in emails:
        lower = e.lower()
        if lower.endswith(".edu") and page_domain and page_domain.split(":")[0] in lower:
            return e

    # 2) any .edu
    for e in emails:
        if e.lower().endswith(".edu"):
            return e

    # 3) fallback
    return emails[0]


def save_item_to_dynamodb(item: dict):
    logger.info(f"[{AGENT_SOURCE}] Saving item to DynamoDB: {item}")
    table.put_item(Item=item)


def run_agent() -> int:
    saved_count = 0
    now_iso = datetime.now(timezone.utc).isoformat()

    for raw_query in SEARCH_QUERIES:
        query = raw_query.strip()
        if not query:
            continue

        items = google_search(query)
        if not items:
            continue

        for result in items[:MAX_RESULTS]:
            url = result.get("link")
            title = result.get("title", "")
            snippet = result.get("snippet", "")

            if not url:
                continue

            emails = fetch_emails_from_url(url)
            primary_email = choose_primary_email(url, emails)

            record_id = uuid.uuid5(
                uuid.NAMESPACE_URL, f"{AGENT_SOURCE}:{url}"
            ).hex

            ddb_item = {
                "id": record_id,
                "url": url,
                "title": title,
                "snippet": snippet,
                "source": AGENT_SOURCE,
                "query": query,
                "timestamp": now_iso,
            }

            if primary_email:
                ddb_item["email"] = primary_email
            if emails:
                ddb_item["emails"] = emails

            save_item_to_dynamodb(ddb_item)
            saved_count += 1

    return saved_count


def lambda_handler(event, context):
    logger.info(f"[lambda_handler] Starting agent: {AGENT_SOURCE}")
    logger.info(f"[lambda_handler] Event: {json.dumps(event)}")

    try:
        saved = run_agent()
        body = {
            "message": f"{AGENT_SOURCE} ran successfully. Saved {saved} items.",
            "saved": saved,
        }
        logger.info(body)
        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps(body),
        }
    except Exception as e:
        logger.exception("[lambda_handler] Error running agent")
        return {
            "statusCode": 500,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"error": str(e)}),
        }
