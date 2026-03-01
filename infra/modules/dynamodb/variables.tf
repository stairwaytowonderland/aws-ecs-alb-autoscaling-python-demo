### STANDARD MODULE VARIABLES ###
variable "environment" {
  description = "Environment name (e.g., dev, nonprod, prod)"
  type        = string
  nullable    = false
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
variable "ttl_enabled" {
  description = "Enable Time to Live (TTL) for the DynamoDB table."
  type        = bool
  nullable    = false

  default = false
}

variable "table_name" {
  description = "The name of the DynamoDB table."
  type        = string
  nullable    = false

  validation {
    condition     = length(var.table_name) > 0
    error_message = "Table name must not be empty."
  }
}

variable "hash_key" {
  description = "The partition key for the DynamoDB table."
  type        = string
  nullable    = false

  validation {
    condition     = length(var.hash_key) > 0
    error_message = "Hash key must not be empty."
  }
}
