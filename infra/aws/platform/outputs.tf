output "public_subnet_ids" {
  description = "Map of public subnet IDs"
  value       = local.vpc_public_subnet_ids
}

output "public_subnet_ids_json" {
  description = "Map of public subnet IDs"
  value       = jsonencode(local.vpc_public_subnet_ids)
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = local.vpc_id
}

output "vpc_security_group_id" {
  description = "The ID of the VPC security group"
  value       = local.vpc_security_group_id
}

output "ami_id" {
  description = "ID of the AMI"
  value       = local.ami_id
}

output "iam_instance_profile_name" {
  description = "Name of the IAM instance profile"
  value       = local.iam_instance_profile_name
}

output "ec2_role_name" {
  description = "Name of the EC2 role"
  value       = local.aws_iam_role_ec2_role_name
}

output "ecr_username" {
  description = "Username for ECR authentication"
  value       = local.ecr_authorization_username
}
