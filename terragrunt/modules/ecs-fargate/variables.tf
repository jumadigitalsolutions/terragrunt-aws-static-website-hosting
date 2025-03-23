variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "domain" {
  description = "Domain name for the ECS service"
  type        = string
}

variable "domain_name" {
  description = "Root domain name for Route53 zone"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]+(\\.[a-z0-9]+)+$", var.domain_name))
    error_message = "Domain name must be in the format of example.com"
  }
}

variable "acm_certificate_domain" {
  description = "Domain for the ACM certificate (defaults to *.domain)"
  type        = string
  default     = ""
}

variable "task_cpu" {
  description = "CPU units for the ECS task (256 = 0.25 vCPU)"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Memory for the ECS task in MiB"
  type        = number
  default     = 512
}

variable "service_desired_count" {
  description = "Desired count of service tasks"
  type        = number
  default     = 1
}

variable "image_tag" {
  description = "Docker image tag to deploy"
  type        = string
  default     = "latest"
}

# VPC variables from dependencies
variable "vpc_id" {
  description = "ID of the VPC to deploy resources into"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB and ECS tasks"
  type        = list(string)
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
