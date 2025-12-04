######################################
# CLOUDWATCH EVENT RULES + TARGETS
######################################

# NOTE: cron format: cron(Minutes Hours Day-of-month Month Day-of-week Year)
# These are all UTC times.

# 1) Student Athlete – 13:00 UTC daily
resource "aws_cloudwatch_event_rule" "student_athlete_daily" {
  name                = "student-athlete-leadership-daily"
  schedule_expression = "cron(0 13 * * ? *)"
}

resource "aws_cloudwatch_event_target" "student_athlete_target" {
  rule      = aws_cloudwatch_event_rule.student_athlete_daily.name
  target_id = "student-athlete-lambda"
  arn       = aws_lambda_function.student_athlete_leadership_agent.arn
}

resource "aws_lambda_permission" "student_athlete_events" {
  statement_id  = "AllowExecutionFromCloudWatchStudentAthlete"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.student_athlete_leadership_agent.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.student_athlete_daily.arn
}

# 2) Men of Color – 13:05 UTC daily
resource "aws_cloudwatch_event_rule" "men_of_color_daily" {
  name                = "men-of-color-initiative-daily"
  schedule_expression = "cron(5 13 * * ? *)"
}

resource "aws_cloudwatch_event_target" "men_of_color_target" {
  rule      = aws_cloudwatch_event_rule.men_of_color_daily.name
  target_id = "men-of-color-lambda"
  arn       = aws_lambda_function.men_of_color_initiative_agent.arn
}

resource "aws_lambda_permission" "men_of_color_events" {
  statement_id  = "AllowExecutionFromCloudWatchMenOfColor"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.men_of_color_initiative_agent.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.men_of_color_daily.arn
}

# 3) First Gen – 13:10 UTC daily
resource "aws_cloudwatch_event_rule" "first_gen_daily" {
  name                = "first-gen-student-success-daily"
  schedule_expression = "cron(10 13 * * ? *)"
}

resource "aws_cloudwatch_event_target" "first_gen_target" {
  rule      = aws_cloudwatch_event_rule.first_gen_daily.name
  target_id = "first-gen-lambda"
  arn       = aws_lambda_function.first_gen_student_success_agent.arn
}

resource "aws_lambda_permission" "first_gen_events" {
  statement_id  = "AllowExecutionFromCloudWatchFirstGen"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.first_gen_student_success_agent.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.first_gen_daily.arn
}

# 4) Multicultural Center – 13:15 UTC daily
resource "aws_cloudwatch_event_rule" "multicultural_center_daily" {
  name                = "multicultural-center-leadership-daily"
  schedule_expression = "cron(15 13 * * ? *)"
}

resource "aws_cloudwatch_event_target" "multicultural_center_target" {
  rule      = aws_cloudwatch_event_rule.multicultural_center_daily.name
  target_id = "multicultural-center-lambda"
  arn       = aws_lambda_function.multicultural_center_leadership_agent.arn
}

resource "aws_lambda_permission" "multicultural_center_events" {
  statement_id  = "AllowExecutionFromCloudWatchMulticulturalCenter"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.multicultural_center_leadership_agent.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.multicultural_center_daily.arn
}

# 5) Service Learning / Civic – 13:20 UTC daily
resource "aws_cloudwatch_event_rule" "service_learning_daily" {
  name                = "service-learning-civic-engagement-daily"
  schedule_expression = "cron(20 13 * * ? *)"
}

resource "aws_cloudwatch_event_target" "service_learning_target" {
  rule      = aws_cloudwatch_event_rule.service_learning_daily.name
  target_id = "service-learning-lambda"
  arn       = aws_lambda_function.service_learning_civic_engagement_agent.arn
}

resource "aws_lambda_permission" "service_learning_events" {
  statement_id  = "AllowExecutionFromCloudWatchServiceLearning"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.service_learning_civic_engagement_agent.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.service_learning_daily.arn
}

# 6) HS Student Council – 13:25 UTC daily
resource "aws_cloudwatch_event_rule" "hs_student_council_daily" {
  name                = "hs-student-council-leadership-daily"
  schedule_expression = "cron(25 13 * * ? *)"
}

resource "aws_cloudwatch_event_target" "hs_student_council_target" {
  rule      = aws_cloudwatch_event_rule.hs_student_council_daily.name
  target_id = "hs-student-council-lambda"
  arn       = aws_lambda_function.hs_student_council_leadership_agent.arn
}

resource "aws_lambda_permission" "hs_student_council_events" {
  statement_id  = "AllowExecutionFromCloudWatchHSStudentCouncil"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hs_student_council_leadership_agent.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.hs_student_council_daily.arn
}

# 7) Summer Bridge / Orientation – 13:30 UTC daily
resource "aws_cloudwatch_event_rule" "summer_bridge_daily" {
  name                = "summer-bridge-orientation-daily"
  schedule_expression = "cron(30 13 * * ? *)"
}

resource "aws_cloudwatch_event_target" "summer_bridge_target" {
  rule      = aws_cloudwatch_event_rule.summer_bridge_daily.name
  target_id = "summer-bridge-lambda"
  arn       = aws_lambda_function.summer_bridge_orientation_agent.arn
}

resource "aws_lambda_permission" "summer_bridge_events" {
  statement_id  = "AllowExecutionFromCloudWatchSummerBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.summer_bridge_orientation_agent.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.summer_bridge_daily.arn
}
