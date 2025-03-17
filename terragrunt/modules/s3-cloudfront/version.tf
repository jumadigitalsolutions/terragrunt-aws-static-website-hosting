terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.91.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.10.0"
    }
  }
}

# ACM certificates for CloudFront must be in us-east-1 region
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
