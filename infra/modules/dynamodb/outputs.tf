output "ttl" {
  description = "The Time to Live (TTL) attribute for the DynamoDB table"
  value       = local.ttl
}

output "table_name" {
  description = "Name of the DynamoDB table"
  value       = local.table_name
}

output "table_arn" {
  description = "ARN of the DynamoDB table"
  value       = local.table_arn
}
