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
    Module      = "ecs-fargate"
  }
}

# Dependencies
dependency "vpc" {
  config_path = "../vpc"

  # Configure mock outputs for plan operations when VPC might not exist yet
  mock_outputs = {
    vpc_id            = "mock-vpc-id"
    public_subnets    = ["mock-subnet-1", "mock-subnet-2"]
    private_subnets   = ["mock-subnet-3", "mock-subnet-4"]
    vpc_cidr_block    = "10.0.0.0/16"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

# Inputs for the variables defined for the module
inputs = {
  # Required input
  environment = local.env
  
  # Use VPC outputs instead of creating new resources
  vpc_id            = dependency.vpc.outputs.vpc_id
  public_subnet_ids = dependency.vpc.outputs.public_subnets
  
  # Domain configuration
  domain                 = local.vars.domain
  acm_certificate_domain = try(local.vars.acm_certificate_domain, "")
  
  # Other optional inputs
  region              = local.region
  task_cpu            = local.vars.task_cpu
  task_memory         = local.vars.task_memory
  service_desired_count = local.vars.service_desired_count
  image_tag           = local.vars.image_tag
  
  # Additional tags
  tags = local.default_tags
}