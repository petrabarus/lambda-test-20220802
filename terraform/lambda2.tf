resource "aws_iam_role" "lambda2_iam_role" {
  name = "lambda2_iam_role"
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


resource "aws_iam_role_policy" "lambda2_iam_role_logging" {
  name = "lambda2_iam_role_logging"
  role = aws_iam_role.lambda2_iam_role.id

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



resource "aws_lambda_function" "lambda2_func" {
  filename      = "dist/lambda2.zip"
  function_name = "lambda_test_lambda2"
  role          = aws_iam_role.lambda2_iam_role.arn
  handler       = "main"

  source_code_hash = filebase64sha256("dist/lambda2.zip")

  runtime = "go1.x"
}

resource "aws_cloudwatch_log_group" "lambda2_func_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda2_func.function_name}"
  retention_in_days = 30
}

resource "aws_apigatewayv2_api" "lambda2_apigw" {
  name          = "lambda2_apigw"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "lambda2_apigw_stage" {
  api_id = aws_apigatewayv2_api.lambda2_apigw.id

  name        = "prod"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "lambda2_apigw_integration" {
  api_id = aws_apigatewayv2_api.lambda2_apigw.id

  integration_uri    = aws_lambda_function.lambda2_func.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "lambda2_apigw_route" {
  api_id = aws_apigatewayv2_api.lambda2_apigw.id

  route_key = "GET /hello"
  target    = "integrations/${aws_apigatewayv2_integration.lambda2_apigw_integration.id}"
}


resource "aws_lambda_permission" "lambda2_apigw_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda2_func.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda2_apigw.execution_arn}/*/*"
}

resource "aws_cloudwatch_log_group" "lambda2_apigw_log" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.lambda2_apigw.name}"

  retention_in_days = 30
}

output "lambda2_arn" {
  value = aws_lambda_function.lambda2_func.arn
}

output "lambda2_url" {
  value = aws_apigatewayv2_stage.lambda2_apigw_stage.invoke_url
}
