# This boilerplate is used to inherit the main Terragrunt configuration from the parent terragrunt.hcl file
# and merge the common module configuration from the common.hcl file to override the attributes from the parent terragrunt.hcl file
# This is used to avoid repeating the same code in each environment's Terragrunt configuration file for each module
# This is the main terragrunt configuration file that is used to configure the Terragrunt CLI.
# It is inherited by all other terragrunt configuration files to provide common configuration and functionality,
# automatically generating the necessary Terraform files, such as backend.tf and provider.tf.

locals {
  root_vars = include.root.locals
  env = local.root_vars.env
  region = local.root_vars.region
  module = local.root_vars.module
  vars = local.root_vars.vars
}

# Include parent configuration
include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
  merge_strategy = "deep"
}

# Include the common module configuration
include "common"{
  path = "${get_repo_root()}/terragrunt/common/vpc.hcl"
  merge_strategy = "deep"
}