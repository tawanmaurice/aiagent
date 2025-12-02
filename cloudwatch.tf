########################################
# CloudWatch Events rule to trigger Lambda
########################################

resource "aws_cloudwatch_event_rule" "speaking_agent_schedule" {
  name        = "speaking-agent-schedule"
  description = "Run the speaking-agent Lambda on a schedule"
  # You can change this later to rate(1 day) or a CRON
  schedule_expression = "rate(1 day)"
}

########################################
# Event target: send the rule to the Lambda
########################################

resource "aws_cloudwatch_event_target" "speaking_agent_target" {
  rule      = aws_cloudwatch_event_rule.speaking_agent_schedule.name
  target_id = "speaking-agent-lambda"
  arn       = aws_lambda_function.speaking_agent.arn
}
