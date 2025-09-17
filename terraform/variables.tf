# terraform variables
# all the settings i can customize

# aws config
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.aws_region))
    error_message = "AWS region must be a valid region name."
  }
}

# project config
variable "project_name" {
  description = "Project name"
  type        = string
  default     = "terraform-ansible-webapp"
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.project_name))
    error_message = "Project name must contain only alphanumeric characters and hyphens."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "owner" {
  description = "Owner of resources"
  type        = string
  default     = "DevOps Student"
}

# network config
variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24"]
  
  validation {
    condition     = length(var.public_subnet_cidrs) >= 1
    error_message = "At least one public subnet CIDR must be specified."
  }
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
  
  validation {
    condition     = length(var.private_subnet_cidrs) >= 2
    error_message = "At least two private subnet CIDRs must be specified."
  }
}

# ec2 config
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
  
  validation {
    condition     = can(regex("^t3\\.", var.instance_type))
    error_message = "Instance type must be t3.micro for AWS Academy compatibility."
  }
}

variable "key_pair_name" {
  description = "SSH key pair name"
  type        = string
  default     = "devops-learning-key"
}

variable "web_server_count" {
  description = "Number of web server instances"
  type        = number
  default     = 2
  
  validation {
    condition     = var.web_server_count >= 1 && var.web_server_count <= 4
    error_message = "Web server count must be between 1 and 4."
  }
}

# app config
variable "app_port" {
  description = "Application port"
  type        = number
  default     = 5000
  
  validation {
    condition     = var.app_port > 0 && var.app_port <= 65535
    error_message = "App port must be between 1 and 65535."
  }
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/health"
}

# security config
variable "allowed_cidr_blocks" {
  description = "Allowed CIDR blocks"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_ssh_access" {
  description = "Enable SSH access"
  type        = bool
  default     = true
}

# backend config
variable "terraform_state_bucket" {
  description = "S3 bucket for terraform state"
  type        = string
  default     = "terraform-ansible-webapp-state"
}

variable "terraform_state_key" {
  description = "S3 key for terraform state"
  type        = string
  default     = "terraform.tfstate"
}

variable "terraform_state_region" {
  description = "AWS region for terraform state bucket"
  type        = string
  default     = "us-east-1"
}

variable "dynamodb_table_name" {
  description = "DynamoDB table for state locking"
  type        = string
  default     = "terraform-ansible-webapp-locks"
}