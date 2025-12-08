##########################################
# CloudWatch Event Rule for Truck-ESL    #
# Single daily run for truck_esl_agent   #
##########################################

# NOTE: cron format: cron(Minutes Hours Day-of-month Month Day-of-week Year)
# Times are in UTC. 13:00 UTC ≈ 8:00 AM Eastern (standard time).

resource "aws_cloudwatch_event_rule" "truck_esl_daily" {
  name                = "truck-esl-agent-daily"
  description         = "Daily run of the Truck ESL multi-agent scraper"
  schedule_expression = "cron(0 13 * * ? *)"
}

resource "aws_cloudwatch_event_target" "truck_esl_target" {
  rule      = aws_cloudwatch_event_rule.truck_esl_daily.name
  target_id = "truck-esl-agent-lambda"
  arn       = aws_lambda_function.truck_esl_agent.arn
}

resource "aws_lambda_permission" "truck_esl_events" {
  statement_id  = "AllowExecutionFromCloudWatchTruckESL"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.truck_esl_agent.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.truck_esl_daily.arn
}
