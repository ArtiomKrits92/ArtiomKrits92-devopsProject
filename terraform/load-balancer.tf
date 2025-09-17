# load balancer config
# creates the application load balancer

# application load balancer
resource "aws_lb" "main" {
  name = "${local.name_prefix}-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb.id]
  subnets = aws_subnet.public[*].id
  enable_deletion_protection = false

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb"
    Type = "Application Load Balancer"
    Purpose = "Distributes traffic to web servers"
  })
}

# target group
resource "aws_lb_target_group" "web_servers" {
  name = "${local.name_prefix}-web-tg"
  port = var.app_port
  protocol = "HTTP"
  vpc_id = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-web-tg"
    Type = "Target Group"
    Purpose = "Defines which instances receive traffic"
  })
}

# load balancer listener
resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.main.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_servers.arn
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-web-listener"
    Type = "Load Balancer Listener"
    Purpose = "Handles incoming HTTP requests"
  })
}

# target group attachment
resource "aws_lb_target_group_attachment" "web_servers" {
  count = var.web_server_count

  target_group_arn = aws_lb_target_group.web_servers.arn
  target_id = aws_instance.web_servers[count.index].id
  port = var.app_port
}

# outputs
output "load_balancer_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "load_balancer_zone_id" {
  description = "Zone ID of the load balancer"
  value       = aws_lb.main.zone_id
}

output "load_balancer_arn" {
  description = "ARN of the load balancer"
  value       = aws_lb.main.arn
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.web_servers.arn
}

output "application_url" {
  description = "URL to access the application"
  value       = "http://${aws_lb.main.dns_name}"
}