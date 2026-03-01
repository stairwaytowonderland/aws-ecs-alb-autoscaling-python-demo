### STANDARD PARENT MODULE VARIABLES ###
variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  nullable    = false
}

variable "environment" {
  description = "Environment name (e.g., dev, nonprod, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "nonprod", "prod"], var.environment)
    error_message = "Environment must be one of 'dev', 'nonprod', or 'prod'."
  }
}

variable "required_tags" {
  description = "Tags that must be applied to all resources"
  type = object({
    # These tags are here for convenience, and should be merged with the local calculated tags
    ManagedBy   = optional(string, "Terraform")
    Owner       = optional(string, null)
    App         = optional(string, null)
    Environment = optional(string, null)
  })

  default = {}
}

variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(any)
  default     = {}
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
variable "create_ipam" {
  description = "Flag to create the IPAM module"
  type        = bool
  default     = false
}

variable "docker_install_command" {
  description = "The Docker install command"
  type        = string
  default     = "yum install -y docker" # "amazon-linux-extras install docker -y"
}

variable "assume_ecr_repository" {
  description = "Flag to use an ECR repository for Docker images"
  type        = bool
  nullable    = false

  default = true
}

variable "force_new_ami" {
  default = null # Boolean requires null to force module default
}

variable "create_custom_ami" {
  default = null # Boolean requires null to force module default
}

variable "top_cidr" {}

variable "dynamodb_table_name" {}

variable "ami_name_pattern" {}
