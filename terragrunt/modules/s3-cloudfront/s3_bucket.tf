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
# This will be overridden by the cloudfront module response headers policy,
# because the override attribute is set to true
resource "aws_s3_bucket_cors_configuration" "cors_configuration" {
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
