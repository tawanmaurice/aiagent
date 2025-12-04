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

######################################
# NEW AGENTS – leadership & CC focus
######################################

# 8) SGA Leadership – 13:35 UTC daily
resource "aws_cloudwatch_event_rule" "sga_leadership_daily" {
  name                = "sga-leadership-daily"
  schedule_expression = "cron(35 13 * * ? *)"
}

resource "aws_cloudwatch_event_target" "sga_leadership_target" {
  rule      = aws_cloudwatch_event_rule.sga_leadership_daily.name
  target_id = "sga-leadership-lambda"
  arn       = aws_lambda_function.sga_leadership_agent.arn
}

resource "aws_lambda_permission" "sga_leadership_events" {
  statement_id  = "AllowExecutionFromCloudWatchSGALeadership"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sga_leadership_agent.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.sga_leadership_daily.arn
}

# 9) Student Leadership Retreat – 13:40 UTC daily
resource "aws_cloudwatch_event_rule" "student_leadership_retreat_daily" {
  name                = "student-leadership-retreat-daily"
  schedule_expression = "cron(40 13 * * ? *)"
}

resource "aws_cloudwatch_event_target" "student_leadership_retreat_target" {
  rule      = aws_cloudwatch_event_rule.student_leadership_retreat_daily.name
  target_id = "student-leadership-retreat-lambda"
  arn       = aws_lambda_function.student_leadership_retreat_agent.arn
}

resource "aws_lambda_permission" "student_leadership_retreat_events" {
  statement_id  = "AllowExecutionFromCloudWatchStudentLeadershipRetreat"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.student_leadership_retreat_agent.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.student_leadership_retreat_daily.arn
}

# 10) Student Leadership Conference – 13:45 UTC daily
resource "aws_cloudwatch_event_rule" "student_leadership_conference_daily" {
  name                = "student-leadership-conference-daily"
  schedule_expression = "cron(45 13 * * ? *)"
}

resource "aws_cloudwatch_event_target" "student_leadership_conference_target" {
  rule      = aws_cloudwatch_event_rule.student_leadership_conference_daily.name
  target_id = "student-leadership-conference-lambda"
  arn       = aws_lambda_function.student_leadership_conference_agent.arn
}

resource "aws_lambda_permission" "student_leadership_conference_events" {
  statement_id  = "AllowExecutionFromCloudWatchStudentLeadershipConference"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.student_leadership_conference_agent.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.student_leadership_conference_daily.arn
}

# 11) Leadership Summit – 13:50 UTC daily
resource "aws_cloudwatch_event_rule" "leadership_summit_daily" {
  name                = "leadership-summit-daily"
  schedule_expression = "cron(50 13 * * ? *)"
}

resource "aws_cloudwatch_event_target" "leadership_summit_target" {
  rule      = aws_cloudwatch_event_rule.leadership_summit_daily.name
  target_id = "leadership-summit-lambda"
  arn       = aws_lambda_function.leadership_summit_agent.arn
}

resource "aws_lambda_permission" "leadership_summit_events" {
  statement_id  = "AllowExecutionFromCloudWatchLeadershipSummit"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.leadership_summit_agent.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.leadership_summit_daily.arn
}

# 12) Officer Training – 13:55 UTC daily
resource "aws_cloudwatch_event_rule" "officer_training_daily" {
  name                = "officer-training-daily"
  schedule_expression = "cron(55 13 * * ? *)"
}

resource "aws_cloudwatch_event_target" "officer_training_target" {
  rule      = aws_cloudwatch_event_rule.officer_training_daily.name
  target_id = "officer-training-lambda"
  arn       = aws_lambda_function.officer_training_agent.arn
}

resource "aws_lambda_permission" "officer_training_events" {
  statement_id  = "AllowExecutionFromCloudWatchOfficerTraining"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.officer_training_agent.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.officer_training_daily.arn
}

# 13) Speaker / Lyceum Series – 14:00 UTC daily
resource "aws_cloudwatch_event_rule" "speaker_series_lyceum_daily" {
  name                = "speaker-series-lyceum-daily"
  schedule_expression = "cron(0 14 * * ? *)"
}

resource "aws_cloudwatch_event_target" "speaker_series_lyceum_target" {
  rule      = aws_cloudwatch_event_rule.speaker_series_lyceum_daily.name
  target_id = "speaker-series-lyceum-lambda"
  arn       = aws_lambda_function.speaker_series_lyceum_agent.arn
}

resource "aws_lambda_permission" "speaker_series_lyceum_events" {
  statement_id  = "AllowExecutionFromCloudWatchSpeakerSeriesLyceum"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.speaker_series_lyceum_agent.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.speaker_series_lyceum_daily.arn
}

# 14) Orientation Leaders – 14:05 UTC daily
resource "aws_cloudwatch_event_rule" "orientation_leader_daily" {
  name                = "orientation-leader-daily"
  schedule_expression = "cron(5 14 * * ? *)"
}

resource "aws_cloudwatch_event_target" "orientation_leader_target" {
  rule      = aws_cloudwatch_event_rule.orientation_leader_daily.name
  target_id = "orientation-leader-lambda"
  arn       = aws_lambda_function.orientation_leader_agent.arn
}

resource "aws_lambda_permission" "orientation_leader_events" {
  statement_id  = "AllowExecutionFromCloudWatchOrientationLeader"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.orientation_leader_agent.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.orientation_leader_daily.arn
}

# 15) Res Life / RA Leadership – 14:10 UTC daily
resource "aws_cloudwatch_event_rule" "res_life_ra_leadership_daily" {
  name                = "res-life-ra-leadership-daily"
  schedule_expression = "cron(10 14 * * ? *)"
}

resource "aws_cloudwatch_event_target" "res_life_ra_leadership_target" {
  rule      = aws_cloudwatch_event_rule.res_life_ra_leadership_daily.name
  target_id = "res-life-ra-leadership-lambda"
  arn       = aws_lambda_function.res_life_ra_leadership_agent.arn
}

resource "aws_lambda_permission" "res_life_ra_leadership_events" {
  statement_id  = "AllowExecutionFromCloudWatchResLifeRALeadership"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.res_life_ra_leadership_agent.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.res_life_ra_leadership_daily.arn
}

# 16) Honors Program Leadership – 14:15 UTC daily
resource "aws_cloudwatch_event_rule" "honors_program_leadership_daily" {
  name                = "honors-program-leadership-daily"
  schedule_expression = "cron(15 14 * * ? *)"
}

resource "aws_cloudwatch_event_target" "honors_program_leadership_target" {
  rule      = aws_cloudwatch_event_rule.honors_program_leadership_daily.name
  target_id = "honors-program-leadership-lambda"
  arn       = aws_lambda_function.honors_program_leadership_agent.arn
}

resource "aws_lambda_permission" "honors_program_leadership_events" {
  statement_id  = "AllowExecutionFromCloudWatchHonorsProgramLeadership"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.honors_program_leadership_agent.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.honors_program_leadership_daily.arn
}

# 17) Leadership Certificate Programs – 14:20 UTC daily
resource "aws_cloudwatch_event_rule" "leadership_certificate_program_daily" {
  name                = "leadership-certificate-program-daily"
  schedule_expression = "cron(20 14 * * ? *)"
}

resource "aws_cloudwatch_event_target" "leadership_certificate_program_target" {
  rule      = aws_cloudwatch_event_rule.leadership_certificate_program_daily.name
  target_id = "leadership-certificate-program-lambda"
  arn       = aws_lambda_function.leadership_certificate_program_agent.arn
}

resource "aws_lambda_permission" "leadership_certificate_program_events" {
  statement_id  = "AllowExecutionFromCloudWatchLeadershipCertificateProgram"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.leadership_certificate_program_agent.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.leadership_certificate_program_daily.arn
}

# 18) Leadership Academy – 14:25 UTC daily
resource "aws_cloudwatch_event_rule" "leadership_academy_daily" {
  name                = "leadership-academy-daily"
  schedule_expression = "cron(25 14 * * ? *)"
}

resource "aws_cloudwatch_event_target" "leadership_academy_target" {
  rule      = aws_cloudwatch_event_rule.leadership_academy_daily.name
  target_id = "leadership-academy-lambda"
  arn       = aws_lambda_function.leadership_academy_agent.arn
}

resource "aws_lambda_permission" "leadership_academy_events" {
  statement_id  = "AllowExecutionFromCloudWatchLeadershipAcademy"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.leadership_academy_agent.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.leadership_academy_daily.arn
}

# 19) Student Activities Leadership – 14:30 UTC daily
resource "aws_cloudwatch_event_rule" "student_activities_leadership_daily" {
  name                = "student-activities-leadership-daily"
  schedule_expression = "cron(30 14 * * ? *)"
}

resource "aws_cloudwatch_event_target" "student_activities_leadership_target" {
  rule      = aws_cloudwatch_event_rule.student_activities_leadership_daily.name
  target_id = "student-activities-leadership-lambda"
  arn       = aws_lambda_function.student_activities_leadership_agent.arn
}

resource "aws_lambda_permission" "student_activities_leadership_events" {
  statement_id  = "AllowExecutionFromCloudWatchStudentActivitiesLeadership"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.student_activities_leadership_agent.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.student_activities_leadership_daily.arn
}

# 20) College Success Leadership – 14:35 UTC daily
resource "aws_cloudwatch_event_rule" "college_success_leadership_daily" {
  name                = "college-success-leadership-daily"
  schedule_expression = "cron(35 14 * * ? *)"
}

resource "aws_cloudwatch_event_target" "college_success_leadership_target" {
  rule      = aws_cloudwatch_event_rule.college_success_leadership_daily.name
  target_id = "college-success-leadership-lambda"
  arn       = aws_lambda_function.college_success_leadership_agent.arn
}

resource "aws_lambda_permission" "college_success_leadership_events" {
  statement_id  = "AllowExecutionFromCloudWatchCollegeSuccessLeadership"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.college_success_leadership_agent.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.college_success_leadership_daily.arn
}

# 21) Career Success Leadership – 14:40 UTC daily
resource "aws_cloudwatch_event_rule" "career_success_leadership_daily" {
  name                = "career-success-leadership-daily"
  schedule_expression = "cron(40 14 * * ? *)"
}

resource "aws_cloudwatch_event_target" "career_success_leadership_target" {
  rule      = aws_cloudwatch_event_rule.career_success_leadership_daily.name
  target_id = "career-success-leadership-lambda"
  arn       = aws_lambda_function.career_success_leadership_agent.arn
}

resource "aws_lambda_permission" "career_success_leadership_events" {
  statement_id  = "AllowExecutionFromCloudWatchCareerSuccessLeadership"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.career_success_leadership_agent.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.career_success_leadership_daily.arn
}

# 22) Social Justice / DEI Leadership – 14:45 UTC daily
resource "aws_cloudwatch_event_rule" "social_justice_leadership_daily" {
  name                = "social-justice-leadership-daily"
  schedule_expression = "cron(45 14 * * ? *)"
}

resource "aws_cloudwatch_event_target" "social_justice_leadership_target" {
  rule      = aws_cloudwatch_event_rule.social_justice_leadership_daily.name
  target_id = "social-justice-leadership-lambda"
  arn       = aws_lambda_function.social_justice_leadership_agent.arn
}

resource "aws_lambda_permission" "social_justice_leadership_events" {
  statement_id  = "AllowExecutionFromCloudWatchSocialJusticeLeadership"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.social_justice_leadership_agent.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.social_justice_leadership_daily.arn
}

# 23) CC Student Leadership (catch-all) – 14:50 UTC daily
resource "aws_cloudwatch_event_rule" "cc_student_leadership_daily" {
  name                = "cc-student-leadership-daily"
  schedule_expression = "cron(50 14 * * ? *)"
}

resource "aws_cloudwatch_event_target" "cc_student_leadership_target" {
  rule      = aws_cloudwatch_event_rule.cc_student_leadership_daily.name
  target_id = "cc-student-leadership-lambda"
  arn       = aws_lambda_function.cc_student_leadership_agent.arn
}

resource "aws_lambda_permission" "cc_student_leadership_events" {
  statement_id  = "AllowExecutionFromCloudWatchCCStudentLeadership"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cc_student_leadership_agent.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cc_student_leadership_daily.arn
}

# 24) CC Success & Retention – 14:55 UTC daily
resource "aws_cloudwatch_event_rule" "cc_success_and_retention_daily" {
  name                = "cc-success-and-retention-daily"
  schedule_expression = "cron(55 14 * * ? *)"
}

resource "aws_cloudwatch_event_target" "cc_success_and_retention_target" {
  rule      = aws_cloudwatch_event_rule.cc_success_and_retention_daily.name
  target_id = "cc-success-and-retention-lambda"
  arn       = aws_lambda_function.cc_success_and_retention_agent.arn
}

resource "aws_lambda_permission" "cc_success_and_retention_events" {
  statement_id  = "AllowExecutionFromCloudWatchCCSuccessAndRetention"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cc_success_and_retention_agent.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cc_success_and_retention_daily.arn
}
