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
  description = "Custom domain for the CloudFront distribution, if enabled"
  value       = var.use_custom_domain ? format("hippo-cloudfront-%s.%s", var.environment, var.domain) : "Not configured - using CloudFront default domain"
}

output "route53_zone_id" {
  description = "ID of the Route53 hosted zone"
  value       = aws_route53_zone.website.zone_id
}

output "route53_zone_name" {
  description = "Name of the Route53 hosted zone"
  value       = aws_route53_zone.website.name
}

output "nameservers" {
  description = "The nameservers for the Route53 zone - update these in your GoDaddy domain configuration"
  value       = aws_route53_zone.website.name_servers
}

output "certificate_validation_records" {
  description = "The DNS records needed for certificate validation (can be created manually in GoDaddy if needed)"
  value = var.use_custom_domain ? {
    for dvo in aws_acm_certificate.cloudfront[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : "Certificate validation not configured"
}
