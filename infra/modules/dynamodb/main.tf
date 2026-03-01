locals {
  tags = merge(
    var.tags,
    {
      Environment = var.environment,
    },
  )

  ttl        = aws_dynamodb_table.table.ttl
  table_name = aws_dynamodb_table.table.name
  table_arn  = aws_dynamodb_table.table.arn
}

resource "aws_dynamodb_table" "table" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = var.hash_key

  attribute {
    name = var.hash_key
    type = "S"
  }

  dynamic "ttl" {
    for_each = var.ttl_enabled ? [1] : []
    content {
      # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table#attribute_name
      attribute_name = "TimeToExist"
      enabled        = true
    }
  }

  lifecycle {
    ignore_changes = [
      ttl
    ]
  }

  tags = local.tags
}
