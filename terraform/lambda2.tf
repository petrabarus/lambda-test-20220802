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

resource "aws_api_gateway_rest_api" "lambda2_api" {
  name = "lambda2_api"
}

resource "aws_api_gateway_resource" "lambda2_api_resource" {
  path_part   = "resource"
  parent_id   = aws_api_gateway_rest_api.lambda2_api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.lambda2_api.id
}

resource "aws_api_gateway_method" "lambda2_api_get" {
  rest_api_id   = aws_api_gateway_rest_api.lambda2_api.id
  resource_id   = aws_api_gateway_resource.lambda2_api_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda2_api_integration" {
  rest_api_id             = aws_api_gateway_rest_api.lambda2_api.id
  resource_id             = aws_api_gateway_resource.lambda2_api_resource.id
  http_method             = aws_api_gateway_method.lambda2_api_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda2_func.invoke_arn
}

resource "aws_lambda_permission" "lambda2_apigw_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda2_func.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.lambda2_api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "lambda2_api_deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda2_api_integration,
  ]

  rest_api_id = aws_api_gateway_rest_api.lambda2_api.id
  stage_name  = "prod"
}

output "lambda2_arn" {
  value = aws_lambda_function.lambda2_func.arn
}

output "lambda2_url" {
  value = "${aws_api_gateway_deployment.lambda2_api_deployment.invoke_url}resource"
}
