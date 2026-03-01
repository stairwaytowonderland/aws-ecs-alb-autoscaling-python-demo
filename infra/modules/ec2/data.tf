data "aws_region" "current" {}

data "aws_ami" "base" {
  count = var.base_ami ? (var.ami_id == null ? 1 : 0) : 0

  most_recent = true
  owners      = ["amazon"]

  filter {
    name = "name"
    # values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    # values = ["al2023-ami-*-kernel-6.12-x86_64"]
    # values = ["al2023-ami-*-kernel-6.1-x86_64"]
    values = [var.ami_name_pattern]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "aws_ami" "this" {
  count = var.ami_id != null ? 1 : 0

  filter {
    name   = "image-id"
    values = [var.ami_id]
  }
}
