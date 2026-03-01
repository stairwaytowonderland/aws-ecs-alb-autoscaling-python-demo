### STANDARD MODULE VARIABLES ###
variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  nullable    = false

  validation {
    condition     = length(var.aws_region) > 0
    error_message = "AWS region must not be empty."
  }
}

variable "environment" {
  description = "Environment name (e.g., dev, nonprod, prod)"
  type        = string
  nullable    = false

  validation {
    condition     = length(var.environment) > 0
    error_message = "Environment name must not be empty."
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
variable "force_destroy" {
  description = "Whether to force destroy the S3 bucket and DynamoDB table"
  type        = bool
  default     = false
  nullable    = false
}
