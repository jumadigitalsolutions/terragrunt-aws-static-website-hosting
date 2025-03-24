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
    Module      = "s3-cloudfront"
  }
}

# Dependencies
dependency "route53" {
  config_path = "../route53"

  # Configure mock outputs for plan operations when Route53 might not exist yet
  mock_outputs = {
    zone_id = "mock-zone-id"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy", "apply"]
}

# Inputs for the variables defined for the module
inputs = {
  environment = local.env
  region = local.region
  domain_name = local.vars.domain_name
  bucket_name = local.vars.bucket_name
  tags = local.vars.tags
  route53_zone_id = dependency.route53.outputs.zone_id
  enable_s3_bucket_notifications = local.vars.enable_s3_bucket_notifications
  enable_s3_bucket_server_side_encryption = local.vars.enable_s3_bucket_server_side_encryption
  enable_cross_region_replication = local.vars.enable_cross_region_replication
  enable_versioning = local.vars.enable_versioning
  enable_logging = local.vars.enable_logging
  s3_bucket_private = local.vars.s3_bucket_private
  enable_lifecycle_configuration = local.vars.enable_lifecycle_configuration
  cors_rules = local.vars.cors_rules
} 