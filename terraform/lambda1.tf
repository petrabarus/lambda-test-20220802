resource "aws_iam_role" "lambda1_iam_role" {
  name = "lambda1_iam_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda1_iam_role_logging" {
  name = "lambda1_iam_role_logging"
  role = aws_iam_role.lambda1_iam_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:logs:*:*:*"
        ]
      },
    ]
  })
}

resource "aws_lambda_function" "lambda1_func" {
  filename      = "dist/lambda1.zip"
  function_name = "lambda_test_lambda1"
  role          = aws_iam_role.lambda1_iam_role.arn
  handler       = "main"

  source_code_hash = filebase64sha256("dist/lambda1.zip")

  runtime = "go1.x"
}

resource "aws_cloudwatch_log_group" "lambda1_func_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda1_func.function_name}"
  retention_in_days = 30
}

output "lambda1_arn" {
  value = aws_lambda_function.lambda1_func.arn
}
