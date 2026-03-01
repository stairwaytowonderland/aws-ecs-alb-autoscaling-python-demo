module "ecr" {
  source = "../../modules/ecr"

  environment     = var.environment
  repository_name = var.application_name
  force_delete    = true
}

module "vpc" {
  source = "../../modules/vpc"

  environment  = var.environment
  vpc_cidr     = local.vpc_cidr
  azs          = local.availability_zones
  ipam_pool_id = local.ipam_pool_id
}

module "ec2_ami" {
  source = "../../modules/ec2"

  base_ami          = true
  create_custom_ami = var.create_custom_ami

  environment      = var.environment
  application_name = var.application_name

  ami_name_pattern = var.ami_name_pattern
  ec2_role_name    = local.ec2_role_name

  docker_install_command = var.docker_install_command

  security_group_id = local.vpc_security_group_id
  subnet_ids        = local.vpc_public_subnet_ids
}
