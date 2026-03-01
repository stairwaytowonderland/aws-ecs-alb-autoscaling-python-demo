module "dynamodb" {
  source = "../../modules/dynamodb"

  for_each = local.configs

  environment = var.environment
  table_name  = each.value.table_name
  hash_key    = "LockID"
  tags        = each.value.tags
}

module "s3_state" {
  source = "../../modules/s3_state"

  aws_region       = local.region_name
  environment      = var.environment
  application_name = var.application_name
  force_destroy    = var.s3_force_destroy
}

# resource "local_file" "backend_config" {
#   for_each = local.backend_configs

#   content = <<-S3BACKEND
#   terraform {
#     # backend "s3" {}
#     # TF_CLI_ARGS_init: "-backend-config 'bucket=$TF_VAR_tf_state_bucket' -backend-config 'region=$TF_VAR_aws_region' -backend-config 'key=$TF_VAR_tf_state_bucket_key' -input=false"
#     backend "s3" {
#       region         = "${each.value.region}"
#       bucket         = "${each.value.bucket}"
#       key            = "${each.value.key}"
#       dynamodb_table = "${each.value.dynamodb_table}"
#       encrypt        = true
#     }
#   }
#   S3BACKEND

#   filename = each.value.filename
# }

resource "local_file" "backend_config" {
  for_each = var.manage_backend_file ? local.backend_configs : {}

  content = <<-S3BACKEND
  terraform {
    backend "s3" {}
  }
  S3BACKEND

  filename = each.value.filename
}

resource "local_file" "backend_config_vars" {
  for_each = local.backend_configs_vars

  content = <<-S3BACKEND
  region         = "${each.value.region}"
  bucket         = "${each.value.bucket}"
  key            = "${each.value.key}"
  dynamodb_table = "${each.value.dynamodb_table}"
  encrypt        = true
  S3BACKEND

  filename = each.value.filename_config
}
