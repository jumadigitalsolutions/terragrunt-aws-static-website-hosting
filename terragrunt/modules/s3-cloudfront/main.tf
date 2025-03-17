# TODO: Disable public read access to the bucket

# S3 Bucket Configuration
resource "aws_s3_bucket" "website" {
  bucket = format("%s-%s", var.bucket_name, var.environment)

  tags = var.tags
}

resource "aws_s3_bucket_ownership_controls" "website" {
  bucket = aws_s3_bucket.website.id
  rule {
    object_ownership = "BucketOwnerEnforced" # This ensures that the bucket owner has full control over the bucket and its objects
  }
}

# Security Hardening - Block all public access
resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create Origin Access Control for CloudFront to allow access to the S3 bucket
resource "aws_cloudfront_origin_access_control" "website" {
  name                              = "${var.bucket_name}-oac"
  description                       = "Origin Access Control for ${var.bucket_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# S3 bucket policy to allow CloudFront access via OAC
resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id

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
        Resource = "${aws_s3_bucket.website.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.website.arn
          }
        }
      }
    ]
  })
}

# Create a new Route53 hosted zone for the domain
resource "aws_route53_zone" "website" {
  name = var.domain
  tags = var.tags
}

# Create ACM certificate for the CloudFront distribution
# Note: CloudFront distributions use certificates in us-east-1 region
resource "aws_acm_certificate" "cloudfront" {
  count             = var.use_custom_domain ? 1 : 0
  provider          = aws.us_east_1
  domain_name       = coalesce(var.acm_certificate_domain, "*.${var.domain}")
  validation_method = "DNS"

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

# Create DNS validation records for the ACM certificate
resource "aws_route53_record" "cert_validation" {
  for_each = var.use_custom_domain ? {
    for dvo in aws_acm_certificate.cloudfront[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  zone_id = aws_route53_zone.website.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

# Validate the ACM certificate
resource "aws_acm_certificate_validation" "cloudfront" {
  count                   = var.use_custom_domain ? 1 : 0
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.cloudfront[0].arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# CDN Configuration - Updated to use OAC
resource "aws_cloudfront_distribution" "website" {
  origin {
    domain_name              = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id                = "S3-${aws_s3_bucket.website.bucket}"
    origin_access_control_id = aws_cloudfront_origin_access_control.website.id
  }

  # Conditionally use custom domain based on use_custom_domain variable
  aliases = var.use_custom_domain ? [format("hippo-cloudfront-%s.%s", var.environment, var.domain)] : []

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.website.bucket}"

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

  # Conditionally use custom certificate based on use_custom_domain variable
  viewer_certificate {
    acm_certificate_arn            = var.use_custom_domain ? aws_acm_certificate_validation.cloudfront[0].certificate_arn : null
    ssl_support_method             = var.use_custom_domain ? "sni-only" : null
    minimum_protocol_version       = var.use_custom_domain ? "TLSv1.2_2021" : "TLSv1.2_2021"
    cloudfront_default_certificate = var.use_custom_domain ? false : true
  }

  tags = var.tags

  # Wait for certificate validation before creating the distribution only if using custom domain
  depends_on = var.use_custom_domain ? [aws_acm_certificate_validation.cloudfront[0]] : []
}

# Create Route53 alias record pointing to the CloudFront distribution
resource "aws_route53_record" "cloudfront" {
  count   = var.use_custom_domain ? 1 : 0
  zone_id = aws_route53_zone.website.zone_id
  name    = format("hippo-cloudfront-%s.%s", var.environment, var.domain)
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website.domain_name
    zone_id                = aws_cloudfront_distribution.website.hosted_zone_id
    evaluate_target_health = false
  }
}

# We are using GitHub Actions to deploy the website for better isolation of Infrastructure as Code from Application Code Deployments
# but leaving this resource here to demonstrate how to upload the website with Infrastructure as Code
# resource "null_resource" "upload_website" {
#   triggers = {
#     file_content_md5 = md5(file("${path.module}/../../src/index.html"))
#   }

#   provisioner "local-exec" {
#     command = "aws s3 cp ${path.module}/../../src/index.html s3://${aws_s3_bucket.website.bucket}/index.html"
#   }

#   depends_on = [aws_s3_bucket.website, aws_s3_bucket_policy.website]
# }
