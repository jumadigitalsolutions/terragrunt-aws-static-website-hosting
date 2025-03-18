# This boilerplate is used to inherit the main Terragrunt configuration from the parent terragrunt.hcl file
# and merge the common module configuration from the common.hcl file to override the attributes from the parent terragrunt.hcl file
# This is used to avoid repeating the same code in each environment's Terragrunt configuration file for each module

# Include parent configuration
include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

# Include the common module configuration
include {
  path           = "${get_repo_root()}/terragrunt/common/basen.hcl"
  merge_strategy = "deep" # Override attributes from the parent terragrunt.hcl file with the common module configuration
}