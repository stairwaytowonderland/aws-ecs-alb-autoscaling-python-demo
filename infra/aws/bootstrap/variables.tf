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
variable "role_name_prefix" {
  description = "Prefix for IAM role names"
  type        = string
  nullable    = false

  default = "ci-provision"
}

variable "oidc_subjects" {
  description = "List of subjects for the OIDC roles, typically GitHub or GitLab repository references"
  type        = list(string)
  nullable    = false

  validation {
    condition     = length(var.oidc_subjects) > 0
    error_message = "OIDC subjects must not be empty."
  }
}

variable "oidc_policy_map" {
  description = "Map of policy arns for oidc role"
  type        = map(string)
  nullable    = false

  default = {
    ReadOnlyAccess = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  }
}

variable "create_cli_role" {
  description = "Whether to create a cli role"
  type        = bool
  nullable    = false

  default = false
}
