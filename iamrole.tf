#############################################
# IAM ROLE FOR MULTI AGENT LAMBDA FUNCTIONS
#############################################

resource "aws_iam_role" "lambda_exec" {
  name = "speaking-agent-lambda-role-v3-multi"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

#############################################
# BASIC LAMBDA LOGGING POLICY
#############################################

resource "aws_iam_role_policy_attachment" "lambda_basic_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

#############################################
# DYNAMODB READ/WRITE ACCESS
#############################################

resource "aws_iam_role_policy" "lambda_dynamodb_policy" {
  name = "lambda-dynamodb-policy-v3-multi"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Resource = [
          # IMPORTANT:
          # You MUST update the table name in dynamo.tf before apply
          # Example below assumes: speaking-leads-v3-multi
          "arn:aws:dynamodb:*:*:table/speaking-leads-v3-multi"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}
