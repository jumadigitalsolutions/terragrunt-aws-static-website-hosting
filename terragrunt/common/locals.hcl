# Define locals for the environment variables
inputs = {
  # Parse the path to get the environment and region
  path   = split("/", path_relative_to_include())
  region = local.path[0]
  env    = local.path[1]
  module = local.path[2]

  # Create merged environment variables from common and module configs
  vars = merge(
    yamldecode(
      fileexists("${get_terragrunt_dir()}/common.yaml")
      ? file("${get_terragrunt_dir()}/common.yaml")
      : "{}"
    ),
    yamldecode(
      fileexists("${get_terragrunt_dir()}/module.yaml")
      ? file("${get_terragrunt_dir()}/module.yaml")
      : "{}"
    )
  )
}