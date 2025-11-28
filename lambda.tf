########################################
# Lambda function for Speaking Agent
########################################

# If you want Terraform to manage the zip, you can add an archive_file
# later. For now we'll assume you build lambda_function.zip manually
# in the project root.

resource "aws_lambda_function" "speaking_agent" {
  function_name = "speaking-agent"
  role          = aws_iam_role.lambda_exec.arn

  # Python handler: file "lambda_function.py", function "handler"
  handler       = "lambda_function.handler"
  runtime       = "python3.11"

  # Zip file with your lambda code + dependencies
  filename         = "${path.module}/lambda_function.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_function.zip")

  timeout     = 900
  memory_size = 512

  environment {
    variables = {
      DDB_TABLE_NAME = aws_dynamodb_table.speaking_leads.name
      OPENAI_API_KEY = var.openai_api_key
      GOOGLE_API_KEY = var.google_api_key
      GOOGLE_CX_ID   = var.google_cx_id
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
