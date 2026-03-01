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

### MODULE SPECIFIC VARIABLES ###
variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string

  validation {
    condition     = length(var.vpc_id) > 0
    error_message = "VPC ID must not be empty."
  }
}

variable "vpc_security_group_id" {
  description = "Security group ID for the EC2 instances"
  type        = string

  validation {
    condition     = length(var.vpc_security_group_id) > 0
    error_message = "VPC security group ID must not be empty."
  }
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ALB"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "Subnet IDs must not be empty."
  }
}

variable "health_check_path" {
  description = "The path for the ALB health check"
  type        = string
  default     = "/"

  validation {
    condition     = length(var.health_check_path) > 0
    error_message = "Health check path must not be empty."
  }
}

variable "health_check_timeout" {
  description = "Timeout for the ALB health check in seconds"
  type        = number
  default     = 5

  validation {
    condition     = var.health_check_timeout > 0
    error_message = "Health check timeout must be a positive integer."
  }
}
