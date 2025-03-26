################################################################################
# WAF Logging Configuration
################################################################################
resource "aws_s3_bucket" "waf_logs" {
  count  = var.enable_wafv2 && var.enable_wafv2_logs ? 1 : 0
  bucket = "waf-logs-${var.bucket_name}-${var.environment}"
  tags   = var.tags
}

resource "aws_s3_bucket_ownership_controls" "waf_logs" {
  count  = var.enable_wafv2 && var.enable_wafv2_logs ? 1 : 0
  bucket = aws_s3_bucket.waf_logs[0].id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "waf_logs" {
  count  = var.enable_wafv2 && var.enable_wafv2_logs ? 1 : 0
  bucket = aws_s3_bucket.waf_logs[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "waf_logs" {
  count  = var.enable_wafv2 && var.enable_wafv2_logs ? 1 : 0
  bucket = aws_s3_bucket.waf_logs[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_role" "firehose_role" {
  count = var.enable_wafv2 && var.enable_wafv2_logs ? 1 : 0
  name  = "waf-firehose-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "firehose_s3" {
  count = var.enable_wafv2 && var.enable_wafv2_logs ? 1 : 0
  name  = "waf-firehose-s3-policy-${var.environment}"
  role  = aws_iam_role.firehose_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ]
        Effect = "Allow"
        Resource = [
          aws_s3_bucket.waf_logs[0].arn,
          "${aws_s3_bucket.waf_logs[0].arn}/*"
        ]
      }
    ]
  })
}

resource "aws_kinesis_firehose_delivery_stream" "waf_logs" {
  count       = var.enable_wafv2 && var.enable_wafv2_logs ? 1 : 0
  name        = "aws-waf-logs-${var.environment}"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.firehose_role[0].arn
    bucket_arn         = aws_s3_bucket.waf_logs[0].arn
    prefix             = "waf-logs/"
    compression_format = "GZIP"

    # Standard Firehose buffering settings
    buffering_size     = 5
    buffering_interval = 300
  }

  tags = var.tags
}

resource "aws_wafv2_web_acl_logging_configuration" "waf_logging" {
  count                   = var.enable_wafv2 && var.enable_wafv2_logs ? 1 : 0
  resource_arn            = aws_wafv2_web_acl.cloudfront_acl[0].arn
  log_destination_configs = [aws_kinesis_firehose_delivery_stream.waf_logs[0].arn]
}
