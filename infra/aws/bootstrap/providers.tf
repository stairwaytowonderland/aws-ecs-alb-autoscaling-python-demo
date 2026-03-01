provider "aws" {
  region = var.aws_region

  default_tags {
    tags = merge(
      local.tags,
      {
        ManagedBy = "Terraform"
      }
    )
  }
}
