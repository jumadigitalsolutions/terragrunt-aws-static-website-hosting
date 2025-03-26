output "cloudfront_bucket_name" {
  description = "The name of the S3 bucket hosting the cloudfront"
  value       = zipmap(keys(aws_s3_bucket.cloudfront), values(aws_s3_bucket.cloudfront)[*].id) # zipmap may break if order of buckets changes
}

output "cloudfront_bucket_arn" {
  description = "The ARN of the S3 bucket hosting the cloudfront"
  value       = { for k, v in aws_s3_bucket.cloudfront : k => v.arn } # This approach is more reliable as it doesn't depend on the order of the buckets
}

output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.cloudfront.id
}

output "cloudfront_distribution_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.cloudfront.domain_name
}

output "cloudfront_distribution_arn" {
  description = "The ARN of the CloudFront distribution"
  value       = aws_cloudfront_distribution.cloudfront.arn
}

output "acm_certificate_arn" {
  description = "The ARN of the ACM certificate"
  value       = aws_acm_certificate.cloudfront.arn
}

output "acm_certificate_validation_records" {
  description = "The DNS records needed for ACM certificate validation"
  value = {
    for dvo in aws_acm_certificate.cloudfront.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
}
