locals {
  aws_ecr_repository_app_name = aws_ecr_repository.app.name
  aws_ecr_repository_app_url  = aws_ecr_repository.app.repository_url
}

resource "aws_ecr_repository" "app" {
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE" # It's easier to deal with MUTABLE tags for now

  image_scanning_configuration {
    scan_on_push = true
  }

  force_delete = var.force_delete

  tags = {
    Name = format("%s-%s", var.environment, var.repository_name)
  }
}

resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 5 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 5
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
