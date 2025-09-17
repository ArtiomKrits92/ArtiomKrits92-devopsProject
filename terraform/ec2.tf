# ec2 instances
# creates the actual servers

# get latest amazon linux ami
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# web server instances
resource "aws_instance" "web_servers" {
  count = var.web_server_count
  
  ami = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.private[count.index % length(aws_subnet.private)].id
  vpc_security_group_ids = [aws_security_group.web_servers.id]
  key_name = var.key_pair_name
  
  user_data = templatefile("${path.module}/user_data.sh", {
    app_port      = var.app_port
    project_name  = var.project_name
  })
  
  monitoring = true
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-web-server-${count.index + 1}"
    Type = "Web Server"
    Purpose = "Hosts the web application"
    InstanceNumber = count.index + 1
  })
}

# bastion host
resource "aws_instance" "bastion" {
  ami = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.bastion.id]
  key_name = var.key_pair_name
  
  user_data = templatefile("${path.module}/bastion_user_data.sh", {
    project_name = var.project_name
  })
  
  monitoring = true
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-bastion"
    Type = "Bastion Host"
    Purpose = "SSH access to private instances"
  })
}

# elastic ip for bastion
resource "aws_eip" "bastion" {
  instance = aws_instance.bastion.id
  domain   = "vpc"
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-bastion-eip"
    Purpose = "Static IP for bastion host"
  })
}

# outputs
output "web_server_private_ips" {
  description = "Private IP addresses of web servers"
  value       = aws_instance.web_servers[*].private_ip
}

output "web_server_instance_ids" {
  description = "Instance IDs of web servers"
  value       = aws_instance.web_servers[*].id
}

output "bastion_public_ip" {
  description = "Public IP address of bastion host"
  value       = aws_eip.bastion.public_ip
}

output "bastion_private_ip" {
  description = "Private IP address of bastion host"
  value       = aws_instance.bastion.private_ip
}

output "bastion_instance_id" {
  description = "Instance ID of bastion host"
  value       = aws_instance.bastion.id
}