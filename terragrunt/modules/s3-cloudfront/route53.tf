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
