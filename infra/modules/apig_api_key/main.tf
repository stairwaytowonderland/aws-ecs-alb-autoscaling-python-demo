locals {
  tags = merge(
    var.tags,
    {
      Environment = var.environment,
    },
  )

  # When regenerate_key=true, embed the random hex so a keeper change forces a name change,
  # which in turn forces replacement of the API key (name is ForceNew).
  key_name = var.regenerate_key ? format("%s-%s-api-key-%s", var.environment, var.application_name, random_id.key.keepers.key_name_suffix) : (
    var.key_name_suffix != null ? format("%s-%s-api-key-%s", var.environment, var.application_name, var.key_name_suffix) : format("%s-%s-api-key", var.environment, var.application_name)
  )
  plan_name = var.plan_name_suffix != null ? format("%s-%s-%s-usage-plan", var.environment, var.application_name, var.plan_name_suffix) : format("%s-%s-usage-plan", var.environment, var.application_name)

  # Resolve to the existing plan ID when provided, otherwise the newly created one.
  usage_plan_id = var.usage_plan_id != null ? var.usage_plan_id : one(aws_api_gateway_usage_plan.this[*]).id
}

# Create a random_id resource because lifecycle replace_triggered_by does not support referencing a variable directly.
resource "random_id" "key" {
  byte_length = 8

  keepers = {
    key_name_suffix = var.regenerate_key ? var.key_name_suffix : null
    usage_plan_id   = var.regenerate_key ? (var.usage_plan_id != null ? var.usage_plan_id : one(aws_api_gateway_usage_plan.this[*]).id) : null
  }
}

resource "aws_api_gateway_api_key" "this" {
  name        = local.key_name
  description = var.key_description
  enabled     = true

  lifecycle {
    replace_triggered_by = [random_id.key]
  }

  tags = local.tags
}

# State migration: api key was previously count-based.
moved {
  from = aws_api_gateway_api_key.this[0]
  to   = aws_api_gateway_api_key.this
}

resource "aws_api_gateway_usage_plan" "this" {
  count = var.usage_plan_id == null ? 1 : 0

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
