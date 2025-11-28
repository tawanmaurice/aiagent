########################################
# IAM role for Lambda
########################################

resource "aws_iam_role" "lambda_exec" {
  name = "speaking-agent-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

########################################
# Permissions for DynamoDB + CloudWatch Logs
########################################

# Managed policy so the Lambda can write logs to CloudWatch
resource "aws_iam_role_policy_attachment" "lambda_basic_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Inline policy so the Lambda can write to your leads table
resource "aws_iam_role_policy" "lambda_dynamodb_policy" {
  name = "speaking-agent-dynamodb-policy"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:GetItem",
          "dynamodb:BatchWriteItem"
        ]
        Resource = aws_dynamodb_table.speaking_leads.arn
      }
    ]
  })
}
