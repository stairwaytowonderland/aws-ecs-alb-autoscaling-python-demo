locals {
  stack_name = "terraform-backend-${var.environment}"

  create = var.mode == "create"
  update = var.mode == "update"
  delete = var.mode == "delete"

  template_vars = {
    environment      = var.environment
    application_name = var.application_name
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
      ParameterKey=Owner,ParameterValue="${var.owner_name}"
  CLOUDFORMATION

  mode       = var.mode
  aws_region = var.aws_region
}
