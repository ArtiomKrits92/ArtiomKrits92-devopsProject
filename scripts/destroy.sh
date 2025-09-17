#!/bin/bash
# destroy script
# destroys the infrastructure

set -e

# script config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
TERRAFORM_DIR="$PROJECT_DIR/terraform"

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

# confirmation
confirm_destruction() {
    echo "DESTROY INFRASTRUCTURE"
    echo "This will DESTROY all AWS resources!"
    echo "Cannot be undone!"
    echo ""
    echo "Resources to be destroyed:"
    echo "- VPC and networking"
    echo "- EC2 instances"
    echo "- Load balancer"
    echo "- Security groups"
    echo "- All data"
    echo ""
    
    read -p "Continue? (type 'yes'): " confirmation
    
    if [ "$confirmation" != "yes" ]; then
        log "Destruction cancelled"
        exit 0
    fi
    
    log "Proceeding with destruction..."
}

# check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    if ! command -v terraform &> /dev/null; then
        log_error "Terraform not installed"
        exit 1
    fi
    
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS credentials not configured"
        exit 1
    fi
    
    log_success "Prerequisites OK"
}

# destroy terraform
destroy_terraform() {
    log "Starting terraform destruction..."
    
    cd "$TERRAFORM_DIR"
    
    if [ ! -d ".terraform" ]; then
        log "Initializing terraform..."
        terraform init
    fi
    
    terraform validate
    terraform plan -destroy -out=destroy.tfplan
    terraform apply destroy.tfplan
    
    log_success "Terraform destruction completed!"
}

# cleanup
cleanup() {
    log "Cleaning up..."
    
    cd "$TERRAFORM_DIR"
    
    rm -f tfplan destroy.tfplan
    
    log_success "Cleanup completed!"
}

# display results
display_results() {
    echo ""
    echo "DESTRUCTION COMPLETE"
    echo "All AWS resources destroyed!"
    echo ""
    echo "Note: S3 buckets and DynamoDB tables may still exist"
    echo "Check AWS console to manually delete if needed"
}

# main
main() {
    check_prerequisites
    confirm_destruction
    destroy_terraform
    cleanup
    display_results
    
    log_success "Destruction completed!"
}

main "$@"