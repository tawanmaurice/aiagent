#############################################
# Lambda function for Truck ESL Agent
#############################################

# Common environment vars for the Lambda
locals {
  common_env = {
    # Google Custom Search config (from variables.tf)
    GOOGLE_API_KEY = var.google_api_key
    GOOGLE_CX      = var.google_cx

    # If your lambda.py reads TABLE_NAME from env, you can enable this:
    # TABLE_NAME = "speaking-leads-v3-multi"
  }
}

resource "aws_lambda_function" "truck_esl_agent" {
  function_name = "truck-esl-agent"
  handler       = "lambda.truck_esl_handler"
  runtime       = "python3.12"

  # The zip you already built in this folder (C:\Users\tawan\truck-esl-agent\lambda.zip)
  filename         = "lambda.zip"
  source_code_hash = filebase64sha256("lambda.zip")

  # 🔴 IMPORTANT: use the *data* role, not a resource
  role        = data.aws_iam_role.lambda_exec.arn
  timeout     = 900
  memory_size = 512

  environment {
    variables = local.common_env
  }
}
