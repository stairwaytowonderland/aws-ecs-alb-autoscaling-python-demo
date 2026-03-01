output "repository_url" {
  description = "The URL of the repository"
  value       = local.aws_ecr_repository_app_url
}

output "repository_name" {
  description = "The name of the repository"
  value       = local.aws_ecr_repository_app_name
}
