locals {
  dns_record_name = format("hippo-cloudfront-%s.%s", var.environment, var.domain_name)
  bucket_names = var.enable_cross_region_replication ? {
    primary   = format("%s-%s", var.bucket_name, var.environment)
    secondary = format("%s-%s-replica", var.bucket_name, var.environment)
    } : {
    primary = format("%s-%s", var.bucket_name, var.environment)
  }
}

# S3 Bucket Configuration
resource "aws_s3_bucket" "cloudfront" {
  for_each = local.bucket_names
  bucket   = each.value
  tags     = var.tags
}

################################################################################
# S3 Bucket Encryption
################################################################################
resource "aws_kms_key" "bucket_encryption" {
  for_each = var.enable_s3_bucket_server_side_encryption ? local.bucket_names : {}

  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudfront" {
  for_each = var.enable_s3_bucket_server_side_encryption ? local.bucket_names : {}

  bucket = aws_s3_bucket.cloudfront[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.bucket_encryption[each.key].arn
      sse_algorithm     = "aws:kms"
    }
  }
}

################################################################################
# S3 Bucket Notifications
################################################################################
resource "aws_sns_topic" "bucket_notification_topic" {
  for_each = var.enable_s3_bucket_notifications ? local.bucket_names : {}

  name = "${each.value}-s3-event-notification-topic"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowSNSPublish"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = "arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${each.value}-s3-event-notification-topic"
      }
    ]
  })
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  for_each = var.enable_s3_bucket_notifications ? local.bucket_names : {}

  bucket = aws_s3_bucket.cloudfront[each.key].id

  topic {
    topic_arn = aws_sns_topic.bucket_notification_topic[each.key].arn
    events = [
      "s3:ObjectCreated:*",
      "s3:ObjectRemoved:Delete"
    ]
  }
}

################################################################################
# S3 Bucket Versioning
################################################################################
resource "aws_s3_bucket_versioning" "this" {
  for_each = var.enable_versioning ? local.bucket_names : {}

  bucket = aws_s3_bucket.cloudfront[each.key].id
  versioning_configuration {
    status = "Enabled"
  }
}

################################################################################
# S3 Bucket Logging
################################################################################
resource "aws_s3_bucket" "logging" {
  for_each = var.enable_logging ? local.bucket_names : {}

  bucket = format("%s-logging-%s", var.bucket_name, var.environment)
}

resource "aws_s3_bucket_ownership_controls" "logging" {
  for_each = var.enable_logging ? local.bucket_names : {}

  bucket = aws_s3_bucket.logging[each.key].id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_logging" "this" {
  for_each = var.enable_logging ? local.bucket_names : {}

  bucket        = aws_s3_bucket.cloudfront[each.key].id
  target_bucket = aws_s3_bucket.logging[each.key].id
  target_prefix = "logs/"
}

################################################################################
# S3 Bucket Lifecycle Configuration
################################################################################
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  for_each = var.enable_lifecycle_configuration ? local.bucket_names : {}

  bucket = aws_s3_bucket.cloudfront[each.key].id
  rule {
    id     = "delete-after-30-days"
    status = "Enabled"
    filter {
      prefix = "logs/"
    }
    expiration {
      days = 30
    }
  }
}

################################################################################
# S3 Bucket Policy
################################################################################
resource "aws_s3_bucket_ownership_controls" "cloudfront" {
  for_each = local.bucket_names

  bucket = aws_s3_bucket.cloudfront[each.key].id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

################################################################################
# S3 CORS Configuration
################################################################################
resource "aws_s3_bucket_cors_configuration" "new_bucket" {
  for_each = var.s3_cors_rules != null ? local.bucket_names : {}

  bucket = aws_s3_bucket.cloudfront[each.key].id

  dynamic "cors_rule" {
    for_each = var.s3_cors_rules
    content {
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }
}

resource "aws_s3_bucket_public_access_block" "cloudfront" {
  for_each = local.bucket_names

  bucket = aws_s3_bucket.cloudfront[each.key].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

################################################################################
# S3 Bucket Replication
################################################################################
data "aws_iam_policy_document" "replication_assume_role" {
  count = var.enable_cross_region_replication ? 1 : 0

  statement {
    sid    = "AllowCrossRegionReplication"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "replication_policy" {
  count = var.enable_cross_region_replication ? 1 : 0

  statement {
    sid    = "AllowCrossRegionReplication"
    effect = "Allow"
    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
      "s3:GetReplicationConfiguration",
      "s3:ListBucket"
    ]
    resources = [
      "${aws_s3_bucket.cloudfront["primary"].arn}/*"
    ]
  }

  statement {
    sid    = "AllowReplicationDestinationObjectOperations"
    effect = "Allow"
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
      "s3:GetObjectVersionTagging"
    ]
    resources = [
      "${aws_s3_bucket.cloudfront["secondary"].arn}/*"
    ]
  }
}

resource "aws_iam_policy" "replication" {
  count = var.enable_cross_region_replication ? 1 : 0

  name   = "s3-cross-region-replication-policy"
  policy = data.aws_iam_policy_document.replication_policy[0].json
}

resource "aws_iam_role" "replication_role" {
  count = var.enable_cross_region_replication ? 1 : 0

  name               = "s3-cross-region-replication-role"
  assume_role_policy = data.aws_iam_policy_document.replication_assume_role[0].json
}

resource "aws_iam_role_policy_attachment" "replication" {
  count = var.enable_cross_region_replication ? 1 : 0

  role       = aws_iam_role.replication_role[0].name
  policy_arn = aws_iam_policy.replication[0].arn
}

resource "aws_s3_bucket_replication_configuration" "this" {
  count = var.enable_cross_region_replication ? 1 : 0

  bucket = aws_s3_bucket.cloudfront["primary"].id
  role   = aws_iam_role.replication_role[0].arn

  rule {
    id     = "replication-rule"
    status = "Enabled"
    destination {
      bucket = aws_s3_bucket.cloudfront["secondary"].arn
    }
  }

  depends_on = [aws_s3_bucket_versioning.this]
}

################################################################################
# CloudFront Distribution
################################################################################
resource "aws_cloudfront_distribution" "cloudfront" {
  depends_on = [aws_acm_certificate_validation.cloudfront]

  origin {
    domain_name              = aws_s3_bucket.cloudfront["primary"].bucket_regional_domain_name
    origin_id                = "S3-${aws_s3_bucket.cloudfront["primary"].id}"
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
    target_origin_id = "S3-${aws_s3_bucket.cloudfront["primary"].id}"

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    viewer_protocol_policy = "redirect-to-https"

    compress = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.cloudfront.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = var.tags
}

################################################################################
# CloudFront Origin Access Control & S3 Bucket Policy
################################################################################
resource "aws_cloudfront_origin_access_control" "cloudfront" {
  name                              = "${var.bucket_name}-oac"
  description                       = "Origin Access Control for ${var.bucket_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_s3_bucket_policy" "cloudfront" {
  bucket = aws_s3_bucket.cloudfront["primary"].id

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
        Resource = "${aws_s3_bucket.cloudfront["primary"].arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.cloudfront.arn
          }
        }
      }
    ]
  })
}

################################################################################
# CloudFront ACM Certificate
################################################################################
resource "aws_acm_certificate" "cloudfront" {
  domain_name = coalesce(var.acm_certificate_domain, "*.${var.domain_name}")
  subject_alternative_names = [
    "${aws_s3_bucket.cloudfront["primary"].id}.${var.domain_name}",
    local.dns_record_name
  ]
  validation_method = "DNS"

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

################################################################################
# Route53 DNS
################################################################################
resource "aws_route53_record" "cloudfront_subdomain" {
  count = var.domain_name != "" ? 1 : 0

  zone_id = var.route53_zone_id
  name    = local.dns_record_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cloudfront.domain_name
    zone_id                = aws_cloudfront_distribution.cloudfront.hosted_zone_id
    evaluate_target_health = false
  }
}
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

resource "aws_acm_certificate_validation" "cloudfront" {
  certificate_arn         = aws_acm_certificate.cloudfront.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

