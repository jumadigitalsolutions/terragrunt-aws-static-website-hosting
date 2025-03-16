variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "task_cpu" {
  description = "CPU units for the ECS task"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Memory for the ECS task"
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
