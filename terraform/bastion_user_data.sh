#!/bin/bash
# bastion host user data script
# sets up bastion for ssh access

set -e

# system update and package installation
echo "Starting bastion host setup..."
yum update -y

echo "Installing required packages..."
yum install -y \
    htop \
    wget \
    curl \
    git \
    tree \
    vim \
    unzip

# ssh configuration
echo "Configuring SSH..."
mkdir -p /home/ec2-user/.ssh
chown ec2-user:ec2-user /home/ec2-user/.ssh
chmod 700 /home/ec2-user/.ssh

# ssh client config
cat > /home/ec2-user/.ssh/config << EOF
Host *
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    ServerAliveInterval 60
    ServerAliveCountMax 3
EOF

chown ec2-user:ec2-user /home/ec2-user/.ssh/config
chmod 600 /home/ec2-user/.ssh/config

# install network tools
echo "Installing network tools..."
yum install -y \
    telnet \
    nc \
    nmap \
    tcpdump \
    netstat-nat

# install monitoring tools
echo "Installing monitoring tools..."
yum install -y \
    htop \
    iotop \
    nethogs \
    iftop

# install aws cli
echo "Installing AWS CLI..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip

# install terraform
echo "Installing Terraform..."
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
mv terraform /usr/local/bin/
rm terraform_1.6.0_linux_amd64.zip

# install ansible
echo "Installing Ansible..."
yum install -y epel-release
yum install -y ansible

# create welcome message
cat > /home/ec2-user/welcome.txt << EOF
BASTION HOST - ${project_name}

This bastion host provides SSH access to your private instances.

Available tools:
- AWS CLI: aws --version
- Terraform: terraform --version
- Ansible: ansible --version
- Network tools: telnet, nc, nmap, tcpdump
- Monitoring: htop, iotop, nethogs, iftop

To connect to web servers:
1. First, get the private IPs from Terraform outputs
2. SSH to this bastion: ssh -i your-key.pem ec2-user@$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
3. Then SSH to web servers: ssh ec2-user@<private-ip>

Project: ${project_name}
Setup completed: $(date)
EOF

chown ec2-user:ec2-user /home/ec2-user/welcome.txt

# setup logging
mkdir -p /var/log/bastion
chown ec2-user:ec2-user /var/log/bastion

echo "Bastion host setup completed!"
echo "Welcome message created at /home/ec2-user/welcome.txt"