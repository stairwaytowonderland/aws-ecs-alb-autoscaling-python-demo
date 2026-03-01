output "client_id_list" {
  description = "List of client IDs for the OIDC provider"
  value       = local.client_id_list
}

output "thumbprint_list" {
  description = "List of thumbprints for the OIDC provider"
  value       = local.thumbprint_list
}

# output "cloudformation_stack_id" {
#   description = "ID of the CloudFormation stack"
#   value       = aws_cloudformation_stack.bootstrap.id
# }

# output "cloudformation_oidc_provider_arn" {
#   description = "ARN of the OIDC provider from CloudFormation"
#   value       = aws_cloudformation_stack.bootstrap.outputs["OIDCProviderArn"]
# }

# output "cloudformation_oidc_role_arn" {
#   description = "ARN of the OIDC role from CloudFormation"
#   value       = aws_cloudformation_stack.bootstrap.outputs["OIDCRoleArn"]
# }
