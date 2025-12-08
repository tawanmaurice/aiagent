#########################################
# Reuse existing DynamoDB table
#########################################

data "aws_dynamodb_table" "speaking_leads" {
  # Existing table created by the main speaking-leads project
  name = "speaking-leads-v3-multi"
}
