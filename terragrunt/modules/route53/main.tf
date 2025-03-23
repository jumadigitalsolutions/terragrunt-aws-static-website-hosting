locals {
  # Use existing hosted zone if provided, otherwise create this one
  hosted_zone_id = var.use_existing_hosted_zone ? data.aws_route53_zone.existing[0].zone_id : aws_route53_zone.this[0].zone_id
}

# Use existing hosted zone if specified
data "aws_route53_zone" "existing" {
  count = var.use_existing_hosted_zone ? 1 : 0
  name  = var.domain_name
}

# Create this hosted zone if not using existing
resource "aws_route53_zone" "this" {
  count = var.use_existing_hosted_zone ? 0 : 1
  name  = var.domain_name

  tags = var.tags
}

# Add caller identity data source for IAM policies
data "aws_caller_identity" "current" {}

# Configure DNSSEC if enabled
resource "aws_kms_key" "dnssec_key" {
  count = var.enable_dnssec ? 1 : 0

  customer_master_key_spec = "ECC_NIST_P256"
  deletion_window_in_days  = 7
  key_usage                = "SIGN_VERIFY"
  policy = jsonencode({
    Statement = [
      {
        Action = [
          "kms:DescribeKey",
          "kms:GetPublicKey",
          "kms:Sign",
        ],
        Effect = "Allow",
        Principal = {
          Service = "dnssec-route53.amazonaws.com"
        },
        Resource = "*"
        Sid      = "Allow Route53 DNSSEC Service"
      },
      {
        Action = "kms:*"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Resource = "*"
        Sid      = "Enable IAM User Permissions"
      },
    ]
    Version = "2012-10-17"
  })

  tags = merge(var.tags, {
    Name = "${var.domain_name}-dnssec-key"
  })
}

resource "aws_route53_key_signing_key" "dnssec_key" {
  count = var.enable_dnssec ? 1 : 0

  hosted_zone_id             = local.hosted_zone_id
  key_management_service_arn = aws_kms_key.dnssec_key[0].arn
  name                       = "${var.domain_name}-key"
}

resource "aws_route53_hosted_zone_dnssec" "dnssec" {
  count = var.enable_dnssec ? 1 : 0

  hosted_zone_id = local.hosted_zone_id
}

# Configure query logging if enabled
resource "aws_cloudwatch_log_group" "route53_query_logs" {
  count = var.enable_query_logging ? 1 : 0

  name              = "/aws/route53/${var.domain_name}"
  retention_in_days = var.query_log_retention_days

  tags = merge(var.tags, {
    Name = "${var.domain_name}-query-logs"
  })
}

resource "aws_cloudwatch_log_resource_policy" "route53_query_logging_policy" {
  count = var.enable_query_logging ? 1 : 0

  policy_name = "route53-query-logging-policy-${var.environment}"

  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Effect = "Allow"
        Principal = {
          Service = "route53.amazonaws.com"
        }
        Resource = "arn:aws:logs:*:*:log-group:/aws/route53/*"
        Sid      = "Route53QueryLoggingPolicy"
      }
    ]
  })
}

resource "aws_route53_query_log" "query_log" {
  count = var.enable_query_logging ? 1 : 0

  depends_on = [aws_cloudwatch_log_resource_policy.route53_query_logging_policy]

  zone_id                  = local.hosted_zone_id
  cloudwatch_log_group_arn = aws_cloudwatch_log_group.route53_query_logs[0].arn
}
