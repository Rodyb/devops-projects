provider "aws" {
  region = "eu-west-1"
}

resource "aws_dynamodb_table" "users" {
  name         = "UsersTable"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "userId"

  attribute {
    name = "userId"
    type = "S"
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "dynamodb_access" {
  name = "lambda_dynamodb_access"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["dynamodb:PutItem", "dynamodb:GetItem", "dynamodb:Scan"],
      Resource = aws_dynamodb_table.users.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_dynamo" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.dynamodb_access.arn
}

# Archive Files
data "archive_file" "create_user_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/createUser"
  output_path = "${path.module}/create_user.zip"
}

data "archive_file" "get_user_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/getUser"
  output_path = "${path.module}/get_user.zip"
}

data "archive_file" "list_users_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/listUsers"
  output_path = "${path.module}/list_users.zip"
}

resource "aws_lambda_function" "create_user" {
  function_name = "CreateUserFunction"
  role          = aws_iam_role.lambda_exec.arn
  runtime       = "nodejs14.x"
  handler       = "index.handler"

  filename         = data.archive_file.create_user_zip.output_path
  source_code_hash = data.archive_file.create_user_zip.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.users.name
    }
  }
}

resource "aws_lambda_function" "get_user" {
  function_name = "GetUserFunction"
  role          = aws_iam_role.lambda_exec.arn
  runtime       = "nodejs14.x"
  handler       = "index.handler"

  filename         = data.archive_file.get_user_zip.output_path
  source_code_hash = data.archive_file.get_user_zip.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.users.name
    }
  }
}

resource "aws_lambda_function" "list_users" {
  function_name = "ListUsersFunction"
  role          = aws_iam_role.lambda_exec.arn
  runtime       = "nodejs14.x"
  handler       = "index.handler"

  filename         = data.archive_file.list_users_zip.output_path
  source_code_hash = data.archive_file.list_users_zip.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.users.name
    }
  }
}

resource "aws_apigatewayv2_api" "http_api" {
  name          = "UserAPI"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "create_user_integration" {
  api_id             = aws_apigatewayv2_api.http_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.create_user.invoke_arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "get_user_integration" {
  api_id             = aws_apigatewayv2_api.http_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.get_user.invoke_arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "list_users_integration" {
  api_id             = aws_apigatewayv2_api.http_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.list_users.invoke_arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "create_user_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /users"
  target    = "integrations/${aws_apigatewayv2_integration.create_user_integration.id}"
}

resource "aws_apigatewayv2_route" "get_user_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /users/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.get_user_integration.id}"
}

resource "aws_apigatewayv2_route" "list_users_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /users"
  target    = "integrations/${aws_apigatewayv2_integration.list_users_integration.id}"
}

resource "aws_lambda_permission" "allow_api_create_user" {
  statement_id  = "AllowAPIGatewayInvokeCreate"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_user.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "allow_api_get_user" {
  statement_id  = "AllowAPIGatewayInvokeGet"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_user.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "allow_api_list_users" {
  statement_id  = "AllowAPIGatewayInvokeList"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.list_users.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

output "create_user_url" {
  value = "${aws_apigatewayv2_api.http_api.api_endpoint}/users"
}

output "get_user_url" {
  value = "${aws_apigatewayv2_api.http_api.api_endpoint}/users/{id}"
}

output "list_users_url" {
  value = "${aws_apigatewayv2_api.http_api.api_endpoint}/users"
}
