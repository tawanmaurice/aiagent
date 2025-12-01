Autonomous Speaking Engagement Finder/Locator Agent

The Autonomous Speaking Engagement Finder/Locator Agent is a serverless system that automatically discovers student leadership conferences and large-scale programs across U.S. colleges and universities. It runs daily, extracts structured data, finds contact emails, and saves every opportunity into DynamoDB—fully hands-free.

🚀 What It Does

Searches .edu sites using Google Custom Search

Extracts real conferences & programs using OpenAI

Scrapes webpages to find contact emails

Stores everything in DynamoDB with timestamps and seen counts

Runs automatically on a schedule via EventBridge

Requires zero manual input

📁 Project Structure
/
├── lambda_function.py
├── requirements.txt
└── README.md

🔧 Setup & Install

Clone the repo:

git clone https://github.com/yourname/speaking-agent.git
cd speaking-agent


Install dependencies:

pip install -r requirements.txt

🔑 Environment Variables

Set these in AWS Lambda → Configuration → Environment Variables:

Variable	Description
GOOGLE_API_KEY	Google CSE API key
GOOGLE_CX	Google Search Engine ID
OPENAI_API_KEY	OpenAI key
OPENAI_MODEL	e.g., gpt-4.1-mini
DDB_TABLE_NAME	DynamoDB table name
🛠️ Deployment

Zip and upload to Lambda:

zip -r speaking-agent.zip lambda_function.py requirements.txt


Upload the ZIP into AWS Lambda

Set timeout ~45s

Configure environment variables

Deploy

⏱️ Scheduling

Create an EventBridge rule:

Twice a day:

cron(0 8,20 * * ? *)

📦 DynamoDB Record Example
{
  "id": "example-conference",
  "conference_name": "Student Leadership Summit",
  "school_name": "Example University",
  "url": "https://example.edu/leadership",
  "contact_email": "leadership@example.edu",
  "seen_count": 2,
  "status": "NEW",
  "created_at": "2025-01-18T12:00:00Z",
  "updated_at": "2025-01-18T12:00:00Z"
}

📈 Roadmap

Optional outreach email generator

Automated reports

Dashboard

Multi-topic rotation
