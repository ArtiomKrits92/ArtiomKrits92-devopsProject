# security groups
# firewall rules for the instances

# load balancer security group
resource "aws_security_group" "alb" {
  name_prefix = "${local.name_prefix}-alb-"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  # allow http traffic
  ingress {
    description = "HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  # allow https traffic
  ingress {
    description = "HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  # allow all outbound
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb-sg"
    Type = "Load Balancer"
    Purpose = "Controls traffic to load balancer"
  })
}

# web servers security group
resource "aws_security_group" "web_servers" {
  name_prefix = "${local.name_prefix}-web-"
  description = "Security group for web servers"
  vpc_id      = aws_vpc.main.id

  # allow http from load balancer
  ingress {
    description     = "HTTP from load balancer"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # allow ssh from bastion
  ingress {
    description     = "SSH from bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  # allow all outbound
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-web-sg"
    Type = "Web Server"
    Purpose = "Controls traffic to web servers"
  })
}

# bastion security group
resource "aws_security_group" "bastion" {
  name_prefix = "${local.name_prefix}-bastion-"
  description = "Security group for bastion host"
  vpc_id      = aws_vpc.main.id

  # allow ssh from anywhere
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  # allow all outbound
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-bastion-sg"
    Type = "Bastion Host"
    Purpose = "Controls traffic to bastion host"
  })
}

# outputs
output "alb_security_group_id" {
  description = "ID of the load balancer security group"
  value       = aws_security_group.alb.id
}

output "web_servers_security_group_id" {
  description = "ID of the web servers security group"
  value       = aws_security_group.web_servers.id
}

output "bastion_security_group_id" {
  description = "ID of the bastion host security group"
  value       = aws_security_group.bastion.id
}