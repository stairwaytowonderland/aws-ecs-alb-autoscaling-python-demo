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

variable "client_id_list" {
  description = "List of client IDs (also known as audiences) for the IAM OIDC provider. Defaults to STS service if not values are provided"
  type        = list(string)
  default     = []
}

variable "url" {
  description = "The URL of the identity provider. Corresponds to the iss claim"
  type        = string
  default     = "https://token.actions.githubusercontent.com"
}

variable "additional_thumbprints" {
  description = "List of additional thumbprints to add to the thumbprint list."
  type        = list(string)
  # https://github.blog/changelog/2023-06-27-github-actions-update-on-oidc-integration-with-aws/
  default = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]
}

variable "repo_owner" {
  description = "The GitHub organization or user account that owns the repository"
  type        = string
  nullable    = false
}

variable "repo_name" {
  description = "The name of the GitHub repository"
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
