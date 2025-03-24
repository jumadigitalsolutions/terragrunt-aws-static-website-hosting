variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "create_route53_hosted_zone" {
  description = "Whether to create a Route53 hosted zone or use existing one"
  type        = bool
  default     = true
}

variable "domain" {
  description = "Domain name for the CloudFront distribution"
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "Domain name for the cloudfront"
  type        = string
}

variable "route53_zone_id" {
  description = "The ID of the Route53 hosted zone"
  type        = string
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

variable "enable_dnssec" {
  description = "Whether to enable DNSSEC for the Route53 hosted zone"
  type        = bool
  default     = false
}

variable "enable_query_logging" {
  description = "Whether to enable query logging for the Route53 hosted zone"
  type        = bool
  default     = false
}

variable "query_log_retention_days" {
  description = "Number of days to retain Route53 query logs"
  type        = number
  default     = 7
}

variable "index_document" {
  description = "Index document for the S3 cloudfront"
  type        = string
  default     = "index.html"
}

variable "error_document" {
  description = "Error document for the S3 cloudfront"
  type        = string
  default     = "error.html"
}

variable "cloudfront_price_class" {
  description = "PriceClass for the CloudFront distribution"
  type        = string
  default     = "PriceClass_100"
}

variable "cors_allowed_headers" {
  description = "List of allowed headers for CORS"
  type        = list(string)
  default     = ["Authorization", "Content-Length"]
}

variable "cors_allowed_methods" {
  description = "List of allowed methods for CORS"
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "cors_max_age_seconds" {
  description = "Time in seconds that browsers can cache the response for a preflight request"
  type        = number
  default     = 3600
}

variable "enable_versioning" {
  description = "Whether to enable versioning for the S3 bucket"
  type        = bool
  default     = true
}

variable "enable_logging" {
  description = "Whether to enable logging for the S3 bucket"
  type        = bool
  default     = true
}

variable "s3_bucket_private" {
  description = "Whether to make the S3 bucket private"
  type        = bool
  default     = true
}

variable "enable_lifecycle_configuration" {
  description = "Whether to enable lifecycle configuration for the S3 bucket"
  type        = bool
  default     = true
}

variable "enable_s3_bucket_server_side_encryption" {
  description = "Whether to enable server-side encryption for the S3 bucket"
  type        = bool
  default     = true
}

variable "enable_s3_bucket_notifications" {
  description = "Whether to enable S3 bucket notifications"
  type        = bool
  default     = true
}

variable "enable_cross_region_replication" {
  description = "Whether to enable cross-region replication for the S3 bucket"
  type        = bool
  default     = true
}

variable "s3_cors_rules" {
  description = "List of CORS rules for the S3 bucket"
  type = list(object({
    allowed_headers = list(string)
    allowed_methods = list(string)
    allowed_origins = list(string)
    max_age_seconds = number
  }))
  default = [{
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }]
}
