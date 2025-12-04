#############################################
# Lambda functions for multi-agent scraper  #
# (Only Lambda resources – no terraform{},  #
#  no provider, no variables, no DynamoDB,  #
#  no IAM role definitions.)               #
#############################################

# Uses variables defined in variables.tf and IAM role in iamrole.tf

locals {
  common_env = {
    GOOGLE_API_KEY = var.google_api_key
    GOOGLE_CX      = var.google_cx
  }
}

#############################################
# Student Athlete Leadership Agent
#############################################
resource "aws_lambda_function" "student_athlete_leadership_agent" {
  function_name = "student-athlete-leadership-agent"
  handler       = "lambda.student_athlete_handler"
  runtime       = "python3.12"

  filename         = "lambda.zip"
  source_code_hash = filebase64sha256("lambda.zip")

  role        = aws_iam_role.lambda_exec.arn
  timeout     = 900
  memory_size = 512

  environment {
    variables = local.common_env
  }
}

#############################################
# Men of Color Initiative Agent
#############################################
resource "aws_lambda_function" "men_of_color_initiative_agent" {
  function_name = "men-of-color-initiative-agent"
  handler       = "lambda.men_of_color_handler"
  runtime       = "python3.12"

  filename         = "lambda.zip"
  source_code_hash = filebase64sha256("lambda.zip")

  role        = aws_iam_role.lambda_exec.arn
  timeout     = 900
  memory_size = 512

  environment {
    variables = local.common_env
  }
}

#############################################
# First-Gen Student Success Agent
#############################################
resource "aws_lambda_function" "first_gen_student_success_agent" {
  function_name = "first-gen-student-success-agent"
  handler       = "lambda.first_gen_handler"
  runtime       = "python3.12"

  filename         = "lambda.zip"
  source_code_hash = filebase64sha256("lambda.zip")

  role        = aws_iam_role.lambda_exec.arn
  timeout     = 900
  memory_size = 512

  environment {
    variables = local.common_env
  }
}

#############################################
# Multicultural Center Leadership Agent
#############################################
resource "aws_lambda_function" "multicultural_center_leadership_agent" {
  function_name = "multicultural-center-leadership-agent"
  handler       = "lambda.multicultural_center_handler"
  runtime       = "python3.12"

  filename         = "lambda.zip"
  source_code_hash = filebase64sha256("lambda.zip")

  role        = aws_iam_role.lambda_exec.arn
  timeout     = 900
  memory_size = 512

  environment {
    variables = local.common_env
  }
}

#############################################
# Service Learning / Civic Engagement Agent
#############################################
resource "aws_lambda_function" "service_learning_civic_engagement_agent" {
  function_name = "service-learning-civic-engagement-agent"
  handler       = "lambda.service_learning_handler"
  runtime       = "python3.12"

  filename         = "lambda.zip"
  source_code_hash = filebase64sha256("lambda.zip")

  role        = aws_iam_role.lambda_exec.arn
  timeout     = 900
  memory_size = 512

  environment {
    variables = local.common_env
  }
}

#############################################
# High School Student Council Leadership Agent
#############################################
resource "aws_lambda_function" "hs_student_council_leadership_agent" {
  function_name = "hs-student-council-leadership-agent"
  handler       = "lambda.hs_student_council_handler"
  runtime       = "python3.12"

  filename         = "lambda.zip"
  source_code_hash = filebase64sha256("lambda.zip")

  role        = aws_iam_role.lambda_exec.arn
  timeout     = 900
  memory_size = 512

  environment {
    variables = local.common_env
  }
}

#############################################
# Summer Bridge / Orientation Agent
#############################################
resource "aws_lambda_function" "summer_bridge_orientation_agent" {
  function_name = "summer-bridge-orientation-agent"
  handler       = "lambda.summer_bridge_handler"
  runtime       = "python3.12"

  filename         = "lambda.zip"
  source_code_hash = filebase64sha256("lambda.zip")

  role        = aws_iam_role.lambda_exec.arn
  timeout     = 900
  memory_size = 512

  environment {
    variables = local.common_env
  }
}
