output "api_key_id" {
  description = "ID of the API key (retrieve value with: aws apigateway get-api-key --api-key <id> --include-value)"
  value       = aws_api_gateway_api_key.this.id
}

output "api_key_name" {
  description = "Name of the API key"
  value       = aws_api_gateway_api_key.this.name
}

output "usage_plan_id" {
  description = "ID of the usage plan (existing or newly created)"
  value       = local.usage_plan_id
}

output "usage_plan_name" {
  description = "Name of the newly created usage plan (null when usage_plan_id is provided)"
  value       = var.usage_plan_id == null ? one(aws_api_gateway_usage_plan.this[*]).name : null
}
