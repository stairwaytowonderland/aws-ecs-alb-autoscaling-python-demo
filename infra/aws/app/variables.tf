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
variable "create_custom_ami" {
  description = "Flag to create a custom AMI for EC2 instances"
  type        = bool
  nullable    = false

  default = false
}

variable "create_local_pem_file" {
  description = "Flag to create a local PEM file for EC2 access"
  type        = bool
  nullable    = false

  default = false
}

variable "assume_ecr_repository" {
  description = "Flag to use an ECR repository for Docker images"
  type        = bool
  nullable    = false

  default = true
}

variable "docker_install_command" {
  description = "The Docker install command"
  type        = string
  default     = "yum install -y docker" # "amazon-linux-extras install docker -y"
}

variable "dynamodb_ttl_enabled" {
  default = null # Boolean requires null to force module default
}

variable "dynamodb_table_name" {}

variable "handle_docker" {
  default = null # Boolean requires null to force module default
}

variable "force_docker_rebuild" {
  default = null # Boolean requires null to force module default
}

variable "docker_build_context" {}

variable "dockerfile_path_rel" {}

variable "health_check_path" {}

variable "health_check_timeout" {}

variable "apig_usage_plan_quota_limit" {
  description = "The maximum number of requests that can be made in a given period"
  type        = number
  default     = 10
}

variable "apig_usage_plan_quota_period" {
  description = "The period for the usage plan quota (e.g., DAY, WEEK, MONTH)"
  type        = string
  default     = "MONTH"
}

variable "apig_usage_plan_throttle_burst_limit" {
  description = "The maximum number of requests that can be made in a short period"
  type        = number
  default     = 5
}

variable "apig_usage_plan_throttle_rate_limit" {
  description = "The maximum number of requests per second"
  type        = number
  default     = 10
}
