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

# Base VPC configuration shared across environments
inputs = {
  environment          = local.env
  region               = local.region
  vpc_cidr             = local.vars.vpc_cidr
  azs                  = ["${local.region}a", "${local.region}b", "${local.region}c"]
  private_subnets      = local.vars.private_subnets
  public_subnets       = local.vars.public_subnets
  enable_nat_gateway   = try(local.vars.enable_nat_gateway, true)
  single_nat_gateway   = try(local.vars.single_nat_gateway, local.env != "prod")
  enable_dns_hostnames = try(local.vars.enable_dns_hostnames, true)
  enable_dns_support   = try(local.vars.enable_dns_support, true)
  enable_vpn_gateway   = try(local.vars.enable_vpn_gateway, false)

  tags = merge(
    try(local.vars.tags, {}),
    {
      "kubernetes.io/cluster/${local.env}-cluster" = "shared"
    }
  )

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.env}-cluster" = "shared"
    "kubernetes.io/role/internal-elb"            = "1"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.env}-cluster" = "shared"
    "kubernetes.io/role/elb"                     = "1"
  }
}