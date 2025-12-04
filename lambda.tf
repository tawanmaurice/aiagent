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

#####################################################
# NEW: Student Leadership / Community College Agents
#####################################################

#############################################
# SGA Leadership Agent
#############################################
resource "aws_lambda_function" "sga_leadership_agent" {
  function_name = "sga-leadership-agent"
  handler       = "lambda.sga_leadership_handler"
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
# Student Leadership Retreat Agent
#############################################
resource "aws_lambda_function" "student_leadership_retreat_agent" {
  function_name = "student-leadership-retreat-agent"
  handler       = "lambda.student_leadership_retreat_handler"
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
# Student Leadership Conference Agent
#############################################
resource "aws_lambda_function" "student_leadership_conference_agent" {
  function_name = "student-leadership-conference-agent"
  handler       = "lambda.student_leadership_conference_handler"
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
# Leadership Summit Agent
#############################################
resource "aws_lambda_function" "leadership_summit_agent" {
  function_name = "leadership-summit-agent"
  handler       = "lambda.leadership_summit_handler"
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
# Officer Training Agent
#############################################
resource "aws_lambda_function" "officer_training_agent" {
  function_name = "officer-training-agent"
  handler       = "lambda.officer_training_handler"
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
# Speaker Series / Lyceum Agent
#############################################
resource "aws_lambda_function" "speaker_series_lyceum_agent" {
  function_name = "speaker-series-lyceum-agent"
  handler       = "lambda.speaker_series_lyceum_handler"
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
# Orientation Leader Agent
#############################################
resource "aws_lambda_function" "orientation_leader_agent" {
  function_name = "orientation-leader-agent"
  handler       = "lambda.orientation_leader_handler"
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
# Res Life / RA Leadership Agent
#############################################
resource "aws_lambda_function" "res_life_ra_leadership_agent" {
  function_name = "res-life-ra-leadership-agent"
  handler       = "lambda.res_life_ra_leadership_handler"
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
# Honors Program Leadership Agent
#############################################
resource "aws_lambda_function" "honors_program_leadership_agent" {
  function_name = "honors-program-leadership-agent"
  handler       = "lambda.honors_program_leadership_handler"
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
# Leadership Certificate Program Agent
#############################################
resource "aws_lambda_function" "leadership_certificate_program_agent" {
  function_name = "leadership-certificate-program-agent"
  handler       = "lambda.leadership_certificate_program_handler"
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
# Leadership Academy Agent
#############################################
resource "aws_lambda_function" "leadership_academy_agent" {
  function_name = "leadership-academy-agent"
  handler       = "lambda.leadership_academy_handler"
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
# Student Activities Leadership Agent
#############################################
resource "aws_lambda_function" "student_activities_leadership_agent" {
  function_name = "student-activities-leadership-agent"
  handler       = "lambda.student_activities_leadership_handler"
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
# College Success Leadership Agent
#############################################
resource "aws_lambda_function" "college_success_leadership_agent" {
  function_name = "college-success-leadership-agent"
  handler       = "lambda.college_success_leadership_handler"
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
# Career Success Leadership Agent
#############################################
resource "aws_lambda_function" "career_success_leadership_agent" {
  function_name = "career-success-leadership-agent"
  handler       = "lambda.career_success_leadership_handler"
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
# Social Justice / DEI Leadership Agent
#############################################
resource "aws_lambda_function" "social_justice_leadership_agent" {
  function_name = "social-justice-leadership-agent"
  handler       = "lambda.social_justice_leadership_handler"
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
# Community College Student Leadership Agent
#############################################
resource "aws_lambda_function" "cc_student_leadership_agent" {
  function_name = "cc-student-leadership-agent"
  handler       = "lambda.cc_student_leadership_handler"
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
# CC Success & Retention Agent
#############################################
resource "aws_lambda_function" "cc_success_and_retention_agent" {
  function_name = "cc-success-and-retention-agent"
  handler       = "lambda.cc_success_and_retention_handler"
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
