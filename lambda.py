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

# IMPORTANT: use the same name as in dynamo.tf / iamrole.tf
TABLE_NAME = "speaking-leads-v3-multi"

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(TABLE_NAME)

# ---------------------------------------------------
# Agent search definitions
# ---------------------------------------------------
AGENTS = {
    # ----------------------------------------
    # Existing 7 agents
    # ----------------------------------------
    "student_athlete_leadership_agent": {
        "search_queries": [
            '"student-athlete leadership retreat" site:.edu',
            '"student athlete leadership conference" site:.edu',
            '"student-athlete leadership workshop" site:.edu',
        ],
        "max_results_per_query": 5,
    },
    "men_of_color_initiative_agent": {
        "search_queries": [
            '"men of color initiative" student leadership site:.edu',
            '"men of color leadership retreat" site:.edu',
            '"brotherhood" "men of color" student program site:.edu',
        ],
        "max_results_per_query": 5,
    },
    "first_gen_student_success_agent": {
        "search_queries": [
            '"first generation student success conference" site:.edu',
            '"first-gen student success" "leadership" site:.edu',
            '"TRIO SSS leadership retreat" site:.edu',
            '"TRIO student engagement event" site:.edu',
        ],
        "max_results_per_query": 5,
    },
    "multicultural_center_leadership_agent": {
        "search_queries": [
            '"multicultural center" "student leadership retreat" site:.edu',
            '"diversity and inclusion" "student leadership conference" site:.edu',
            '"multicultural affairs" leadership workshop site:.edu',
        ],
        "max_results_per_query": 5,
    },
    "service_learning_civic_engagement_agent": {
        "search_queries": [
            '"service learning" leadership retreat site:.edu',
            '"civic engagement" "student leadership" site:.edu',
            '"day of service" student leadership site:.edu',
        ],
        "max_results_per_query": 5,
    },
    "hs_student_council_leadership_agent": {
        "search_queries": [
            '"high school student council leadership conference"',
            '"student council leadership retreat" "high school"',
            '"ASB leadership camp" "student council"',
        ],
        "max_results_per_query": 5,
    },
    "summer_bridge_orientation_agent": {
        "search_queries": [
            '"summer bridge" "student leadership" site:.edu',
            '"new student orientation" leadership retreat site:.edu',
            '"welcome week" leadership conference site:.edu',
        ],
        "max_results_per_query": 5,
    },

    # ----------------------------------------
    # NEW: student leadership / CC heavy
    # ----------------------------------------

    # SGA leadership / student government
    "sga_leadership_agent": {
        "search_queries": [
            '"student government association" "leadership retreat" site:.edu',
            '"SGA leadership conference" site:.edu',
            '"student government" "officer training" site:.edu',
        ],
        "max_results_per_query": 5,
    },

    # Generic student leadership retreats
    "student_leadership_retreat_agent": {
        "search_queries": [
            '"student leadership retreat" site:.edu',
            '"student leader retreat" site:.edu',
            '"leadership retreat for student leaders" site:.edu',
        ],
        "max_results_per_query": 5,
    },

    # Generic student leadership conferences
    "student_leadership_conference_agent": {
        "search_queries": [
            '"student leadership conference" site:.edu',
            '"student leadership summit" site:.edu',
            '"student leadership institute" site:.edu',
        ],
        "max_results_per_query": 5,
    },

    # Leadership summits (campus-wide)
    "leadership_summit_agent": {
        "search_queries": [
            '"leadership summit" "student" site:.edu',
            '"student leadership summit" "keynote" site:.edu',
            '"leadership summit" "community college" site:.edu',
        ],
        "max_results_per_query": 5,
    },

    # Officer training (clubs, orgs, SGA, RSO)
    "officer_training_agent": {
        "search_queries": [
            '"student organization officer training" site:.edu',
            '"club officer training" "student leadership" site:.edu',
            '"student leader training" "officers" site:.edu',
        ],
        "max_results_per_query": 5,
    },

    # Speaker series / lyceum / distinguished lecture
    "speaker_series_lyceum_agent": {
        "search_queries": [
            '"lyceum series" "speaker" site:.edu',
            '"distinguished lecture series" "student activities" site:.edu',
            '"speaker series" "student leadership" site:.edu',
        ],
        "max_results_per_query": 5,
    },

    # Orientation leaders / OLs
    "orientation_leader_agent": {
        "search_queries": [
            '"orientation leader training" site:.edu',
            '"orientation leaders" "student leadership" site:.edu',
            '"orientation leader workshop" site:.edu',
        ],
        "max_results_per_query": 5,
    },

    # Residence life / RA leadership (broad)
    "res_life_ra_leadership_agent": {
        "search_queries": [
            '"resident assistant training" "leadership" site:.edu',
            '"RA training" "leadership development" site:.edu',
            '"residence life" "student leadership" site:.edu',
        ],
        "max_results_per_query": 5,
    },

    # ----------------------------------------
    # NEW: RA / Ambassador / Sophomore focused
    # ----------------------------------------

    # RA-specific retreats / conferences (narrower, event-focused)
    "resident_assistant_leadership_agent": {
        "search_queries": [
            '"resident assistant leadership retreat" site:.edu',
            '"resident assistant leadership conference" site:.edu',
            '"RA leadership retreat" site:.edu',
            '"resident assistant leadership summit" site:.edu',
            '"RA fall training retreat" site:.edu',
        ],
        "max_results_per_query": 5,
    },

    # Campus / student ambassador events
    "campus_ambassador_events_agent": {
        "search_queries": [
            '"student ambassador leadership retreat" site:.edu',
            '"student ambassador leadership conference" site:.edu',
            '"student ambassador training workshop" site:.edu',
            '"campus ambassador leadership" "retreat" site:.edu',
            '"student ambassador summit" site:.edu',
            '"student ambassador orientation" "leadership" site:.edu',
        ],
        "max_results_per_query": 5,
    },

    # Sophomore / second-year leadership & success
    "sophomore_leadership_agent": {
        "search_queries": [
            '"sophomore leadership retreat" site:.edu',
            '"sophomore leadership program" site:.edu',
            '"sophomore leadership conference" site:.edu',
            '"second-year experience" "leadership" site:.edu',
            '"second year leadership retreat" site:.edu',
            '"sophomore success program" "leadership" site:.edu',
        ],
        "max_results_per_query": 5,
    },

    # Honors program leadership
    "honors_program_leadership_agent": {
        "search_queries": [
            '"honors program" "leadership conference" site:.edu',
            '"honors college" "student leadership" site:.edu',
            '"honors program" "leadership retreat" site:.edu',
        ],
        "max_results_per_query": 5,
    },

    # Leadership certificate programs
    "leadership_certificate_program_agent": {
        "search_queries": [
            '"leadership certificate program" students site:.edu',
            '"student leadership certificate" site:.edu',
            '"co-curricular leadership program" site:.edu',
        ],
        "max_results_per_query": 5,
    },

    # Leadership academies
    "leadership_academy_agent": {
        "search_queries": [
            '"student leadership academy" site:.edu',
            '"emerging leaders program" site:.edu',
            '"leadership academy" "student affairs" site:.edu',
        ],
        "max_results_per_query": 5,
    },

    # Student activities / campus activities leadership
    "student_activities_leadership_agent": {
        "search_queries": [
            '"student activities" "leadership workshop" site:.edu',
            '"campus activities" "leadership development" site:.edu',
            '"student activities office" "leadership series" site:.edu',
        ],
        "max_results_per_query": 5,
    },

    # College success / first-year experience style leadership
    "college_success_leadership_agent": {
        "search_queries": [
            '"college success seminar" "leadership" site:.edu',
            '"first year experience" "leadership" site:.edu',
            '"student success workshop" "leadership" site:.edu',
        ],
        "max_results_per_query": 5,
    },

    # Career success leadership (career centers, career-ready events)
    "career_success_leadership_agent": {
        "search_queries": [
            '"career services" "leadership workshop" site:.edu',
            '"career readiness" "leadership" site:.edu',
            '"professional success" "student leadership" site:.edu',
        ],
        "max_results_per_query": 5,
    },

    # Social justice / DEI leadership
    "social_justice_leadership_agent": {
        "search_queries": [
            '"social justice leadership" "students" site:.edu',
            '"DEI leadership workshop" "students" site:.edu',
            '"equity and inclusion" "student leadership" site:.edu',
        ],
        "max_results_per_query": 5,
    },

    # Community college student leadership – heavy CC bias
    "cc_student_leadership_agent": {
        "search_queries": [
            '"community college" "student leadership conference"',
            '"community college" "student leadership retreat"',
            '"community college" "student government" "leadership"',
        ],
        "max_results_per_query": 5,
    },

    # Community college success & retention events
    "cc_success_and_retention_agent": {
        "search_queries": [
            '"community college" "student success conference"',
            '"community college" "retention summit" "students"',
            '"community college" "first year experience" "leadership"',
        ],
        "max_results_per_query": 5,
    },
}

# ---------------------------------------------------
# Helper functions
# ---------------------------------------------------
def google_search(query: str, num: int = 5):
    """Call Google Custom Search and return items list."""
    logger.info(f"Searching Google: {query}")

    params = {
        "key": GOOGLE_API_KEY,
        "cx": GOOGLE_CX,
        "q": query,
        "num": num,
    }

    resp = requests.get("https://www.googleapis.com/customsearch/v1", params=params, timeout=15)
    resp.raise_for_status()
    data = resp.json()
    return data.get("items", [])


def fetch_html(url: str) -> str | None:
    """Fetch raw HTML for a URL."""
    try:
        headers = {
            "User-Agent": "Mozilla/5.0 (compatible; SpeakingAgent/1.0; +https://example.com)"
        }
        resp = requests.get(url, headers=headers, timeout=15)
        resp.raise_for_status()
        return resp.text
    except Exception as e:
        logger.warning(f"Error fetching HTML from {url}: {e}")
        return None


def find_email_in_text(text: str) -> str | None:
    """Very simple email finder from raw text."""
    if not text:
        return None

    # Basic email regex
    pattern = r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}"
    matches = re.findall(pattern, text)
    if not matches:
        return None

    # Return the first one for now
    return matches[0]


def extract_domain(url: str) -> str:
    """Extract domain from URL."""
    parsed = urlparse(url)
    return parsed.netloc


def google_search_for_domain_email(domain: str) -> str | None:
    """
    Fallback: search Google again limited to this domain,
    grab first page, try to extract email.
    """
    fallback_query = f'site:{domain} "email" "contact"'
    logger.info(f"Fallback search on domain: {domain} with query: {fallback_query}")
    try:
        items = google_search(fallback_query, num=3)
    except Exception as e:
        logger.warning(f"Error in fallback domain search for {domain}: {e}")
        return None

    for item in items:
        link = item.get("link")
        if not link:
            continue

        html = fetch_html(link)
        if not html:
            continue

        email = find_email_in_text(html)
        if email:
            return email

    return None


def make_id(url: str, agent_name: str) -> str:
    """Deterministic ID from URL + agent name."""
    h = hashlib.sha256()
    h.update((url + "|" + agent_name).encode("utf-8"))
    return h.hexdigest()


def item_exists(item_id: str) -> bool:
    """
    Check if an item with this id already exists in DynamoDB.
    Used for de-duplication.
    """
    try:
        resp = table.get_item(Key={"id": item_id})
        return "Item" in resp
    except botocore.exceptions.ClientError as e:
        logger.error(f"Error checking existence in DynamoDB for id={item_id}: {e}")
        # Fail open: if we can't check, we'll treat it as not existing
        return False


def save_to_dynamodb(item: dict, agent_name: str) -> bool:
    """Save item to DynamoDB, return True on success."""
    try:
        table.put_item(Item=item)
        return True
    except botocore.exceptions.ClientError as e:
        logger.error(f"[{agent_name}] Error saving to DynamoDB: {e}")
        return False


def run_agent(agent_name: str, context: dict | None = None) -> dict:
    """
    Generic runner for all agents.
    agent_name must exist in AGENTS keys.

    Behavior:
    - Skip duplicates (if id already exists in DynamoDB)
    - Only save items that have a non-empty contact_email
    """
    if agent_name not in AGENTS:
        raise ValueError(f"Unknown agent: {agent_name}")

    cfg = AGENTS[agent_name]
    total_saved = 0

    logger.info(f"[{agent_name}] Starting run.")

    for q in cfg["search_queries"]:
        try:
            items = google_search(q, num=cfg["max_results_per_query"])
        except Exception as e:
            logger.error(f"[{agent_name}] Error during Google search: {e}")
            continue

        for result in items:
            url = result.get("link")
            title = result.get("title")

            if not url:
                continue

            logger.info(f"[{agent_name}] Processing URL: {url}")

            # Build deterministic ID for de-dupe
            item_id = make_id(url, agent_name)

            # De-duplication: skip if already in DynamoDB
            if item_exists(item_id):
                logger.info(f"[{agent_name}] Skipping duplicate URL (already in table): {url}")
                continue

            # Try to get email from the main page
            html = fetch_html(url)
            email = find_email_in_text(html) if html else None

            # If no email on main page, try fallback domain search
            if not email:
                domain = extract_domain(url)
                logger.info(f"[{agent_name}] No email on main page. Fallback search on domain: {domain}")
                email = google_search_for_domain_email(domain)

            # If still no email, skip saving this record
            if not email:
                logger.info(f"[{agent_name}] No email found even after fallback. Skipping URL: {url}")
                continue

            # Build the item
            item = {
                "id": item_id,
                "url": url,
                "title": title or "",
                "contact_email": email,
                "source": agent_name,
                "scraped_at": int(time.time()),
            }

            logger.info(f"[{agent_name}] Saving item to DynamoDB: {url}")
            if save_to_dynamodb(item, agent_name):
                total_saved += 1
            else:
                logger.error(
                    f"[{agent_name}] Error processing result: failed to save item for URL {url}"
                )

    logger.info(f"[{agent_name}] Finished. Saved {total_saved} items.")
    return {
        "message": f"{agent_name} ran successfully. Saved {total_saved} items.",
        "saved": total_saved,
        "source": agent_name,
    }


def make_response(body: dict, status_code: int = 200) -> dict:
    return {
        "statusCode": status_code,
        "body": json.dumps(body),
    }


# ---------------------------------------------------
# Lambda handlers (Terraform points to these)
# ---------------------------------------------------

def student_athlete_handler(event, context):
    body = run_agent("student_athlete_leadership_agent", event)
    return make_response(body)


def men_of_color_handler(event, context):
    body = run_agent("men_of_color_initiative_agent", event)
    return make_response(body)


def first_gen_handler(event, context):
    body = run_agent("first_gen_student_success_agent", event)
    return make_response(body)


def multicultural_center_handler(event, context):
    body = run_agent("multicultural_center_leadership_agent", event)
    return make_response(body)


def service_learning_handler(event, context):
    body = run_agent("service_learning_civic_engagement_agent", event)
    return make_response(body)


def hs_student_council_handler(event, context):
    body = run_agent("hs_student_council_leadership_agent", event)
    return make_response(body)


def summer_bridge_handler(event, context):
    body = run_agent("summer_bridge_orientation_agent", event)
    return make_response(body)


def sga_leadership_handler(event, context):
    body = run_agent("sga_leadership_agent", event)
    return make_response(body)


def student_leadership_retreat_handler(event, context):
    body = run_agent("student_leadership_retreat_agent", event)
    return make_response(body)


def student_leadership_conference_handler(event, context):
    body = run_agent("student_leadership_conference_agent", event)
    return make_response(body)


def leadership_summit_handler(event, context):
    body = run_agent("leadership_summit_agent", event)
    return make_response(body)


def officer_training_handler(event, context):
    body = run_agent("officer_training_agent", event)
    return make_response(body)


def speaker_series_lyceum_handler(event, context):
    body = run_agent("speaker_series_lyceum_agent", event)
    return make_response(body)


def orientation_leader_handler(event, context):
    body = run_agent("orientation_leader_agent", event)
    return make_response(body)


def res_life_ra_leadership_handler(event, context):
    body = run_agent("res_life_ra_leadership_agent", event)
    return make_response(body)


def resident_assistant_leadership_handler(event, context):
    body = run_agent("resident_assistant_leadership_agent", event)
    return make_response(body)


def campus_ambassador_events_handler(event, context):
    body = run_agent("campus_ambassador_events_agent", event)
    return make_response(body)


def sophomore_leadership_handler(event, context):
    body = run_agent("sophomore_leadership_agent", event)
    return make_response(body)


def honors_program_leadership_handler(event, context):
    body = run_agent("honors_program_leadership_agent", event)
    return make_response(body)


def leadership_certificate_program_handler(event, context):
    body = run_agent("leadership_certificate_program_agent", event)
    return make_response(body)


def leadership_academy_handler(event, context):
    body = run_agent("leadership_academy_agent", event)
    return make_response(body)


def student_activities_leadership_handler(event, context):
    body = run_agent("student_activities_leadership_agent", event)
    return make_response(body)


def college_success_leadership_handler(event, context):
    body = run_agent("college_success_leadership_agent", event)
    return make_response(body)


def career_success_leadership_handler(event, context):
    body = run_agent("career_success_leadership_agent", event)
    return make_response(body)


def social_justice_leadership_handler(event, context):
    body = run_agent("social_justice_leadership_agent", event)
    return make_response(body)


def cc_student_leadership_handler(event, context):
    body = run_agent("cc_student_leadership_agent", event)
    return make_response(body)


def cc_success_and_retention_handler(event, context):
    body = run_agent("cc_success_and_retention_agent", event)
    return make_response(body)
