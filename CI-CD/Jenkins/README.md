# Deploying Flask application (Pension calculator) using Docker on Jenkins Pipeline

## Installation Instructions

1. Clone the repository:
   ```bash
   git clone REPO_URL
   ```

2. Navigate your Jenkins pipeline to the `Jenkinsfile` in this repository.

3. Set up necessary credentials in Jenkins:
   - **GitHub Credentials**: Create credentials for accessing your GitHub repository. 
   - **Docker Hub Credentials**: Create credentials for accessing Docker Hub. The credentials ID: **dockerhub-credentials**

## Usage

This repository provides the Jenkins pipeline scripts and configurations needed to automate your CI/CD workflows. Follow the installation steps and configure your Jenkins pipeline accordingly to use the `Jenkinsfile` in this repository.

## Requirements

- Jenkins server with docker plugin installed
- Access to GitHub and Docker Hub accounts with appropriate credentials
- Docker installed on the build environment if needed for Docker operations, or use Agents.

## Docker app access

- After build is succeeded, open your webserver IP or URL with port :5000 that was exposed in Docker.

## Python application of our Pension Calculator.

- We deployed the Flask app with our Pension Calculator.
- You can use any other application of Flask or other Frameworks by adding it to Docker file.

