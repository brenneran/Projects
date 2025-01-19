# Terraform AWS Replicated Console with JAMA

This Terraform project deploys the Replicated Console with Docker, including Java, and integrates JAMA, the leading solution for Requirements Management and Traceability.

## Overview

The project automates the creation of AWS resources, including EC2 instances, RDS databases, security groups, Application Load Balancer, and Route53 resources.

## Prerequisites

Before you begin, make sure you have the following in place:

- AWS Account with appropriate permissions
- Terraform installed on your local machine
- AWS CLI credentials configured

## Variables
- region - AWS region where the resources will be deployed.
- instance_type - EC2 instance type for the Replicated Console.
- ami - Amazon Machine Image (AMI) ID for the EC2 instances.
- key_name - The name of the AWS Key Pair to use for EC2 instances.
- database_name - Name of the RDS database.
- database_username - Username for RDS database access.
- database_password - Password for the RDS database access.
- subnet_ids - List of subnet IDs for the EC2 instances.
- security_group_ids - List of security group IDs for the EC2 instances.
- vpc_id - ID of the Virtual Private Cloud (VPC) where the resources will be created.
- alb_listener_arn - ARN of the Application Load Balancer (ALB) listener.
- alb_security_group_id - Security Group ID for the ALB.

## Usage

1. Clone this repository to your local machine.
2. Navigate to the project directory.
3. Run `terraform init` to initialize the project.
4. Use `terraform apply` to create the AWS resources.
5. Follow the prompts to input necessary variables.

## Configuration

The project's configuration files are structured as follows:

- `main.tf`: Contains the main Terraform code for resource provisioning.
- `variables.tf`: Defines input variables and their descriptions.
- `outputs.tf`: Specifies the output variables to display after applying changes.

## License

This project is licensed under the [Jama Enterprise].

## Acknowledgments

- [Replicated](https://docs.replicated.com/) - For providing an excellent platform for deploying modern enterprise applications.
