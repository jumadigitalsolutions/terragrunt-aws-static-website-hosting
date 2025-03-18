# Define locals for the environment variables
locals {
  # Parse the path to get the environment and region
  path   = split("/", path_relative_to_include())
  region = local.path[1]
  env    = local.path[2]
  module = local.path[3]

  # Create merged environment variables from common and module configs
  vars = merge(
    yamldecode(
      fileexists("${get_terragrunt_dir()}/../common.yaml")
      ? file("${get_terragrunt_dir()}/../common.yaml")
      : "{}"
    ),
    yamldecode(
      fileexists("${get_terragrunt_dir()}/module.yaml")
      ? file("${get_terragrunt_dir()}/module.yaml")
      : "{}"
    )
  )
}

# Inputs for the variables defined for the module
inputs = {
  domain                  = local.vars.domain
  environment             = local.env
  bucket_name             = local.vars.bucket_name
  acm_certificate_domain  = try(local.vars.acm_certificate_domain, "")
  tags = merge(
    local.vars.tags,
    try(local.vars.bucket_tags, {})
  )
} 