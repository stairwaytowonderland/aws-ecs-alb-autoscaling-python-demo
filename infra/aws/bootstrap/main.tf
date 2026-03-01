# https://github.com/terraform-aws-modules/terraform-aws-iam/blob/master/docs/UPGRADE-6.0.md

module "iam_github_oidc_provider" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-provider"
  version = "~> v5.60"
}

module "iam_github_oidc_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-role"
  version = "~> v5.60"

  name     = local.oidc_role_name
  subjects = local.oidc_subjects
  policies = local.oidc_policies
}

module "iam_bootstrap_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> v5.60"

  create_role = var.create_cli_role

  role_name           = local.bootstrap_role_name
  role_requires_mfa   = false
  trusted_role_arns   = [local.account_id]
  attach_admin_policy = true
  # trusted_role_actions = ["sts:AssumeRole"] # role-skip-session-tagging: true
}
