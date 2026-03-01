locals {
  tags = merge(merge(
    var.required_tags,
    {
      Environment = var.environment,
      App         = var.application_name,
    },
  ), var.additional_tags)

  region_name = data.aws_region.self.region
  account_id  = data.aws_caller_identity.this.account_id

  availability_zones = [for az in ["a", "b"] : "${local.region_name}${az}"]

  ipam_pool_id          = var.create_ipam ? data.aws_vpc_ipam_pool.self[0].id : null
  vpc_cidr              = var.top_cidr
  vpc_public_subnet_ids = values(module.vpc.public_subnet_ids_by_az)
  vpc_security_group_id = module.vpc.security_group_id
  vpc_id                = module.vpc.vpc_id

  ec2_role_name              = format("%s-ec2-role", var.environment)
  aws_iam_role_ec2_role_name = aws_iam_role.ec2_role.name
  ecr_config_user_name       = data.aws_ecr_authorization_token.token.user_name
  iam_instance_profile_name  = module.ec2_ami.iam_instance_profile_name
  ami_id                     = module.ec2_ami.ami_id

  ecr_authorization_token_endpoint = data.aws_ecr_authorization_token.token.proxy_endpoint
  ecr_authorization_username       = data.aws_ecr_authorization_token.token.user_name
  ecr_authorization_password       = data.aws_ecr_authorization_token.token.authorization_token
}
