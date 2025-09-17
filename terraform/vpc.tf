# vpc config
# creates the virtual network

# main vpc
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy = "default"
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc"
    Purpose = "Main VPC for web application"
    NetworkType = "Virtual Private Cloud"
  })
}

# internet gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-igw"
    Purpose = "Internet gateway for public subnets"
    NetworkType = "Internet Gateway"
  })
}

# public subnets
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)
  
  vpc_id = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone = local.azs[count.index % length(local.azs)]
  map_public_ip_on_launch = true
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-subnet-${count.index + 1}"
    Type = "Public"
    Purpose = "Public subnet for load balancer and bastion"
    NetworkType = "Public"
    AZ = local.azs[count.index % length(local.azs)]
  })
}

# private subnets
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)
  
  vpc_id = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone = local.azs[count.index % length(local.azs)]
  map_public_ip_on_launch = false
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-private-subnet-${count.index + 1}"
    Type = "Private"
    Purpose = "Private subnet for web servers"
    NetworkType = "Private"
    AZ = local.azs[count.index % length(local.azs)]
  })
}

# route tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-rt"
    Type = "Public"
    Purpose = "Route table for public subnets"
    NetworkType = "Public"
  })
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-private-rt"
    Type = "Private"
    Purpose = "Route table for private subnets"
    NetworkType = "Private"
  })
}

# route table associations
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)
  
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)
  
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "internet_gateway_id" {
  description = "ID of the internet gateway"
  value       = aws_internet_gateway.main.id
}

output "availability_zones" {
  description = "List of availability zones used"
  value       = local.azs
}