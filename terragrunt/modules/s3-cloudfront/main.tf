locals {
  dns_record_name = format("hippo-cloudfront-%s.%s", var.environment, var.domain_name)
}

# S3 Bucket Configuration
resource "aws_s3_bucket" "cloudfront" {
  bucket = format("%s-%s", var.bucket_name, var.environment)

  tags = var.tags
}

resource "aws_s3_bucket_ownership_controls" "cloudfront" {
  bucket = aws_s3_bucket.cloudfront.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Security Hardening - Block all public access
resource "aws_s3_bucket_public_access_block" "cloudfront" {
  bucket = aws_s3_bucket.cloudfront.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create Origin Access Control for CloudFront to allow access to the S3 bucket
resource "aws_cloudfront_origin_access_control" "cloudfront" {
  name                              = "${var.bucket_name}-oac"
  description                       = "Origin Access Control for ${var.bucket_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# S3 bucket policy to allow CloudFront access via OAC
resource "aws_s3_bucket_policy" "cloudfront" {
  bucket = aws_s3_bucket.cloudfront.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipalReadOnly"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.cloudfront.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.cloudfront.arn
          }
        }
      }
    ]
  })
}

# Create ACM certificate for the CloudFront distribution
resource "aws_acm_certificate" "cloudfront" {
  domain_name = coalesce(var.acm_certificate_domain, "*.${var.domain_name}")
  subject_alternative_names = [
    "${aws_s3_bucket.cloudfront.bucket}.${var.domain_name}",
    local.dns_record_name
  ]
  validation_method = "DNS"

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

# Create DNS validation records for the ACM certificate
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cloudfront.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = var.route53_zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

# Validate the ACM certificate
resource "aws_acm_certificate_validation" "cloudfront" {
  certificate_arn         = aws_acm_certificate.cloudfront.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# CDN Configuration - Updated to use OAC
resource "aws_cloudfront_distribution" "cloudfront" {
  origin {
    domain_name              = aws_s3_bucket.cloudfront.bucket_regional_domain_name
    origin_id                = "S3-${aws_s3_bucket.cloudfront.bucket}"
    origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront.id
  }

  # Custom domain configuration
  aliases = [
    format("hippo-cloudfront-%s.%s", var.environment, var.domain_name),
    "${aws_s3_bucket.cloudfront.bucket}.${var.domain_name}"
  ]

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.cloudfront.bucket}"

    # Cache optimization settings
    min_ttl                = 0
    default_ttl            = 3600  # 1 hour
    max_ttl                = 86400 # 1 day
    viewer_protocol_policy = "redirect-to-https"

    # Optional: Improve forwarding settings
    compress = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  price_class = "PriceClass_100" # Optimize costs for main regions

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Certificate configuration
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.cloudfront.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = var.tags
}

# Create DNS record for cloudfront subdomain
resource "aws_route53_record" "cloudfront_subdomain" {
  count = var.domain_name != "" ? 1 : 0 # Only create the record if the domain name is set

  zone_id = var.route53_zone_id
  name    = local.dns_record_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cloudfront.domain_name
    zone_id                = aws_cloudfront_distribution.cloudfront.hosted_zone_id
    evaluate_target_health = false
  }
}
