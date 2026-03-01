variable "enabled" {
  description = "Whether to enable the CloudFormation stack operation"
  type        = bool
  default     = true
}

variable "file_only" {
  description = "If true, only create the CloudFormation template file without deploying the stack"
  type        = bool
  default     = false
}

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

variable "stack_name" {
  description = "The name of the CloudFormation stack"
  type        = string
  nullable    = false
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

variable "cloudformation" {
  description = "Additional CloudFormation as a string"
  type        = string
  default     = ""
}

variable "template_vars" {
  description = "Map of variables to pass to the CloudFormation template"
  type        = any
  default     = {}

  validation {
    condition     = can(var.template_vars)
    error_message = "template_vars must be a map of variables."
  }
}
