output "alb_dns_name" {
  value       = aws_lb.main.dns_name
  description = "ALB DNS name"
}

output "ecr_repository_url" {
  value       = aws_ecr_repository.hippo.repository_url
  description = "ECR repository URL"
}
