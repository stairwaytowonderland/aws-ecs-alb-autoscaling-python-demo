data "aws_partition" "current" {}

data "tls_certificate" "this" {
  count = local.create || local.update ? 1 : 0

  url = var.url
}
