data "aws_region" "current" {}

data "aws_caller_identity" "this" {}

data "aws_ecr_authorization_token" "token" {}

data "terraform_remote_state" "platform" {
  backend = "s3"
  config = {
    bucket = local.platform_state_bucket_name
    key    = "platform/terraform.tfstate"
    region = local.region_name
  }
}

data "git_commit" "current_commit" {
  directory = "../../.."
  revision  = "HEAD"
}

data "aws_instances" "running" {

  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }

  instance_state_names = ["running"]
}
