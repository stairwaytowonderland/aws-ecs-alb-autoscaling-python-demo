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
variable "s3_state_key_name" {
  description = "The Terraform state file name"
  type        = string
  default     = "terraform.tfstate"
}

variable "s3_force_destroy" {
  description = "Whether to force destroy the S3 bucket"
  type        = bool
  default     = false
}

variable "backend_filename" {
  description = "The filename for the backend configuration"
  type        = string
  default     = "backend.auto.tf"
}

variable "backend_vars_suffix" {
  description = "The filename suffix for the backend configuration vars"
  type        = string
  default     = "auto.backend"
}

variable "backends" {
  description = "Map of backend configurations for different environments"
  type        = map(string)
  default     = {}
}

variable "manage_backend_file" {
  description = "Whether to manage the backend tf configuration file"
  type        = bool
  default     = false
}
