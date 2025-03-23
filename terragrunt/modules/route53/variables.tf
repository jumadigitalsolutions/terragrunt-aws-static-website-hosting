variable "domain_name" {
  description = "Root domain name for Route53 zone"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]+(\\.[a-z0-9]+)+$", var.domain_name))
    error_message = "Domain name must be in the format of example.com"
  }
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "use_existing_hosted_zone" {
  description = "Whether to use an existing hosted zone or create a new one"
  type        = bool
  default     = true
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

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
} 
