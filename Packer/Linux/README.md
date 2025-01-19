# Jenkins Linux Agent Packer Project

This project creates an Amazon Machine Image (AMI) for a Jenkins Linux agent using Packer. The AMI is built using the official Amazon Linux 2 base image and includes a variety of tools and dependencies necessary for a Jenkins agent.

## Installed Components

The following components are installed on the AMI:

### System Updates and Basic Tools

- **System Updates**: All system packages are updated to the latest versions.
- **Git**: Installed for version control.

### Docker

- **Docker**: Installed and configured to start on boot.
- **Docker Compose**: Installed and set up as a CLI plugin for Docker.

### Programming Languages and Package Managers

- **Python 3**: Installed along with pip.
- **Java 11**: Amazon Corretto 11 is installed for running Java applications.

### Infrastructure Tools

- **AWS CLI**: Installed for interacting with AWS services.
- **Terraform**: Installed for infrastructure as code.
- **Packer**: Installed from the HashiCorp repository.

### Kubernetes Tools

- **kubectl**: Kubernetes command-line tool installed.
- **Helm**: Kubernetes package manager installed.

### Security and Compliance

- **Checkov**: Installed for static code analysis of infrastructure as code.

### Additional Python Packages

- **jinja2schema**: Installed using pip for working with Jinja2 templates.

### Configuration and Cleanup

- **Disable repo upgrades**: Configured in `cloud.cfg` to prevent automatic upgrades.
- **Cleanup**: Temporary installation files are removed.

## Installation Process

The installation process is divided into two main scripts:

### `install_main.sh`

This script performs the initial setup, including:

- System updates
- Installing Git
- Installing Docker and enabling the service
- Installing Python 3 and pip
- Installing kubectl
- Installing Helm
- Installing AWS CLI
- Installing Terraform
- Installing Checkov
- Reinstalling urllib3 for compatibility
- Creating a symbolic link for Checkov
- Cleanup of temporary files
- Rebooting the system

### `install_second.sh`

This script performs additional configuration and installations:

- Running a Docker container to verify Docker installation
- Installing Docker Compose and setting it up as a CLI plugin
- Disabling repo upgrades in `cloud.cfg`
- Installing jinja2schema using pip
- Installing Java 11 (Amazon Corretto)
- Adding HashiCorp repository and installing Packer

## Usage

To build the AMI, ensure you have Packer installed and run the following command:

```sh
packer init .
packer build .

