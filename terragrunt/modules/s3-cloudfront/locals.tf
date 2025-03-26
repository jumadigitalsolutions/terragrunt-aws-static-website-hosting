################################################################################
# Local Variables
################################################################################
locals {
  dns_record_name = format("hippo-cloudfront-%s.%s", var.environment, var.domain_name)
  bucket_names = var.enable_cross_region_replication ? {
    primary   = format("%s-%s", var.bucket_name, var.environment)
    secondary = format("%s-%s-replica", var.bucket_name, var.environment)
    } : {
    primary = format("%s-%s", var.bucket_name, var.environment)
  }
  oac_origin_id = format("S3-%s", aws_s3_bucket.cloudfront["primary"].id)
}
