# This is the main terragrunt configuration file that is used to configure the Terragrunt CLI.
# It is inherited by all other terragrunt configuration files to provide common configuration and functionality,
# automatically generating the necessary Terraform files, such as backend.tf and provider.tf.

# Define locals for the environment variables
locals {
  # Parse the path to get the environment and region
  path = split("/", path_relative_to_include())
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

# Configure the Terraform source to use the module from the terragrunt/modules directory
# The local.module variable is set in the child terragrunt.hcl file that inherits this.
terraform {
  source = "${get_repo_root()}/terragrunt/modules/${local.module}"
}

# Configure the remote state backend to use S3 for storing the Terraform state files
remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt" # Generates a new backend.tf file if it doesn't exist
  }
  config = {
    bucket         = "jumads-hippo-terraform-state"
    key            = "replace(${path_relative_to_include()}, 'live/', '')/terraform.tfstate" # Remove "live" from the path and join remaining parts for the state file path in S3
    region         = local.region
    encrypt        = true
    use_lockfile = true
  }
}

# Configure the provider to use the AWS region specified in the environment variables
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt" # Generates a new provider.tf file if it doesn't exist
  contents  = <<EOF
provider "aws" {
  region = "${local.region}"
  
  # Allows GitHub Actions to assume the role for the static website hosting with OIDC
  assume_role {
    role_arn = "arn:aws:iam::626146856453:role/github-execution-role-terragrunt-aws-static-website-hosting"
  }
}
EOF
}

generate "terraform" {
  path = "terraform.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
  terraform {
    required_version = "= 1.11.2"
  }
EOF
}
