data "aws_cloudformation_stack" "this" {
  count = local.update || local.delete ? 1 : 0

  name = var.stack_name
}
