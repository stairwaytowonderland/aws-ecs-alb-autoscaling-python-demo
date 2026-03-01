locals {
  tags = merge(merge(
    var.required_tags,
    {
      Environment = var.environment,
      App         = var.application_name,
    },
  ), var.additional_tags)
  region_name         = data.aws_region.self.region
  oidc_subjects       = var.oidc_subjects
  oidc_policies       = var.oidc_policy_map
  oidc_role_name      = "${var.role_name_prefix}-oidc-${var.application_name}"
  bootstrap_role_name = "${var.role_name_prefix}-bootstrap-${var.application_name}"
  account_id          = data.aws_caller_identity.self.account_id

  calc_oidc_role_name = module.iam_github_oidc_role.name
  calc_oidc_role_arn  = module.iam_github_oidc_role.arn

  calc_bootstrap_role_name = var.create_cli_role ? module.iam_bootstrap_role.iam_role_name : null
  calc_bootstrap_role_arn  = var.create_cli_role ? module.iam_bootstrap_role.iam_role_arn : null

  roles = { for k, v in {
    oidc = {
      name = local.calc_oidc_role_name
      arn  = local.calc_oidc_role_arn
    }
    bootstrap = var.create_cli_role ? {
      name = local.calc_bootstrap_role_name
      arn  = local.calc_bootstrap_role_arn
    } : null
  } : k => v if v != null }
}
