locals {
  vpc_name            = format("%s-vpc", var.environment)
  security_group_name = format("%s-app-sg", var.environment)
}

module "vpc" {
  source  = "aws-ia/vpc/aws"
  version = "~> 4.5"

  name       = format("%s-vpc", var.environment)
  cidr_block = var.vpc_cidr
  az_count   = 2

  # Use IPAM pool ID if provided
  vpc_ipv4_ipam_pool_id = var.ipam_pool_id

  subnets = {
    public = {
      name_prefix = format("%s-public", var.environment)
      # cidrs                     = [for i in range(2) : cidrsubnet(var.vpc_cidr, 8, i)]
      netmask = 28
      tags = {
        Type = "Public"
      }
    }
  }

  # Enable internet gateway for public access
  vpc_enable_dns_hostnames = true
  vpc_enable_dns_support   = true
}

# Security group for the EC2 instance
resource "aws_security_group" "app" {
  name        = local.security_group_name
  description = "Security group for the candidate app"
  vpc_id      = module.vpc.vpc_attributes.id

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_attributes.cidr_block]
    description = "Allow HTTP traffic on port 8000"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = local.security_group_name
  }

  lifecycle {
    create_before_destroy = true
  }
}
