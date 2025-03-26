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
