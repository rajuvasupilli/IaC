variable "aws_region" {
  description = "AWS region where the ECR repo will be created"
  type        = string
  default     = "us-east-1"
}

variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "my-app-repo"
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "dev"
}

variable "project" {
  description = "Project name tag"
  type        = string
  default     = "sample-project"
}

