output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.website.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.website.arn
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.website.id
}

output "cloudfront_distribution_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.website.domain_name
}

output "cloudfront_custom_domain" {
  description = "Custom domain for the CloudFront distribution"
  value       = format("hippo-cloudfront-%s.%s", var.environment, var.domain_name)
}

output "route53_zone_id" {
  description = "ID of the Route53 hosted zone"
  value       = local.public_hosted_zone_id
}

output "route53_zone_name" {
  description = "Name of the Route53 hosted zone"
  value       = var.domain_name
}

output "nameservers" {
  description = "The nameservers for the Route53 zone"
  value       = var.create_route53_hosted_zone ? aws_route53_zone.public_hosted_zone[0].name_servers : data.aws_route53_zone.public_hosted_zone[0].name_servers
}

output "certificate_validation_records" {
  description = "The DNS records needed for certificate validation"
  value = {
    for dvo in aws_acm_certificate.cloudfront.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
}
