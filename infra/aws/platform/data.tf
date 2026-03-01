data "aws_region" "self" {}

data "aws_caller_identity" "this" {}

data "aws_ecr_authorization_token" "token" {}

data "aws_vpc_ipam_pool" "self" {
  count = var.create_ipam ? 1 : 0

  filter {
    name   = "description"
    values = ["*top level pool*"] # Use value from the IPAM module
  }

  filter {
    name   = "address-family"
    values = ["ipv4"]
  }

  # depends_on = [module.ipam]
}

data "git_commit" "current_commit" {
  directory = "../../.."
  revision  = "HEAD"
}
