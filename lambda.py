import os
import json
import re
import time
import hashlib
import logging
from urllib.parse import urlparse

import boto3
import botocore.exceptions
import requests

# ---------------------------------------------------
# Logging setup
# ---------------------------------------------------
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# ---------------------------------------------------
# Environment / configuration
# ---------------------------------------------------
GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")
GOOGLE_CX = os.getenv("GOOGLE_CX")

# IMPORTANT: this must match the DynamoDB table name you are using
# In your terraform, this is "speaking-leads-v3-multi"
TABLE_NAME = "speaking-leads-v3-multi"

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(TABLE_NAME)

# Agent name tag in DynamoDB so you know who created the lead
AGENT_NAME = "truck_esl_agent"

# ---------------------------------------------------
# Search queries for Truck ESL / CDL English
# ---------------------------------------------------
SEARCH_QUERIES = [
    '"ESL for truck drivers" "online class"',
    '"English for truck drivers" "course"',
    '"CDL" "ESL class" "community college"',
    '"CDL preparation" "ESL" "English language"',
    '"truck driver" "English language training"'
]

EMAIL_REGEX = re.compile(
    r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}",
    re.IGNORECASE,
)


def normalize_domain(url: str) -> str:
    """Return just the domain like example.edu from a URL."""
    try:
        parsed = urlparse(url)
        return parsed.netloc.lower()
    except Exception:
        return ""


def google_search(query: str, start: int = 1, num: int = 10):
    """Call Google Custom Search API and return list of items."""
    if not GOOGLE_API_KEY or not GOOGLE_CX:
        logger.error("Missing GOOGLE_API_KEY or GOOGLE_CX environment variables.")
        return []

    params = {
        "key": GOOGLE_API_KEY,
        "cx": GOOGLE_CX,
        "q": query,
        "start": start,
        "num": num,
    }
    try:
        resp = requests.get(
            "https://www.googleapis.com/customsearch/v1",
            params=params,
            timeout=15,
        )
        resp.raise_for_status()
        data = resp.json()
        return data.get("items", [])
    except Exception as e:
        logger.exception(f"Google search failed for query={query}: {e}")
        return []


def fetch_page(url: str) -> str:
    """Download the HTML for a page (best-effort)."""
    try:
        resp = requests.get(url, timeout=15)
        if "text/html" not in resp.headers.get("Content-Type", ""):
            return ""
        return resp.text
    except Exception as e:
        logger.info(f"Failed to fetch page {url}: {e}")
        return ""


def extract_emails_from_text(text: str):
    """Return a set of unique email addresses found in text."""
    if not text:
        return set()
    emails = set(EMAIL_REGEX.findall(text))
    return emails


def generate_id(email: str, url: str) -> str:
    """Stable ID so we don’t insert duplicates for same email+url+agent."""
    raw = f"{email}|{url}|{AGENT_NAME}"
    return hashlib.sha256(raw.encode("utf-8")).hexdigest()


def save_lead(email: str, url: str, title: str, snippet: str) -> bool:
    """Save a lead to DynamoDB (if not already there)."""
    item_id = generate_id(email, url)
    domain = normalize_domain(url)
    now = int(time.time())

    item = {
        "id": item_id,
        "email": email,
        "url": url,
        "domain": domain,
        "title": title[:500],
        "snippet": snippet[:1000],
        "agent": AGENT_NAME,
        "topic": "Truck ESL / CDL English",
        "created_at": now,
    }

    try:
        table.put_item(
            Item=item,
            ConditionExpression="attribute_not_exists(id)",
        )
        logger.info(f"Saved new lead: {email} ({url})")
        return True
    except botocore.exceptions.ClientError as e:
        if e.response["Error"]["Code"] == "ConditionalCheckFailedException":
            logger.info(f"Duplicate lead skipped: {email} ({url})")
            return False
        logger.exception(f"Error saving lead {email} ({url}): {e}")
        return False


def run_truck_esl_agent() -> int:
    """
    Main logic:
    - run several Google searches
    - fetch pages
    - extract emails
    - store them in DynamoDB
    """
    total_saved = 0

    for query in SEARCH_QUERIES:
        logger.info(f"Running Google search for query: {query}")
        items = google_search(query, start=1, num=10)
        logger.info(f"Google search for '{query}' returned {len(items)} items")

        for item in items:
            link = item.get("link")
            title = item.get("title", "")
            snippet = item.get("snippet", "")

            if not link:
                continue

            # Try to fetch the page and pull emails from the HTML body
            page_text = fetch_page(link)
            emails = extract_emails_from_text(page_text)

            # Fallback: also search title/snippet text if page fails
            if not emails:
                fallback_text = " ".join([title, snippet])
                emails = extract_emails_from_text(fallback_text)

            if not emails:
                logger.info(f"No emails found for {link}")
                continue

            for email in emails:
                if save_lead(email, link, title, snippet):
                    total_saved += 1

        # small pause between queries to be polite
        time.sleep(1)

    logger.info(f"Truck ESL agent finished. Total leads saved: {total_saved}")
    return total_saved


def truck_esl_handler(event, context):
    """
    Lambda entrypoint.

    This MUST match the handler string in Terraform:
        handler = "lambda.truck_esl_handler"
    """
    logger.info("Truck ESL handler invoked")
    saved = run_truck_esl_agent()
    body = {
        "message": "Truck ESL agent completed.",
        "saved": saved,
    }
    return {
        "statusCode": 200,
        "body": json.dumps(body),
    }
