resource "aws_apigatewayv2_api" "self" {
  name          = "${var.environment}-${var.application_name}-http-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "self" {
  api_id      = aws_apigatewayv2_api.self.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "self" {
  api_id           = aws_apigatewayv2_api.self.id
  integration_type = "HTTP_PROXY"

  integration_method = "ANY"
  integration_uri    = "${local.app_url}/{proxy}"
}

resource "aws_apigatewayv2_route" "self" {
  api_id    = aws_apigatewayv2_api.self.id
  route_key = "ANY /{proxy+}"

  target = "integrations/${aws_apigatewayv2_integration.self.id}"
}
