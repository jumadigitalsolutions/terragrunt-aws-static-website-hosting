################################################################################
# CloudFront ACM Certificate
################################################################################
resource "aws_acm_certificate" "cloudfront" {
  provider    = aws.us_east_1 # CloudFront requires certificates in us-east-1
  domain_name = coalesce(var.acm_certificate_domain, "*.${var.domain_name}")
  subject_alternative_names = [
    "${var.bucket_name}-${var.environment}.${var.domain_name}",
    local.dns_record_name
  ]
  validation_method = "DNS"

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

# Route53 Record for ACM Certificate Validation
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

# ACM Certificate Validation
resource "aws_acm_certificate_validation" "cloudfront" {
  provider                = aws.us_east_1 # CloudFront requires certificates in us-east-1
  certificate_arn         = aws_acm_certificate.cloudfront.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
