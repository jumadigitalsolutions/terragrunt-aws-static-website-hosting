################################################################################
# CloudFront Distribution
################################################################################
# Note: response_headers_policy_id requires AWS provider version >= 4.0.0
resource "aws_cloudfront_distribution" "cloudfront" {
  depends_on = [aws_acm_certificate_validation.cloudfront]

  # Associate the WAF with the CloudFront distribution, if enabled
  web_acl_id = var.enable_wafv2 ? aws_wafv2_web_acl.cloudfront_acl[0].arn : null

  origin {
    domain_name              = aws_s3_bucket.cloudfront["primary"].bucket_regional_domain_name
    origin_id                = local.oac_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront.id
  }

  aliases = [
    local.dns_record_name,
    "${aws_s3_bucket.cloudfront["primary"].id}.${var.domain_name}"
  ]

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.oac_origin_id

    # min_ttl                = 0
    # default_ttl            = 3600
    # max_ttl                = 86400

    viewer_protocol_policy = "redirect-to-https"

    compress = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    response_headers_policy_id = var.enable_response_headers_policy ? aws_cloudfront_response_headers_policy.cloudfront_response_headers_policy.id : null # Only set if response headers policy is enabled
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "BR"]
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cloudfront.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = var.tags
}

################################################################################
# CloudFront Origin Access Control
################################################################################
resource "aws_cloudfront_origin_access_control" "cloudfront" {
  name                              = "${var.bucket_name}-oac"
  description                       = "Origin Access Control for ${var.bucket_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

################################################################################
# CloudFront Response Headers Policy
################################################################################
resource "aws_cloudfront_response_headers_policy" "cloudfront_response_headers_policy" {
  name    = "${var.bucket_name}-response-headers-policy"
  comment = "Response Headers Policy for ${var.bucket_name}"

  cors_config {
    access_control_allow_credentials = true

    access_control_allow_headers {
      items = ["Authorization", "Content-Type", "Origin"]
    }

    access_control_allow_methods {
      items = ["GET", "PUT"]
    }

    access_control_allow_origins {
      items = ["*.${var.domain_name}"]
    }

    origin_override = true
  }
}
