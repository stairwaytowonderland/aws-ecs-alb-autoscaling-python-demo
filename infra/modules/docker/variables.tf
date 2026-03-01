### STANDARD MODULE VARIABLES ###
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
variable "handle_docker" {
  description = "Whether to provision any docker resources"
  type        = bool
  nullable    = false

  default = false
}

variable "use_local_exec" {
  description = "Use local-exec provisioner for Docker build and push"
  type        = bool
  nullable    = false

  default = false
}

variable "docker_image_url" {
  description = "URL of the Docker image"
  type        = string
  nullable    = false

  validation {
    condition     = length(var.docker_image_url) > 0
    error_message = "Docker image URL must not be empty."
  }
}

variable "force_docker_rebuild" {
  description = "Force Docker image rebuild"
  type        = bool
  nullable    = false

  default = false
}

variable "docker_build_context" {
  description = "Path to the Docker build context"
  type        = string
  nullable    = false

  default = "."

  validation {
    condition     = length(var.docker_build_context) > 0
    error_message = "Docker build context must not be empty."
  }
}

variable "dockerfile_path" {
  description = "Path to the Dockerfile"
  type        = string
  nullable    = false

  default = "Dockerfile"

  validation {
    condition     = length(var.dockerfile_path) > 0
    error_message = "Dockerfile path must not be empty."
  }
}

### DOCKER PROVIDER VARIABLES ###
variable "ecr_authorization_token_endpoint" {
  description = "Endpoint for ECR authorization token"
  type        = string
  nullable    = false

  validation {
    condition     = length(var.ecr_authorization_token_endpoint) > 0
    error_message = "ECR authorization token endpoint must not be empty."
  }
}

variable "auth_config_address" {
  description = "Address for Docker registry authentication"
  type        = string
  nullable    = false

  validation {
    condition     = length(var.auth_config_address) > 0
    error_message = "Docker registry authentication address must not be empty."
  }
}

variable "auth_config_username" {
  description = "Username for Docker registry authentication"
  type        = string
  nullable    = false

  validation {
    condition     = length(var.auth_config_username) > 0
    error_message = "Docker registry authentication username must not be empty."
  }
}

variable "auth_config_password" {
  description = "Password for Docker registry authentication"
  type        = string
  nullable    = false

  validation {
    condition     = length(var.auth_config_password) > 0
    error_message = "Docker registry authentication password must not be empty."
  }
}
