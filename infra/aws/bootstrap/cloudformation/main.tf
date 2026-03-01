locals {
  stack_name = "terraform-bootstrap-${var.environment}"

  create = var.mode == "create"
  update = var.mode == "update"
  delete = var.mode == "delete"

  client_id_list  = !local.delete ? coalescelist(var.client_id_list, ["sts.${data.aws_partition.current.dns_suffix}"]) : []
  thumbprint_list = !local.delete ? distinct(concat(one(data.tls_certificate.this[*]).certificates[*].sha1_fingerprint, var.additional_thumbprints)) : []

  template_vars = {
    client_id_list   = local.client_id_list
    thumbprint_list  = local.thumbprint_list
    environment      = var.environment
    application_name = var.application_name
    role_name_prefix = var.role_name_prefix
    github_owner     = var.repo_owner
    github_repo      = var.repo_name
    create_cli_role  = false
    owner            = var.owner_name
  }

  template_file = "${path.module}/${var.filename}"
}

module "cloudformation" {
  source = "../../../modules/cloudformation"

  # file_only = true

  stack_name       = local.stack_name
  application_name = var.application_name
  owner_name       = var.owner_name

  filename      = local.template_file
  template_vars = local.template_vars

  cloudformation = <<-CLOUDFORMATION
    --parameters \
      ParameterKey=Environment,ParameterValue=${var.environment} \
      ParameterKey=ApplicationName,ParameterValue=${var.application_name} \
      ParameterKey=RoleNamePrefix,ParameterValue=${var.role_name_prefix} \
      ParameterKey=RepositoryOwner,ParameterValue=${var.repo_owner} \
      ParameterKey=RepositoryName,ParameterValue=${var.repo_name} \
      ParameterKey=CreateCLIRole,ParameterValue=false \
      ParameterKey=Owner,ParameterValue="${var.owner_name}" \
    --capabilities CAPABILITY_NAMED_IAM
  CLOUDFORMATION

  mode       = var.mode
  aws_region = var.aws_region
}
