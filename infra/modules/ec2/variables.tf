### STANDARD MODULE VARIABLES ###
variable "environment" {
  description = "Environment name (e.g., dev, nonprod, prod)"
  type        = string
  nullable    = false

  validation {
    condition     = length(var.environment) > 0
    error_message = "Environment name must not be empty."
  }
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  nullable    = false

  default = {
    ManagedBy = "Terraform"
  }

  validation {
    condition     = length(var.tags) > 0
    error_message = "Tags must not be empty."
  }
}

variable "application_name" {
  description = "Name of the application"
  type        = string
  nullable    = false

  validation {
    condition     = length(var.application_name) > 0
    error_message = "Application name must not be empty."
  }
}

### MODULE SPECIFIC VARIABLES ###
variable "ami_name_pattern" {
  description = "The AMI name pattern for the search filter"
  type        = string
  nullable    = false

  default = "al2023-ami-*-kernel-6.1-x86_64"

  validation {
    condition     = length(var.ami_name_pattern) > 0
    error_message = "AMI name pattern must not be empty."
  }
}

variable "ami_id" {
  description = "AMI ID to use for the EC2 instances"
  type        = string
  default     = null

  validation {
    condition     = var.ami_id != null ? length(var.ami_id) > 0 : true
    error_message = "AMI ID must not be empty."
  }
}

variable "iam_instance_profile_name" {
  description = "Name of the created IAM instance profile for EC2 instances"
  type        = string
  default     = null

  validation {
    condition     = var.iam_instance_profile_name != null ? length(var.iam_instance_profile_name) > 0 : true
    error_message = "IAM instance profile name must not be empty."
  }
}

variable "docker_image_url" {
  description = "URL of the Docker image"
  type        = string
  default     = null

  validation {
    condition     = var.docker_image_url != null ? length(var.docker_image_url) > 0 : true
    error_message = "Docker image URL must not be empty."
  }
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  type        = string
  default     = null

  validation {
    condition     = var.dynamodb_table_name != null ? length(var.dynamodb_table_name) > 0 : true
    error_message = "DynamoDB table name must not be empty."
  }
}

variable "target_group_arns" {
  description = "List of target group ARNs for the Auto Scaling Group"
  type        = list(string)
  default     = null

  validation {
    condition     = var.target_group_arns != null ? length(var.target_group_arns) > 0 : true
    error_message = "Target group ARNs must not be empty."
  }
}

variable "base_ami" {
  description = "Flag to determine if module is in base AMI creation/retrieval mode"
  type        = bool
  nullable    = false

  default = false
}

variable "create_custom_ami" {
  description = "Flag to create a custom AMI for the EC2 instances"
  type        = bool
  nullable    = false

  default = false
}

variable "force_new_ami" {
  description = "Force creation of a new AMI with timestamp"
  type        = bool
  nullable    = false

  default = false
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  nullable    = false

  default = "t2.micro" # Free tier eligible

  validation {
    condition     = length(var.instance_type) > 0
    error_message = "Instance type must not be empty."
  }
}

variable "ec2_role_name" {
  description = "Name of the IAM role for EC2 instances"
  type        = string

  validation {
    condition     = length(var.ec2_role_name) > 0
    error_message = "EC2 role name must not be empty."
  }
}

variable "security_group_id" {
  description = "Security group ID for the EC2 instances"
  type        = string
  nullable    = false

  validation {
    condition     = length(var.security_group_id) > 0
    error_message = "Security group ID must not be empty."
  }
}

variable "subnet_ids" {
  description = "List of subnet IDs for the autoscaling group"
  type        = list(string)
  nullable    = false

  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "Subnet IDs must not be empty."
  }
}

variable "docker_install_command" {
  description = "The Docker install command"
  type        = string
  nullable    = false

  default = "yum install -y docker" # "amazon-linux-extras install docker -y"

  validation {
    condition     = length(var.docker_install_command) > 0
    error_message = "Docker install command must not be empty."
  }
}

variable "asg_min_size" {
  description = "Minimum size of the Auto Scaling Group"
  type        = number
  nullable    = false

  default = 1

  validation {
    condition     = var.asg_min_size > 0
    error_message = "Minimum size must be a positive integer."
  }
}

variable "asg_max_size" {
  description = "Maximum size of the Auto Scaling Group"
  type        = number
  nullable    = false

  default = 2

  validation {
    condition     = var.asg_max_size >= var.asg_min_size
    error_message = "Maximum size must be greater than or equal to minimum size."
  }
}

variable "asg_desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group"
  type        = number
  nullable    = false

  default = 1

  validation {
    condition     = var.asg_desired_capacity >= var.asg_min_size && var.asg_desired_capacity <= var.asg_max_size
    error_message = "Desired capacity must be between minimum and maximum size."
  }
}

variable "ecr_config_user_name" {
  description = "Username for ECR authentication"
  type        = string
  nullable    = false

  default = "AWS"

  validation {
    condition     = length(var.ecr_config_user_name) > 0
    error_message = "ECR config username must not be empty."
  }
}
