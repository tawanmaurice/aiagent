#########################################
# LAMBDA FUNCTIONS (8 AGENTS)
#########################################

#########################################
# SGA / STUDENT GOVERNMENT AGENT
#########################################

resource "aws_lambda_function" "sga_agent" {
  function_name = "sga-agent-v2"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  memory_size   = 512
  timeout       = 30

  filename         = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")

  environment {
    variables = {
      DDB_TABLE_NAME = aws_dynamodb_table.speaking_leads.name
      GOOGLE_API_KEY = var.google_api_key
      GOOGLE_CX      = var.google_cx

      AGENT_SOURCE   = "sga_student_government_agent"
      SEARCH_QUERIES = "Student Government Association leadership retreat site:.edu||SGA leadership conference site:.edu"
      MAX_RESULTS    = "5"
    }
  }
}

#########################################
# ORIENTATION / WELCOME WEEK AGENT
#########################################

resource "aws_lambda_function" "orientation_agent" {
  function_name = "orientation-agent-v2"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  memory_size   = 512
  timeout       = 30

  filename         = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")

  environment {
    variables = {
      DDB_TABLE_NAME = aws_dynamodb_table.speaking_leads.name
      GOOGLE_API_KEY = var.google_api_key
      GOOGLE_CX      = var.google_cx

      AGENT_SOURCE   = "orientation_welcome_week_agent"
      SEARCH_QUERIES = "welcome week keynote site:.edu||new student orientation speaker site:.edu"
      MAX_RESULTS    = "5"
    }
  }
}

#########################################
# STUDENT LEADERSHIP CONFERENCE / SUMMIT AGENT
#########################################

resource "aws_lambda_function" "leadership_conference_agent" {
  function_name = "leadership-conference-agent-v2"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  memory_size   = 512
  timeout       = 30

  filename         = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")

  environment {
    variables = {
      DDB_TABLE_NAME = aws_dynamodb_table.speaking_leads.name
      GOOGLE_API_KEY = var.google_api_key
      GOOGLE_CX      = var.google_cx

      AGENT_SOURCE   = "student_leadership_conference_agent"
      SEARCH_QUERIES = "student leadership conference site:.edu||student leadership summit site:.edu"
      MAX_RESULTS    = "5"
    }
  }
}

#########################################
# STUDENT ACTIVITIES / RETREATS AGENT
#########################################

resource "aws_lambda_function" "activities_agent" {
  function_name = "activities-agent-v2"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  memory_size   = 512
  timeout       = 30

  filename         = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")

  environment {
    variables = {
      DDB_TABLE_NAME = aws_dynamodb_table.speaking_leads.name
      GOOGLE_API_KEY = var.google_api_key
      GOOGLE_CX      = var.google_cx

      AGENT_SOURCE   = "student_activities_retreats_agent"
      SEARCH_QUERIES = "student activities leadership retreat site:.edu||student activities board leadership workshop site:.edu"
      MAX_RESULTS    = "5"
    }
  }
}

#########################################
# LYCEUM / LECTURE SERIES AGENT
#########################################

resource "aws_lambda_function" "lyceum_agent" {
  function_name = "lyceum-agent-v2"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  memory_size   = 512
  timeout       = 30

  filename         = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")

  environment {
    variables = {
      DDB_TABLE_NAME = aws_dynamodb_table.speaking_leads.name
      GOOGLE_API_KEY = var.google_api_key
      GOOGLE_CX      = var.google_cx

      AGENT_SOURCE   = "lyceum_lecture_series_agent"
      SEARCH_QUERIES = "lyceum series site:.edu||distinguished speaker series site:.edu"
      MAX_RESULTS    = "5"
    }
  }
}

#########################################
# FIRST-YEAR EXPERIENCE / COLLEGE SUCCESS AGENT
#########################################

resource "aws_lambda_function" "fye_agent" {
  function_name = "fye-agent-v2"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  memory_size   = 512
  timeout       = 30

  filename         = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")

  environment {
    variables = {
      DDB_TABLE_NAME = aws_dynamodb_table.speaking_leads.name
      GOOGLE_API_KEY = var.google_api_key
      GOOGLE_CX      = var.google_cx

      AGENT_SOURCE   = "first_year_experience_agent"
      SEARCH_QUERIES = "first year experience keynote site:.edu||college success workshop site:.edu"
      MAX_RESULTS    = "5"
    }
  }
}

#########################################
# TRIO / STUDENT SUPPORT SERVICES AGENT
#########################################

resource "aws_lambda_function" "trio_agent" {
  function_name = "trio-agent-v2"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  memory_size   = 512
  timeout       = 30

  filename         = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")

  environment {
    variables = {
      DDB_TABLE_NAME = aws_dynamodb_table.speaking_leads.name
      GOOGLE_API_KEY = var.google_api_key
      GOOGLE_CX      = var.google_cx

      AGENT_SOURCE   = "trio_student_support_agent"
      SEARCH_QUERIES = "TRIO student support services leadership workshop site:.edu||Upward Bound leadership program site:.edu"
      MAX_RESULTS    = "5"
    }
  }
}

#########################################
# DEI / BELONGING PROGRAMS AGENT
#########################################

resource "aws_lambda_function" "dei_agent" {
  function_name = "dei-agent-v2"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  memory_size   = 512
  timeout       = 30

  filename         = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")

  environment {
    variables = {
      DDB_TABLE_NAME = aws_dynamodb_table.speaking_leads.name
      GOOGLE_API_KEY = var.google_api_key
      GOOGLE_CX      = var.google_cx

      AGENT_SOURCE   = "dei_belonging_programs_agent"
      SEARCH_QUERIES = "diversity and inclusion student leadership workshop site:.edu||belonging student leadership program site:.edu"
      MAX_RESULTS    = "5"
    }
  }
}
