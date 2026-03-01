output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_attributes.id
}

output "public_subnet_ids_by_az" {
  description = "List of public subnet IDs"
  value       = { for az, subnet in module.vpc.public_subnet_attributes_by_az : az => subnet.id }
}

output "security_group_id" {
  description = "ID of the application security group"
  value       = aws_security_group.app.id
}
