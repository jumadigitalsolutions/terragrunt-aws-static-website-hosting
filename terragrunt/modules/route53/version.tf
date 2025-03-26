terraform {
  required_version = ">= 1.11.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.92.0"
    }
  }
}

# Declaring an alias to use for global resources that need to be in us-east-1,
# such as AWS KMS keys for DNSSEC signing.
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_hosted_zone_dnssec
provider "aws" {
  alias = "us_east_1"

  region = "us-east-1"
}
