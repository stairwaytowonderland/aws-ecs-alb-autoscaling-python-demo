resource "local_file" "private_key_pem_file" {
  count = var.create_local_pem_file ? 1 : 0

  content         = local.ec2_private_key_pem
  filename        = local.ec2_private_key_pem_path
  file_permission = "0400"
}

module "dynamodb" {
  source = "../../modules/dynamodb"

  environment = var.environment
  ttl_enabled = var.dynamodb_ttl_enabled
  table_name  = var.dynamodb_table_name
  hash_key    = "CandidateName"
}

module "docker" {
  source = "../../modules/docker"

  handle_docker  = var.handle_docker
  use_local_exec = true

  force_docker_rebuild = var.force_docker_rebuild

  application_name                 = var.application_name
  docker_image_url                 = local.docker_image_url
  docker_build_context             = local.docker_build_context
  dockerfile_path                  = local.dockerfile_path
  ecr_authorization_token_endpoint = local.ecr_authorization_token_endpoint
  auth_config_username             = local.ecr_authorization_username
  auth_config_password             = local.ecr_authorization_password
  auth_config_address              = local.ecr_authorization_token_endpoint
}

module "alb" {
  source = "../../modules/alb"

  environment           = var.environment
  vpc_id                = local.vpc_id
  subnet_ids            = local.vpc_public_subnet_ids
  health_check_path     = var.health_check_path
  health_check_timeout  = var.health_check_timeout
  vpc_security_group_id = local.vpc_security_group_id
}

module "ec2_autoscaling" {
  source = "../../modules/ec2"

  create_custom_ami = var.create_custom_ami
  # ami_name_pattern  = var.create_custom_ami ? "${var.environment}-${var.application_name}-ami" : null

  environment      = var.environment
  application_name = var.application_name
  instance_type    = "t2.micro"

  ecr_config_user_name      = local.ecr_authorization_username
  docker_install_command    = var.docker_install_command
  ec2_role_name             = local.ec2_role_name
  iam_instance_profile_name = format("%v-app-instance-profile", var.environment)
  ami_id                    = local.ami_id
  security_group_id         = local.vpc_security_group_id
  subnet_ids                = local.vpc_public_subnet_ids
  docker_image_url          = local.docker_image_url
  dynamodb_table_name       = var.dynamodb_table_name
  asg_desired_capacity      = 2
  asg_min_size              = 1
  asg_max_size              = 2
  target_group_arns         = local.alb_target_group_arns

  tags = local.tags
}
