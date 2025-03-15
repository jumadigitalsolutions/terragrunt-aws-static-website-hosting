# This is the main terragrunt configuration file that is used to configure the Terragrunt CLI.
# It is inherited by all other terragrunt configuration files to provide common configuration and functionality,
# automatically generating the necessary Terraform files, such as backend.tf and provider.tf.

# Configure Terragrunt to automatically store tfstate files in S3
remote_state {
  backend = "s3"
  config = {
    bucket         = "jumads-hippo-terraform-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.vars.region
    encrypt        = true
    kms_key_id     = "arn:aws:kms:us-east-1:626146856453:alias/aws/s3"
    use_lockfile   = true
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}