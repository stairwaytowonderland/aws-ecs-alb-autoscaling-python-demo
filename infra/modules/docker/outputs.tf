output "src_hash" {
  description = "Combined hash of the source files used for building the Docker image"
  value       = local.src_hash
}

output "src_hashes" {
  description = "List of separate hashes of the source files used for building the Docker image"
  value       = local.src_hashes
}

output "src_files" {
  description = "List of the source files used for building the Docker image"
  value       = local.src_files
}

output "docker_image_url" {
  description = "URL for the Docker image"
  value       = var.docker_image_url
}

output "docker_registry_address" {
  description = "Address of the Docker registry"
  value       = var.handle_docker ? (var.use_local_exec ? null : docker_registry_image.handler[0].auth_config[*].address) : null
}
