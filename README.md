# DevOps Project

## What this is

A web application deployment using Terraform for infrastructure and Ansible for configuration management.

## How it works

Terraform creates the AWS infrastructure, Ansible configures the servers. The infrastructure includes a VPC with public/private subnets, load balancer, and web servers running a Flask application.

## Project structure

```
├── terraform/     # infrastructure code
├── ansible/       # server configuration
├── scripts/       # deployment scripts
├── app/           # web application
└── README.md
```

## Files

### terraform/main.tf
Basic terraform configuration with provider setup and variables.

### terraform/vpc.tf  
Creates the VPC and subnets with proper networking configuration.

### terraform/ec2.tf
Creates the EC2 instances for web servers and bastion host.

### terraform/security-groups.tf
Defines security groups for load balancer, web servers, and bastion host.

### terraform/load-balancer.tf
Sets up the application load balancer with target groups and health checks.

### terraform/variables.tf
All configurable settings for the infrastructure.

### ansible/playbooks/setup-webservers.yml
Configures the web servers - installs Python, Flask, and sets up the application.

### ansible/roles/webserver/
Reusable ansible code for web server configuration.

### scripts/deploy.sh
Main deployment script that runs terraform and ansible.

### scripts/destroy.sh
Cleanup script for removing all resources.

### scripts/setup-credentials.sh
Helper script for AWS credential setup.

## How to deploy

1. Get AWS credentials from AWS Academy
2. Set up environment:
   ```bash
   export AWS_ACCESS_KEY_ID=your-key
   export AWS_SECRET_ACCESS_KEY=your-secret  
   export AWS_SESSION_TOKEN=your-token
   export AWS_DEFAULT_REGION=us-east-1
   ```
3. Run deployment:
   ```bash
   ./scripts/deploy.sh
   ```

## Usage

```bash
# Deploy everything
./scripts/deploy.sh

# Destroy everything
./scripts/destroy.sh

# Just terraform
cd terraform && terraform apply

# Just ansible
cd ansible && ansible-playbook -i inventory/aws_ec2.yml playbooks/setup-webservers.yml
```