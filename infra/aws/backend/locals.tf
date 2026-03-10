locals {
  tags = merge(merge(
    var.required_tags,
    {
      Environment = var.environment,
      App         = var.application_name,
    },
  ), var.additional_tags)

  region_name = data.aws_region.self.region

  configs = { for k, v in var.backends : k => {
    purpose           = k
    filename          = "${path.module}/${v}/${var.backend_filename}"
    table_name        = "${var.environment}-${local.region_name}-${var.application_name}-${k}-tfstate-lock"
    s3_state_key_name = "${k}/${var.s3_state_key_name}"

    tags = {
      Environment = var.environment,
      Purpose     = k,
    }
  } }

  s3_state_bucket_name   = module.s3_state.bucket_name
  s3_state_key_names     = { for k, v in local.configs : k => v.s3_state_key_name }
  state_lock_table_names = { for k, v in module.dynamodb : k => v.table_name }

  backend_configs = { for k, v in local.configs : k => {
    filename       = v.filename
    region         = "${local.region_name}"
    bucket         = "${local.s3_state_bucket_name}"
    key            = "${v.s3_state_key_name}"
    dynamodb_table = "${module.dynamodb[k].table_name}"
    encrypt        = true
  } }

  backend_vars_suffix = "env/${var.environment}-${local.region_name}.${var.application_name}.${var.backend_vars_suffix}"

  backend_configs_vars = { for k, v in local.backend_configs : k => merge(v, {
    filename_config = var.manage_backend_file ? "${path.module}/${dirname(local_file.backend_config[k].filename)}/${local.backend_vars_suffix}" : "${path.module}/${dirname(local.backend_configs[k].filename)}/${local.backend_vars_suffix}"
  }) }
}
