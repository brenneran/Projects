#!/bin/bash

# Update system packages
sudo yum -y update

# Install git
sudo yum -y install git
git --version

# Install Docker
sudo yum -y install docker

# Install Python3
sudo yum -y install python3
python3 --version

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client=true

# Install Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
helm version

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version

# Install Terraform
wget https://releases.hashicorp.com/terraform/1.7.3/terraform_1.7.3_linux_amd64.zip
sudo unzip terraform_1.7.3_linux_amd64.zip
sudo mv terraform /usr/bin/
terraform --version

# Enable and start Docker service
sudo systemctl enable docker
sudo systemctl start docker

# Add current user to Docker group
sudo usermod -aG docker $USER

# Install Checkov
export PATH="$PATH:/home/ec2-user/.local/bin"
echo 'export PATH=$PATH:/home/ec2-user/.local/bin' >> ~/.bash_profile
# Refresh the shell session
source ~/.bash_profile
pip3 install checkov --use-feature=2020-resolver
checkov --version

# Reinstall urllib3 (needed for compatibility)
pip3 install --force-reinstall urllib3==1.26.6

# Create symbolic link for Checkov
sudo ln -s ~/.local/bin/checkov /usr/bin/checkov

# Cleanup
sudo rm -rf aws awscliv2.zip get_helm.sh kubectl terraform_1.1.7_linux_amd64.zip

# Reboot
sudo reboot now