
# Outputs
output "zone_id" {
  description = "The ID of the Route53 hosted zone"
  value       = local.hosted_zone_id
}

output "name_servers" {
  description = "The name servers for the Route53 hosted zone"
  value       = var.use_existing_hosted_zone ? data.aws_route53_zone.existing[0].name_servers : aws_route53_zone.this[0].name_servers
}
