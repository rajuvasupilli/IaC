terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_ecr_repository" "my_app" {
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE" # or "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  # Optional encryption configuration
  encryption_configuration {
    encryption_type = "AES256" # or "KMS"
  }

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

