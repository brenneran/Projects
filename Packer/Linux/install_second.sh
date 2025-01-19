#!/bin/bash

# Sleep for 15 seconds
sleep 15

# Run a Docker container to ensure Docker is working
docker run hello-world

# Install Docker Compose
sudo curl -SL https://github.com/docker/compose/releases/download/v2.6.1/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
sudo chmod a+x /usr/local/bin/docker-compose

# Create directory for Docker CLI plugins
mkdir -p /home/ec2-user/.docker/cli-plugins

# Create symbolic link for Docker Compose CLI plugin
ln -sfn /usr/local/bin/docker-compose ~/.docker/cli-plugins/docker-compose

# Check Docker Compose version
docker compose version

# Disable repo upgrades in cloud.cfg
sudo sed -i 's/repo_upgrade: security/repo_upgrade: none/g' /etc/cloud/cloud.cfg

# Install jinja2schema
pip3 install jinja2schema
pip3 freeze | grep jinja2schema

# Install Java 11 (Amazon Corretto)
sudo yum -y install java-11-amazon-corretto
javac -version

# Add HashiCorp repository and install Packer
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install packer
packer version