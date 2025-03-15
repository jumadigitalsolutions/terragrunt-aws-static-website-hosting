locals {
  vars = include.root.locals.vars
}

# Inputs for the variables defined for the module
inputs = {
  domain_name         = local.vars.domain
  environment         = local.env
  acm_certificate_arn = local.vars.certificate_arn
  allowed_origins     = ["https://${local.vars.domain}"]
  bucket_name         = local.vars.bucket_name
  tags = merge(
    local.vars.tags,
    try(local.vars.bucket_tags, {})
  )
} 