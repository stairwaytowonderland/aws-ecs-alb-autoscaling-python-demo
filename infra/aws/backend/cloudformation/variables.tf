variable "mode" {
  description = "Mode of operation: create, update, or delete the CloudFormation stack"
  type        = string
  default     = "create"

  validation {
    condition     = contains(["create", "update", "delete"], var.mode)
    error_message = "Mode must be one of 'create', 'update', or 'delete'."
  }
}

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

variable "application_name" {
  description = "Name of the application"
  type        = string
  nullable    = false

  validation {
    condition     = length(var.application_name) > 0
    error_message = "Application name must not be empty."
  }
}

variable "role_name_prefix" {
  description = "Prefix for IAM role names"
  type        = string
  nullable    = false

  default = "ci-provision"
}

variable "owner_name" {
  description = "Name of the owner of the resources"
  type        = string
  default     = ""
  nullable    = false
}

variable "filename" {
  description = "The CloudFormation template filename"
  type        = string
  default     = ""
}
