variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the S3 bucket"
  type        = map(string)
}

variable "create_route53_hosted_zone" {
  description = "Whether to create a new Route53 hosted zone"
  type        = bool
  default     = false
}


variable "domain_name" {
  description = "Domain name"
  type        = string
  default     = ""
  validation {
    condition     = regex("^[a-z]+\\.[a-z]+$", var.domain_name)
    error_message = "Domain name must be in the format of example.com"
  }
}

variable "acm_certificate_domain" {
  description = "Domain for the ACM certificate (defaults to *.domain)"
  type        = string
  default     = ""
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate"
  type        = string
  default     = ""
}

