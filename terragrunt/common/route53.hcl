locals {
  # Parse the path to get the environment and region
  path   = split("/", path_relative_to_include())
  region = local.path[2]
  env    = local.path[3]
  module = local.path[4]

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
  
  # Default empty maps/lists for variables that might not exist
  default_tags = {
    Environment = local.env
    Managed_by  = "terragrunt"
    Module      = "route53"
  }
}

# Inputs for the variables defined for the module
inputs = {
  # Required inputs
  domain_name = local.vars.domain_name
  environment = local.env
  
  # Optional inputs with defaults
  use_existing_hosted_zone = try(local.vars.use_existing_hosted_zone, true)
  enable_dnssec           = try(local.vars.enable_dnssec, false)
  enable_query_logging    = try(local.vars.enable_query_logging, false)
  query_log_retention_days = try(local.vars.query_log_retention_days, 7)
  
  # Additional tags
  tags = local.default_tags
} 