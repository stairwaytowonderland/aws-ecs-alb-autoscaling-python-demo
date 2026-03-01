locals {
  create = var.mode == "create" && (var.enabled && !var.file_only)
  update = var.mode == "update" && (var.enabled && !var.file_only)
  delete = var.mode == "delete" || !var.enabled

  template_body = templatefile(
    var.filename,
    var.template_vars
  )

  template_path = replace(var.filename, "yaml.tftpl", "auto.yaml")
}

resource "local_file" "cloudformation" {
  count = var.enabled ? 1 : 0

  content  = local.template_body
  filename = local.template_path
}

resource "null_resource" "stack" {
  count = local.create || local.update ? 1 : 0

  # Terminate the base instance after AMI is created
  provisioner "local-exec" {
    command = <<-EOF
    aws cloudformation ${local.create ? "create-stack" : "update-stack"} \
      --stack-name ${var.stack_name} \
      --template-body file://${one(local_file.cloudformation[*]).filename} \
      ${trimspace(var.cloudformation)} \
      --region ${var.aws_region}
    EOF
  }
}

resource "null_resource" "delete" {
  count = local.delete ? 1 : 0

  # Terminate the base instance after AMI is created
  provisioner "local-exec" {
    command = <<-EOF
    aws cloudformation delete-stack \
      --stack-name ${one(data.aws_cloudformation_stack.this[*]).name} \
      --region ${var.aws_region}
    EOF
  }
}
