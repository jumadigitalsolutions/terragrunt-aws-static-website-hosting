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
  
  # Default empty maps/lists for variables that might not exist
  default_tags = {
    Environment = local.env
    Managed_by  = "terragrunt"
    Module      = "ecs-fargate"
  }
}

# Dependencies
dependency "vpc" {
  config_path = "../vpc"
}

# Inputs for the variables defined for the module
inputs = {
  execution_role_arn = "arn:aws:iam::${get_aws_account_id()}:role/ecsTaskExecutionRole"
  task_role_arn      = "arn:aws:iam::${get_aws_account_id()}:role/ecsTaskRole"
  vpc_id             = dependency.vpc.outputs.vpc_id
  private_subnet_ids = dependency.vpc.outputs.private_subnets
  public_subnet_ids  = dependency.vpc.outputs.public_subnets
  security_group_ids = try(local.vars.security_group_ids, [])
  tags = merge(
    local.default_tags,
    try(local.vars.tags, {})
  )
} 