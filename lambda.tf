########################################
# Lambda function for Speaking Agent
########################################

# Assumes you build lambda_function.zip manually in the project root
# (same folder as this .tf file), containing lambda_function.py
# and any dependencies.

resource "aws_lambda_function" "speaking_agent" {
  function_name = "speaking-agent"
  role          = aws_iam_role.lambda_exec.arn

  # Python handler: file "lambda_function.py", function "lambda_handler"
  handler = "lambda_function.lambda_handler"
  runtime = "python3.11"

  # Zip file with your Lambda code + dependencies
  filename         = "${path.module}/lambda_function.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_function.zip")

  timeout     = 900
  memory_size = 512

  environment {
    variables = {
      # DynamoDB table for saving conferences / leads
      DDB_TABLE_NAME = aws_dynamodb_table.speaking_leads.name

      # OpenAI config
      OPENAI_API_KEY = var.openai_api_key
      OPENAI_MODEL   = "gpt-4.1-mini"

      # Google Programmable Search config
      GOOGLE_API_KEY = var.google_api_key
      GOOGLE_CX      = var.google_cx_id # MUST be GOOGLE_CX for the Python code

      # Optional: override autonomous topics (comma-separated)
      # AUTO_TOPICS = "student leadership conference 2025 at community colleges in the Midwest, student leadership summit 2025 at universities in the Northeast"
    }
  }
}

########################################
# Lambda permissions for CloudWatch rule
########################################

resource "aws_lambda_permission" "allow_events" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.speaking_agent.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.speaking_agent_schedule.arn
}
