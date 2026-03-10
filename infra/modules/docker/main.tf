locals {
  dockerfile_hash = filemd5(var.dockerfile_path)

  # Define exclusions list
  exclude_patterns = [
    "__pycache__",
    ".venv",
    ".git",
    ".pytest_cache",
    "*.pyc",
    "*.pyo",
    "*.log",
    ".DS_Store"
  ]
  # Create regex pattern from exclusions
  exclusion_regex = join("|", [for pattern in local.exclude_patterns : replace(replace(pattern, "*", ".*"), ".", "\\.")])
  src_files = [
    for f in sort(fileset(var.docker_build_context, "src/**")) :
    f if !can(regex(local.exclusion_regex, f))
  ]

  src_raw    = [for f in local.src_files : format("%v/%v", var.docker_build_context, f)]
  src_hashes = [for f in local.src_files : filesha1(format("%v/%v", var.docker_build_context, f))]
  src_hash   = sha1(join("", local.src_hashes))

  docker_image_hostname = split("/", var.docker_image_url)[0]

  default_triggers = {
    tag_version     = var.docker_image_url
    force_rebuild   = var.force_docker_rebuild ? timestamp() : null
    dockerfile_hash = local.dockerfile_hash
    src_hash        = local.src_hash
  }
}

# build docker image
resource "docker_image" "app" {
  count = var.use_local_exec ? 0 : (var.handle_docker ? 1 : 0)

  name = var.docker_image_url

  build {
    context    = var.docker_build_context
    dockerfile = var.dockerfile_path
    builder    = "default"
    # tag        = ["${var.docker_image_url}"]
    no_cache = true
    labels = {
      dir_sha1 = local.src_hash
    }
  }

  platform = "linux/amd64" # "linux/arm64"

  triggers = local.default_triggers
}

# push image to ecr repo
resource "docker_registry_image" "handler" {
  count = var.use_local_exec ? 0 : (var.handle_docker ? 1 : 0)

  name          = docker_image.app[count.index].name
  keep_remotely = false

  auth_config {
    address  = var.auth_config_address
    username = var.auth_config_username
    password = var.auth_config_password
  }

  triggers = local.default_triggers
}

# Build and push docker image using null resource
resource "null_resource" "docker_build_push" {
  count = var.use_local_exec && var.handle_docker ? 1 : 0

  provisioner "local-exec" {
    command = <<-EOF
      # Login to ECR
      aws ecr get-login-password --region ${data.aws_region.current.region} | docker login --username ${var.auth_config_username} --password-stdin ${local.docker_image_hostname}

      # Build the image -- Handled by docker_image.app
      # docker build --no-cache --platform linux/amd64,linux/arm64 -t ${var.application_name} -f ${var.dockerfile_path} ${var.docker_build_context}
      docker build --no-cache --platform linux/amd64 -t ${var.application_name} -f ${var.dockerfile_path} ${var.docker_build_context}

      # Tag image -- Handled by docker_image.app
      docker tag ${var.application_name} ${var.docker_image_url}

      # Push to ECR
      docker push ${var.docker_image_url}
    EOF
  }

  triggers = merge(local.default_triggers, {
    image_id = var.use_local_exec ? null : docker_image.app[count.index].image_id
  })
}
