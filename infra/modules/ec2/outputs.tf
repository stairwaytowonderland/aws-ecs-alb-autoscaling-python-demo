output "ami_id" {
  description = "ID of the AMI"
  value       = local.ami_id
}

output "ami_name" {
  description = "Name of the AMI"
  value       = local.ami_name
}

output "iam_instance_profile_name" {
  description = "Name of the IAM instance profile for EC2 instances"
  value       = var.base_ami ? local.iam_instance_profile_name : null
}

output "asg_name" {
  description = "Name of the autoscaling group"
  value       = var.base_ami ? null : one(aws_autoscaling_group.app[*]).name
}

output "asg_id" {
  description = "ID of the autoscaling group"
  value       = var.base_ami ? null : one(aws_autoscaling_group.app[*]).id
}

output "launch_template_id" {
  description = "ID of the launch template"
  value       = var.base_ami ? null : one(aws_launch_template.app[*]).id
}

output "ec2_private_key_pem" {
  value     = var.base_ami ? null : one(tls_private_key.ec2[*]).private_key_pem
  sensitive = true
}
