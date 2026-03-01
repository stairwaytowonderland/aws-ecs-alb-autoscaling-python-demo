locals {
  tags = merge(merge(
    var.required_tags,
    {
      Environment = var.environment,
      App         = var.application_name,
    },
  ), var.additional_tags)

  region_name = data.aws_region.current.region
  account_id  = data.aws_caller_identity.this.account_id

  dynamodb_ttl       = module.dynamodb.ttl
  dynamodb_table_arn = module.dynamodb.table_arn

  ecr_authorization_token_endpoint = data.aws_ecr_authorization_token.token.proxy_endpoint
  ecr_authorization_username       = data.aws_ecr_authorization_token.token.user_name
  ecr_authorization_password       = data.aws_ecr_authorization_token.token.authorization_token
  ecr_hostname                     = replace(local.ecr_authorization_token_endpoint, "https://", "")

  ecr_address    = format("%v.dkr.ecr.%v.amazonaws.com", local.account_id, local.region_name)
  ecr_image_name = format("%v/%v:%v", local.ecr_address, var.application_name, local.commit_hash)

  docker_build_context = var.docker_build_context
  dockerfile_path      = format("%v/%v", var.docker_build_context, var.dockerfile_path_rel)

  src_hash   = module.docker.src_hash
  src_hashes = module.docker.src_hashes
  src_files  = module.docker.src_files

  alb_target_group_arns = [module.alb.target_group_arn]
  asg_name              = module.ec2_autoscaling.asg_name
  app_url               = format("http://%v", module.alb.alb_dns_name)
  alb_dns_name          = module.alb.alb_dns_name
  ec2_private_key_pem   = var.create_local_pem_file ? module.ec2_autoscaling.ec2_private_key_pem : null
  ec2_instance_ids      = length(data.aws_instances.running.ids) > 0 ? data.aws_instances.running.ids : null

  ec2_private_key_pem_file = "ec2-connect.pem"
  ec2_private_key_pem_dir  = format("%v/../../..", path.cwd)
  ec2_private_key_pem_path = var.create_local_pem_file ? format("%v/%v", local.ec2_private_key_pem_dir, local.ec2_private_key_pem_file) : null

  ami_id                = data.terraform_remote_state.platform.outputs.ami_id
  vpc_id                = data.terraform_remote_state.platform.outputs.vpc_id
  vpc_public_subnet_ids = data.terraform_remote_state.platform.outputs.public_subnet_ids
  vpc_security_group_id = data.terraform_remote_state.platform.outputs.vpc_security_group_id
  ec2_role_name         = data.terraform_remote_state.platform.outputs.ec2_role_name

  docker_image_url        = var.assume_ecr_repository ? local.ecr_image_name : format("%v:%v", data.terraform_remote_state.platform.outputs.ecr_repository_url, local.commit_hash)
  module_docker_image_tag = module.docker.docker_image_url
  commit_hash             = data.git_commit.current_commit.sha1

  platform_state_bucket_name = format("%v-%v-%v-tfstate-bucket", var.environment, local.region_name, var.application_name)
}
