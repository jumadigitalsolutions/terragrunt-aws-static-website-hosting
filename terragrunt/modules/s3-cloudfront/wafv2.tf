################################################################################
# WAF v2 Configuration
################################################################################
resource "aws_wafv2_web_acl" "cloudfront_acl" {
  count       = var.enable_wafv2 ? 1 : 0
  provider    = aws.us_east_1 # CloudFront WAF must be in us-east-1
  name        = "cloudfront-web-acl-${var.environment}"
  description = "WAF for CloudFront"
  scope       = "CLOUDFRONT"

  custom_response_body {
    key          = "restricted"
    content      = <<HTML
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Access Restricted</title>
</head>
<body>
    <h1>Access Restricted</h1>
    <p>This content is restricted based on your current location or request rate.</p>
</body>
</html>
HTML
    content_type = "TEXT_HTML"
  }

  default_action {
    allow {}
  }

  rule {
    name     = "rate-limit"
    priority = 1
    action {
      block {
        custom_response {
          response_code            = 429
          custom_response_body_key = "restricted"
        }
      }
    }
    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "rateLimit"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "geo-block"
    priority = 2
    action {
      block {
        custom_response {
          response_code            = 403
          custom_response_body_key = "restricted"
        }
      }
    }
    statement {
      not_statement {
        statement {
          geo_match_statement {
            country_codes = ["BR", "US"]
          }
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "geoBlock"
      sampled_requests_enabled   = true
    }
  }

  # IP allowlist rule - only include if WAF IP set is defined
  dynamic "rule" {
    for_each = length(var.waf_ip_set) > 0 ? [1] : []
    content {
      name     = "ip-allowlist"
      priority = 3

      action {
        allow {}
      }

      statement {
        ip_set_reference_statement {
          arn = aws_wafv2_ip_set.ip_list[0].arn
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "ipAllowlist"
        sampled_requests_enabled   = true
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "cloudfrontWebACL-${var.environment}"
    sampled_requests_enabled   = true
  }

  tags = var.tags
}

resource "aws_wafv2_ip_set" "ip_list" {
  count              = var.enable_wafv2 && length(var.waf_ip_set) > 0 ? 1 : 0
  provider           = aws.us_east_1 # CloudFront WAF must be in us-east-1
  name               = "approved-ip-list-${var.environment}"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = var.waf_ip_set

  tags = var.tags
}
