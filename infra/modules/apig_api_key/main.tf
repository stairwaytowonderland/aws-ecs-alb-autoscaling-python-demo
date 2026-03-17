locals {
  tags = merge(
    var.tags,
    {
      Environment = var.environment,
    },
  )

  # Suffix goes between the app name and the resource-type token so the name
  # mirrors other resource names in the project (e.g. "{env}-{app}-convert-api-key").
  key_name  = var.key_name_suffix != null ? format("%s-%s-%s-api-key", var.environment, var.application_name, var.key_name_suffix) : format("%s-%s-api-key", var.environment, var.application_name)
  plan_name = var.plan_name_suffix != null ? format("%s-%s-%s-usage-plan", var.environment, var.application_name, var.plan_name_suffix) : format("%s-%s-usage-plan", var.environment, var.application_name)

  # Resolve to the existing plan ID when provided, otherwise the newly created one.
  usage_plan_id = var.existing_usage_plan_id != null ? var.existing_usage_plan_id : one(aws_api_gateway_usage_plan.this[*]).id
}

resource "aws_api_gateway_api_key" "this" {
  name        = local.key_name
  description = var.key_description
  enabled     = true

  tags = local.tags
}

resource "aws_api_gateway_usage_plan" "this" {
  count = var.existing_usage_plan_id == null ? 1 : 0

  name        = local.plan_name
  description = var.plan_description

  quota_settings {
    limit  = var.quota_limit
    offset = 0
    period = var.quota_period
  }

  throttle_settings {
    burst_limit = var.throttle_burst_limit
    rate_limit  = var.throttle_rate_limit
  }

  api_stages {
    api_id = var.api_id
    stage  = var.stage_name
  }

  tags = local.tags
}

resource "aws_api_gateway_usage_plan_key" "this" {
  key_id        = aws_api_gateway_api_key.this.id
  key_type      = "API_KEY"
  usage_plan_id = local.usage_plan_id
}
