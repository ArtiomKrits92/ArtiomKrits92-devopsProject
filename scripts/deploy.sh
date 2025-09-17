#!/bin/bash
# deploy script
# deploys the complete infrastructure

set -e

# script config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
TERRAFORM_DIR="$PROJECT_DIR/terraform"
ANSIBLE_DIR="$PROJECT_DIR/ansible"

# colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# logging
log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI not installed"
        exit 1
    fi
    
    if ! command -v terraform &> /dev/null; then
        log_error "Terraform not installed"
        exit 1
    fi
    
    if ! command -v ansible &> /dev/null; then
        log_error "Ansible not installed"
        exit 1
    fi
    
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS credentials not configured"
        exit 1
    fi
    
    log_success "All prerequisites met!"
}

# deploy terraform
deploy_terraform() {
    log "Starting terraform deployment..."
    
    cd "$TERRAFORM_DIR"
    
    terraform init
    terraform validate
    terraform plan -out=tfplan
    terraform apply tfplan
    
    log_success "Terraform deployment completed!"
}

# deploy ansible
deploy_ansible() {
    log "Starting ansible deployment..."
    
    cd "$ANSIBLE_DIR"
    
    sleep 30
    
    ansible-playbook -i inventory/aws_ec2.yml playbooks/setup-webservers.yml
    
    log_success "Ansible deployment completed!"
}

# display results
display_results() {
    log "Deployment completed!"
    
    cd "$TERRAFORM_DIR"
    
    LB_URL=$(terraform output -raw application_url 2>/dev/null || echo "Not available")
    BASTION_IP=$(terraform output -raw bastion_public_ip 2>/dev/null || echo "Not available")
    
    echo ""
    echo "DEPLOYMENT SUMMARY"
    echo "Application URL: $LB_URL"
    echo "Bastion Host IP: $BASTION_IP"
    echo ""
    echo "To access your application:"
    echo "1. Open browser: $LB_URL"
    echo "2. SSH to instances: ssh -i your-key.pem ec2-user@$BASTION_IP"
    echo ""
    echo "To destroy: ./scripts/destroy.sh"
}

# main
main() {
    echo "DEVOPS PROJECT DEPLOYMENT"
    echo "Deploying infrastructure with terraform and ansible"
    echo ""
    
    check_prerequisites
    deploy_terraform
    deploy_ansible
    display_results
    
    log_success "Deployment completed successfully!"
}

main "$@"