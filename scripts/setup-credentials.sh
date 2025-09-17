#!/bin/bash
# setup credentials script
# helps set up aws credentials

set -e

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

# check aws cli
check_aws_cli() {
    log "Checking AWS CLI..."
    
    if command -v aws &> /dev/null; then
        AWS_VERSION=$(aws --version 2>&1 | cut -d' ' -f1 | cut -d'/' -f2)
        log_success "AWS CLI installed (version: $AWS_VERSION)"
    else
        log_error "AWS CLI not installed!"
        echo ""
        echo "Install AWS CLI:"
        echo "  macOS: brew install awscli"
        echo "  Linux: curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o 'awscliv2.zip' && unzip awscliv2.zip && sudo ./aws/install"
        exit 1
    fi
}

# check aws credentials
check_aws_credentials() {
    log "Checking AWS credentials..."
    
    if aws sts get-caller-identity &> /dev/null; then
        ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
        USER_ARN=$(aws sts get-caller-identity --query Arn --output text)
        log_success "AWS credentials configured!"
        log "Account ID: $ACCOUNT_ID"
        log "User: $USER_ARN"
    else
        log_error "AWS credentials not configured!"
        echo ""
        echo "Configure AWS credentials:"
        echo "  1. Run: aws configure"
        echo "  2. Enter AWS Access Key ID"
        echo "  3. Enter AWS Secret Access Key"
        echo "  4. Enter region (e.g., us-east-1)"
        echo "  5. Enter output format (e.g., json)"
        echo ""
        echo "For AWS Academy:"
        echo "  1. Go to AWS Academy"
        echo "  2. Click lab"
        echo "  3. Click 'AWS Details'"
        echo "  4. Click 'Show' next to 'Command line access'"
        echo "  5. Copy export commands and run them"
        exit 1
    fi
}

# check required tools
check_required_tools() {
    log "Checking required tools..."
    
    if command -v terraform &> /dev/null; then
        TERRAFORM_VERSION=$(terraform --version | head -n1 | cut -d' ' -f2)
        log_success "Terraform installed (version: $TERRAFORM_VERSION)"
    else
        log_error "Terraform not installed!"
        echo ""
        echo "Install Terraform:"
        echo "  macOS: brew install terraform"
        echo "  Linux: wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip && unzip terraform_1.6.0_linux_amd64.zip && sudo mv terraform /usr/local/bin/"
        exit 1
    fi
    
    if command -v ansible &> /dev/null; then
        ANSIBLE_VERSION=$(ansible --version | head -n1 | cut -d' ' -f2)
        log_success "Ansible installed (version: $ANSIBLE_VERSION)"
    else
        log_error "Ansible not installed!"
        echo ""
        echo "Install Ansible:"
        echo "  macOS: brew install ansible"
        echo "  Linux: sudo yum install ansible (or sudo apt install ansible)"
        exit 1
    fi
}

# check ssh key
check_ssh_key() {
    log "Checking SSH key..."
    
    SSH_KEY_PATH="$HOME/.ssh/devops-learning-key.pem"
    
    if [ -f "$SSH_KEY_PATH" ]; then
        log_success "SSH key found at $SSH_KEY_PATH"
        chmod 400 "$SSH_KEY_PATH"
    else
        log_warning "SSH key not found at $SSH_KEY_PATH"
        echo ""
        echo "Download SSH key from AWS:"
        echo "  1. Go to AWS Console > EC2 > Key Pairs"
        echo "  2. Find 'devops-learning-key'"
        echo "  3. Download .pem file"
        echo "  4. Save as $SSH_KEY_PATH"
        echo "  5. Run: chmod 400 $SSH_KEY_PATH"
    fi
}

# check aws region
check_aws_region() {
    log "Checking AWS region..."
    
    CURRENT_REGION=$(aws configure get region)
    
    if [ -z "$CURRENT_REGION" ]; then
        log_warning "No default region set!"
        echo ""
        echo "Set default region:"
        echo "  aws configure set region us-east-1"
    else
        log_success "AWS region: $CURRENT_REGION"
    fi
}

# display next steps
display_next_steps() {
    echo ""
    echo "SETUP COMPLETE!"
    echo "Ready for deployment!"
    echo ""
    echo "Next steps:"
    echo "1. Deploy: ./scripts/deploy.sh"
    echo "2. Or terraform: cd terraform && terraform apply"
    echo "3. Or ansible: cd ansible && ansible-playbook -i inventory/aws_ec2.yml playbooks/setup-webservers.yml"
    echo ""
    echo "To destroy: ./scripts/destroy.sh"
}

# main
main() {
    echo "DEVOPS PROJECT SETUP"
    echo "Checking environment and getting ready to deploy"
    echo ""
    
    check_aws_cli
    check_aws_credentials
    check_required_tools
    check_ssh_key
    check_aws_region
    
    display_next_steps
    
    log_success "Setup completed!"
}

main "$@"