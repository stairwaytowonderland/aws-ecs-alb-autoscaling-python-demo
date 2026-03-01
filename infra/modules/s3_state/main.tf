locals {
  state_prefix = format("%v-%v-%v", var.environment, var.aws_region, var.application_name)
  bucket_name  = format("%s-tfstate-bucket", local.state_prefix)

  calc_bucket_id   = aws_s3_bucket.state.id
  calc_bucket_name = aws_s3_bucket.state.bucket
}

resource "aws_s3_bucket" "state" {
  bucket        = local.bucket_name
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = local.calc_bucket_id

  versioning_configuration {
    status = "Enabled"
  }
}
