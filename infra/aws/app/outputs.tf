output "ami_id" {
  description = "ID of the AMI used for EC2 instances"
  value       = local.ami_id
}

output "vpc_id" {
  description = "ID of the VPC used for EC2 instances"
  value       = local.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC used for EC2 instances"
  value       = module.alb.vpc_cidr_block
}

output "src_hash" {
  description = "Combined hash of the source files used for building the Docker image"
  value       = local.src_hash
}

output "src_hashes" {
  description = "List of separate hashes of the source files used for building the Docker image"
  value       = local.src_hashes
}

output "src_files" {
  description = "List of the source files used for building the Docker image"
  value       = local.src_files
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = local.alb_dns_name
}

output "app_url" {
  description = "URL to access the application via the load balancer"
  value       = local.app_url
}

output "ec2_private_key_pem" {
  description = "PEM-encoded private key for EC2 instances"
  value       = local.ec2_private_key_pem
  sensitive   = true
}

output "ec2_private_key_pem_path" {
  description = "Path to the EC2 private key PEM file"
  value       = local.ec2_private_key_pem_path
}

output "apig_id" {
  description = "ID of the API Gateway REST API"
  value       = aws_api_gateway_rest_api.this.id
}

output "apig_invoke_url" {
  description = "Invoke URL for the API Gateway stage"
  value       = aws_api_gateway_stage.this.invoke_url
}

output "commit_hash" {
  description = "Git commit hash used for the Docker image tag"
  value       = local.commit_hash
}

output "ecr_image_tag" {
  description = "Docker image tag used in ECR"
  value       = local.module_docker_image_tag
}

output "ephemeral_instance_ids" {
  description = "List of currently running instance IDs (ephemeral) in the specified VPC"
  value       = local.ec2_instance_ids
}
