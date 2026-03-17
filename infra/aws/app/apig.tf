# All API Gateway (REST API) resources are defined in this file.
# The API Gateway is configured to integrate with the ALB using HTTP proxy integration.

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

resource "aws_api_gateway_resource" "convert" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "convert"
}

resource "aws_api_gateway_resource" "convert_docx" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.convert.id
  path_part   = "docx"
}

resource "aws_api_gateway_resource" "convert_pdf" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.convert.id
  path_part   = "pdf"
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

resource "aws_api_gateway_method" "convert_docx" {
  rest_api_id      = aws_api_gateway_rest_api.this.id
  resource_id      = aws_api_gateway_resource.convert_docx.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_method" "convert_pdf" {
  rest_api_id      = aws_api_gateway_rest_api.this.id
  resource_id      = aws_api_gateway_resource.convert_pdf.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = true
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

resource "aws_api_gateway_integration" "convert_docx" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.convert_docx.id
  http_method             = aws_api_gateway_method.convert_docx.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "POST"
  uri                     = "http://${local.alb_dns_name}/convert/docx"
}

resource "aws_api_gateway_integration" "convert_pdf" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.convert_pdf.id
  http_method             = aws_api_gateway_method.convert_pdf.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "POST"
  uri                     = "http://${local.alb_dns_name}/convert/pdf"
}

# -----------------------------------------------------------------------------
# API Key & Usage Plan
# -----------------------------------------------------------------------------

resource "aws_api_gateway_api_key" "convert" {
  name        = format("%s-%s-convert-api-key", var.environment, var.application_name)
  description = "API key for /convert endpoints"
  enabled     = true

  tags = local.tags
}

resource "aws_api_gateway_usage_plan" "convert" {
  name        = format("%s-%s-convert-usage-plan", var.environment, var.application_name)
  description = "Usage plan for /convert endpoints"

  api_stages {
    api_id = aws_api_gateway_rest_api.this.id
    stage  = aws_api_gateway_stage.this.stage_name
  }

  tags = local.tags
}

resource "aws_api_gateway_usage_plan_key" "convert" {
  key_id        = aws_api_gateway_api_key.convert.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.convert.id
}



resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  # Redeploy whenever any method or integration changes
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.gtg,
      aws_api_gateway_resource.swagger,
      aws_api_gateway_resource.swagger_proxy,
      aws_api_gateway_resource.convert,
      aws_api_gateway_resource.convert_docx,
      aws_api_gateway_resource.convert_pdf,
      aws_api_gateway_method.root,
      aws_api_gateway_method.gtg,
      aws_api_gateway_method.swagger,
      aws_api_gateway_method.swagger_proxy,
      aws_api_gateway_method.convert_docx,
      aws_api_gateway_method.convert_pdf,
      aws_api_gateway_integration.root,
      aws_api_gateway_integration.gtg,
      aws_api_gateway_integration.swagger,
      aws_api_gateway_integration.swagger_proxy,
      aws_api_gateway_integration.convert_docx,
      aws_api_gateway_integration.convert_pdf,
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
    aws_api_gateway_integration.convert_docx,
    aws_api_gateway_integration.convert_pdf,
  ]
}

resource "aws_api_gateway_stage" "this" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  deployment_id = aws_api_gateway_deployment.this.id
  stage_name    = var.environment

  tags = local.tags
}
