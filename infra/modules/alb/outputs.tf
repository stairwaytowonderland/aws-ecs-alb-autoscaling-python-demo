output "alb_id" {
  description = "The ID of the Application Load Balancer"
  value       = aws_lb.app.id
}

output "alb_arn" {
  description = "The ARN of the Application Load Balancer"
  value       = aws_lb.app.arn
}

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_lb.app.dns_name
}

output "alb_zone_id" {
  description = "The zone ID of the Application Load Balancer"
  value       = aws_lb.app.zone_id
}

output "target_group_arn" {
  description = "The ARN of the Target Group"
  value       = aws_lb_target_group.app.arn
}

output "target_group_name" {
  description = "The name of the Target Group"
  value       = aws_lb_target_group.app.name
}

output "security_group_id" {
  description = "The ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = local.vpc_cidr_block
}
