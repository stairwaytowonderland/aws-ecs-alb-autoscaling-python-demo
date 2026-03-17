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

variable "application_name" {
  description = "Application name used in resource naming"
  type        = string
  nullable    = false

  validation {
    condition     = length(var.application_name) > 0
    error_message = "Application name must not be empty."
  }
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  nullable    = false

  default = {
    ManagedBy = "Terraform"
  }
}

### MODULE SPECIFIC VARIABLES ###
variable "api_id" {
  description = "ID of the API Gateway REST API to associate with the usage plan"
  type        = string
  nullable    = false

  validation {
    condition     = length(var.api_id) > 0
    error_message = "API ID must not be empty."
  }
}

variable "stage_name" {
  description = "Name of the API Gateway stage to associate with the usage plan"
  type        = string
  nullable    = false

  validation {
    condition     = length(var.stage_name) > 0
    error_message = "Stage name must not be empty."
  }
}

variable "key_name_suffix" {
  description = "Optional suffix appended before the resource-type token in the API key name (e.g. 'convert' → '{env}-{app}-convert-api-key'). If null, name is '{env}-{app}-api-key'."
  type        = string
  nullable    = true
  default     = null
}

variable "plan_name_suffix" {
  description = "Optional suffix appended before the resource-type token in the usage plan name (e.g. 'convert' → '{env}-{app}-convert-usage-plan'). If null, name is '{env}-{app}-usage-plan'."
  type        = string
  nullable    = true
  default     = null
}

variable "key_description" {
  description = "Human-readable description of the API key"
  type        = string
  nullable    = true
  default     = null
}

variable "plan_description" {
  description = "Human-readable description of the usage plan (ignored when usage_plan_id is set)"
  type        = string
  nullable    = true
  default     = null
}

variable "usage_plan_id" {
  description = "ID of an existing usage plan to associate the key with. When set, no new usage plan is created."
  type        = string
  nullable    = true
  default     = null
}

variable "quota_limit" {
  description = "Maximum number of requests allowed in the quota period (ignored when usage_plan_id is set)"
  type        = number
  nullable    = false
  default     = 10
}

variable "quota_period" {
  description = "Period for the quota limit: DAY, WEEK, or MONTH (ignored when usage_plan_id is set)"
  type        = string
  nullable    = false
  default     = "MONTH"

  validation {
    condition     = contains(["DAY", "WEEK", "MONTH"], var.quota_period)
    error_message = "quota_period must be one of: DAY, WEEK, MONTH."
  }
}

variable "throttle_burst_limit" {
  description = "Maximum request burst size (token-bucket capacity) (ignored when usage_plan_id is set)"
  type        = number
  nullable    = false
  default     = 5
}

variable "throttle_rate_limit" {
  description = "Steady-state request rate limit in requests per second (ignored when usage_plan_id is set)"
  type        = number
  nullable    = false
  default     = 10
}
