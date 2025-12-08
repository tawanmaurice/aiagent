#########################################
# Reuse existing IAM role from main stack
#########################################

data "aws_iam_role" "lambda_exec" {
  # This is the role that already exists from your multi-agent project
  name = "speaking-agent-lambda-role-v3-multi"
}
