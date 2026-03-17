# All API Gateway REST API (protocol: REST) resources and methods are defined in this file.
# The API Gateway is configured to integrate with the ALB using HTTP proxy integration, so there are no Lambda functions or other backend integrations defined here.

locals {
  apig_name = format("%s-%s-apig", var.environment, var.application_name)
}

# -----------------------------------------------------------------------------
# REST API
# -----------------------------------------------------------------------------
resource "aws_api_gateway_rest_api" "this" {
  name        = local.apig_name
  description = "REST API Gateway for ${var.application_name} (${var.environment}) - HTTP proxy integration with ALB"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = local.tags
}

# -----------------------------------------------------------------------------
# Resources
# -----------------------------------------------------------------------------

resource "aws_api_gateway_resource" "gtg" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "gtg"
}

resource "aws_api_gateway_resource" "swagger" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "swagger"
}

# Catch-all proxy resource scoped to /swagger only
resource "aws_api_gateway_resource" "swagger_proxy" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.swagger.id
  path_part   = "{proxy+}"
}

# -----------------------------------------------------------------------------
# Methods
# -----------------------------------------------------------------------------

resource "aws_api_gateway_method" "root" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_rest_api.this.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "gtg" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.gtg.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "swagger" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.swagger.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "swagger_proxy" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.swagger_proxy.id
  http_method   = "ANY"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

# -----------------------------------------------------------------------------
# Integrations (HTTP proxy -> ALB)
# -----------------------------------------------------------------------------

resource "aws_api_gateway_integration" "root" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_rest_api.this.root_resource_id
  http_method             = aws_api_gateway_method.root.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = "http://${local.alb_dns_name}/"
}

resource "aws_api_gateway_integration" "gtg" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.gtg.id
  http_method             = aws_api_gateway_method.gtg.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = "http://${local.alb_dns_name}/gtg"
}

resource "aws_api_gateway_integration" "swagger" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.swagger.id
  http_method             = aws_api_gateway_method.swagger.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = "http://${local.alb_dns_name}/swagger"

  # Inject the API Gateway stage name so the app can build correct asset URLs.
  request_parameters = {
    "integration.request.header.X-Forwarded-Prefix" = "context.stage"
  }
}

resource "aws_api_gateway_integration" "swagger_proxy" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.swagger_proxy.id
  http_method             = aws_api_gateway_method.swagger_proxy.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = "http://${local.alb_dns_name}/swagger/{proxy}"

  request_parameters = {
    "integration.request.path.proxy"                = "method.request.path.proxy"
    "integration.request.header.X-Forwarded-Prefix" = "context.stage"
  }
}

# -----------------------------------------------------------------------------
# Deployment & Stage
# -----------------------------------------------------------------------------

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  # Redeploy whenever any method or integration changes
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.gtg,
      aws_api_gateway_resource.swagger,
      aws_api_gateway_resource.swagger_proxy,
      aws_api_gateway_method.root,
      aws_api_gateway_method.gtg,
      aws_api_gateway_method.swagger,
      aws_api_gateway_method.swagger_proxy,
      aws_api_gateway_integration.root,
      aws_api_gateway_integration.gtg,
      aws_api_gateway_integration.swagger,
      aws_api_gateway_integration.swagger_proxy,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.root,
    aws_api_gateway_integration.gtg,
    aws_api_gateway_integration.swagger,
    aws_api_gateway_integration.swagger_proxy,
  ]
}

resource "aws_api_gateway_stage" "this" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  deployment_id = aws_api_gateway_deployment.this.id
  stage_name    = var.environment

  tags = local.tags
}
