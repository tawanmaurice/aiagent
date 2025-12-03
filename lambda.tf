#########################################
# LAMBDA FUNCTIONS (4 AGENTS)
#########################################

resource "aws_lambda_function" "sga_agent" {
  function_name = "sga-agent"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "sga_lambda_function.lambda_handler"
  runtime       = "python3.12"
  memory_size   = 512
  timeout       = 30

  filename         = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")

  environment {
    variables = {
      DDB_TABLE_NAME = aws_dynamodb_table.speaking_leads.name
      OPENAI_API_KEY = var.openai_api_key
      OPENAI_MODEL   = "gpt-4.1-mini"
      GOOGLE_API_KEY = var.google_api_key
      GOOGLE_CX      = var.google_cx
    }
  }
}

#########################################
# ORIENTATION AGENT
#########################################

resource "aws_lambda_function" "orientation_agent" {
  function_name = "orientation-agent"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "sga_lambda_function.lambda_handler"
  runtime       = "python3.12"
  memory_size   = 512
  timeout       = 30

  filename         = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")

  environment {
    variables = {
      DDB_TABLE_NAME = aws_dynamodb_table.speaking_leads.name
      OPENAI_API_KEY = var.openai_api_key
      OPENAI_MODEL   = "gpt-4.1-mini"
      GOOGLE_API_KEY = var.google_api_key
      GOOGLE_CX      = var.google_cx
    }
  }
}

#########################################
# LEADERSHIP CONFERENCE AGENT
#########################################

resource "aws_lambda_function" "leadership_conference_agent" {
  function_name = "leadership-conference-agent"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "sga_lambda_function.lambda_handler"
  runtime       = "python3.12"
  memory_size   = 512
  timeout       = 30

  filename         = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")

  environment {
    variables = {
      DDB_TABLE_NAME = aws_dynamodb_table.speaking_leads.name
      OPENAI_API_KEY = var.openai_api_key
      OPENAI_MODEL   = "gpt-4.1-mini"
      GOOGLE_API_KEY = var.google_api_key
      GOOGLE_CX      = var.google_cx
    }
  }
}

#########################################
# STUDENT ACTIVITIES / RETREATS AGENT
#########################################

resource "aws_lambda_function" "activities_agent" {
  function_name = "activities-agent"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "sga_lambda_function.lambda_handler"
  runtime       = "python3.12"
  memory_size   = 512
  timeout       = 30

  filename         = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")

  environment {
    variables = {
      DDB_TABLE_NAME = aws_dynamodb_table.speaking_leads.name
      OPENAI_API_KEY = var.openai_api_key
      OPENAI_MODEL   = "gpt-4.1-mini"
      GOOGLE_API_KEY = var.google_api_key
      GOOGLE_CX      = var.google_cx
    }
  }
}
