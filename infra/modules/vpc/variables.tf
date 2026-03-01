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
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  nullable    = false

  default = "10.0.0.0/8"
}

variable "azs" {
  description = "Availability zones to use"
  type        = list(string)
  nullable    = false
}

variable "ipam_pool_id" {
  description = "The ID of the IPAM pool to use for VPC CIDR allocation"
  type        = string
  default     = null
}
