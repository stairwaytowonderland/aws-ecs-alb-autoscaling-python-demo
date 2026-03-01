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
variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
  nullable    = false

  validation {
    condition     = length(var.repository_name) > 0
    error_message = "ECR repository name must not be empty."
  }
}

variable "force_delete" {
  description = "Flag to force delete the ECR repository"
  type        = bool
  nullable    = false

  default = false
}
