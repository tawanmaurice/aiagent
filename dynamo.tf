resource "aws_dynamodb_table" "speaking_leads" {
  name         = "speaking-leads"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Project = "speaking-agent"
  }
}