# main terraform config
# basic provider setup and variables

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# aws provider config
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      Owner       = var.owner
      Purpose     = "Learning DevOps with Terraform and Ansible"
      CreatedBy   = "Terraform"
      ManagedBy   = "Student Learning Project"
      Course      = "Technion DevOps"
      Student     = "Artiom Krits"
    }
  }
}

# get available azs
data "aws_availability_zones" "available" {
  state = "available"
}

# get current aws account info
data "aws_caller_identity" "current" {}

# get current region
data "aws_region" "current" {}

# local values
locals {
  name_prefix = "${var.project_name}-${var.environment}"
  
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "Terraform"
    Course      = "Technion DevOps"
    Student     = "Artiom Krits"
  }
  
  # only need first 2 azs
  azs = slice(data.aws_availability_zones.available.names, 0, 2)
}