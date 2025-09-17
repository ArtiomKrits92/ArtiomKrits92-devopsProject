# terraform outputs
# what terraform shows after deployment

# vpc info
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

# network info
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

# load balancer info
output "load_balancer_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "application_url" {
  description = "URL to access the application"
  value       = "http://${aws_lb.main.dns_name}"
}

# instance info
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

# security group info
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

# connection info
output "ssh_to_bastion" {
  description = "SSH command to connect to bastion host"
  value       = "ssh -i your-key.pem ec2-user@${aws_eip.bastion.public_ip}"
}

output "ssh_to_web_servers" {
  description = "SSH command to connect to web servers via bastion"
  value       = "ssh -i your-key.pem ec2-user@${aws_instance.web_servers[0].private_ip} -o ProxyCommand=\"ssh -i your-key.pem ec2-user@${aws_eip.bastion.public_ip} -W %h:%p\""
}

# summary
output "deployment_summary" {
  description = "Summary of the deployment"
  value = {
    application_url = "http://${aws_lb.main.dns_name}"
    bastion_ip      = aws_eip.bastion.public_ip
    web_servers     = length(aws_instance.web_servers)
    vpc_id          = aws_vpc.main.id
    region          = var.aws_region
  }
}