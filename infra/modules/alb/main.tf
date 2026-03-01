locals {
  sg_name  = format("%s-alb-sg", var.environment)
  alb_name = format("%s-app-alb", var.environment)
  tg_name  = format("%s-app-tg", var.environment)
}

resource "aws_security_group" "alb" {
  name        = local.sg_name
  description = "Security group for the ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP traffic"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = local.sg_name
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ! Caution: Manually creating the service-linked role for EC2 ELB
# ! results in potentially long delays before the role can be deleted.
# resource "aws_iam_service_linked_role" "elb" {
#   aws_service_name = "elasticloadbalancing.amazonaws.com"
#   description      = "Allows Elastic Load Balancing to manage AWS resources on your behalf."
# }

resource "aws_lb" "app" {
  name               = local.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = local.alb_name
    # ServiceRoleArn = aws_iam_service_linked_role.elb.arn
  }
}

resource "aws_lb_target_group" "app" {
  name     = local.tg_name
  port     = 8000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    interval            = 30
    path                = var.health_check_path
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = var.health_check_timeout
    protocol            = "HTTP"
    matcher             = "200-499"
  }

  tags = {
    Name = local.tg_name
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
