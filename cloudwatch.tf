#########################
# CloudWatch schedules
#########################

# 1) SGA Agent schedule
resource "aws_cloudwatch_event_rule" "sga_agent_schedule" {
  name                = "sga-agent-schedule"
  schedule_expression = "rate(1 day)"
}

resource "aws_cloudwatch_event_target" "sga_agent_target" {
  rule      = aws_cloudwatch_event_rule.sga_agent_schedule.name
  target_id = "sga-agent"
  arn       = aws_lambda_function.sga_agent.arn
}

resource "aws_lambda_permission" "sga_agent_cwe" {
  statement_id  = "AllowExecutionFromCloudWatchSGA"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sga_agent.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.sga_agent_schedule.arn
}

# 2) Orientation Agent schedule
resource "aws_cloudwatch_event_rule" "orientation_agent_schedule" {
  name                = "orientation-agent-schedule"
  schedule_expression = "rate(1 day)"
}

resource "aws_cloudwatch_event_target" "orientation_agent_target" {
  rule      = aws_cloudwatch_event_rule.orientation_agent_schedule.name
  target_id = "orientation-agent"
  arn       = aws_lambda_function.orientation_agent.arn
}

resource "aws_lambda_permission" "orientation_agent_cwe" {
  statement_id  = "AllowExecutionFromCloudWatchOrientation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.orientation_agent.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.orientation_agent_schedule.arn
}

# 3) Leadership Conference Agent schedule
resource "aws_cloudwatch_event_rule" "leadership_conference_agent_schedule" {
  name                = "leadership-conference-agent-schedule"
  schedule_expression = "rate(1 day)"
}

resource "aws_cloudwatch_event_target" "leadership_conference_agent_target" {
  rule      = aws_cloudwatch_event_rule.leadership_conference_agent_schedule.name
  target_id = "leadership-conference-agent"
  arn       = aws_lambda_function.leadership_conference_agent.arn
}

resource "aws_lambda_permission" "leadership_conference_agent_cwe" {
  statement_id  = "AllowExecutionFromCloudWatchLeadershipConf"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.leadership_conference_agent.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.leadership_conference_agent_schedule.arn
}

# 4) Activities Agent schedule
resource "aws_cloudwatch_event_rule" "activities_agent_schedule" {
  name                = "activities-agent-schedule"
  schedule_expression = "rate(1 day)"
}

resource "aws_cloudwatch_event_target" "activities_agent_target" {
  rule      = aws_cloudwatch_event_rule.activities_agent_schedule.name
  target_id = "activities-agent"
  arn       = aws_lambda_function.activities_agent.arn
}

resource "aws_lambda_permission" "activities_agent_cwe" {
  statement_id  = "AllowExecutionFromCloudWatchActivities"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.activities_agent.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.activities_agent_schedule.arn
}
