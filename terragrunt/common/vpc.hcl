# Define locals for the environment variables
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
  
  # Set default VPC CIDR if not provided in module.yaml
  vpc_cidr = try(local.vars.vpc_cidr, "10.0.0.0/16")
  
  # Use the availability_zones from module.yaml if defined, otherwise use default AZs
  availability_zones = try(local.vars.availability_zones, ["${local.region}a", "${local.region}b", "${local.region}c"])
  
  # Determine number of subnets needed based on AZs
  az_count = length(local.availability_zones)
  
  # Generate subnet CIDRs using cidrsubnet
  # For a /16 VPC, we'll create /24 subnets (adding 8 bits)
  # Private subnets will start from 0, public subnets will start from 100
  private_subnets = [
    for i in range(local.az_count) : cidrsubnet(local.vpc_cidr, 8, i)
  ]
  
  public_subnets = [
    for i in range(local.az_count) : cidrsubnet(local.vpc_cidr, 8, i + 100)
  ]
}

# Base VPC configuration shared across environments
inputs = {
  environment          = local.env
  region               = local.region
  vpc_cidr             = local.vars.vpc_cidr
  azs                  = try(local.vars.availability_zones, ["${local.region}a", "${local.region}b", "${local.region}c"])
  private_subnets      = local.vars.private_subnets
  public_subnets       = local.vars.public_subnets
  enable_nat_gateway   = try(local.vars.enable_nat_gateway, true)
  single_nat_gateway   = try(local.vars.single_nat_gateway, local.env != "prod")
  enable_dns_hostnames = try(local.vars.enable_dns_hostnames, true)
  enable_dns_support   = try(local.vars.enable_dns_support, true)
  enable_vpn_gateway   = try(local.vars.enable_vpn_gateway, false)

  tags = local.vars.tags
}