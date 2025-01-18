@Library('my-shared-lib')
import com.cloudbees.tools

lib = new tools()
def ami_id = ''

pipeline {
    agent {
        label 'linux'
    }
    parameters {
        //Remove this if you don't want autoupdate your AMI of some label in Jenkins
        booleanParam  defaultValue: false, name: 'update_ami', description: "Check to update agent's ami-id in config"
    }
    stages {
        stage('Checkout Code') {
            steps {
                git changelog: false,
                    credentialsId: 'git_creds',
                    poll: false,
                    url: '{URL_2_YOUR_REPO}',
                    branch: 'linux-ami'
            }
        }

        stage('Build with Packer') {
            steps {
                    withCredentials([usernamePassword(credentialsId: 'aws-credentials',
                                                     passwordVariable: 'AWS_SECRET_ACCESS_KEY',
                                                     usernameVariable: 'AWS_ACCESS_KEY_ID'),]) {
                            script {
                                sh '''
                                packer init linux-ami.pkr.hcl
                                packer build linux-ami.pkr.hcl -machine-readable | tee packer-output.txt
                                '''
                                def manifest = readJSON file: 'manifest.json'
                                ami_id       = manifest.builds[0].artifact_id.split(':')[-1]
                                 }
                }
            }
        }
        stage('Update AMI') {
            // This step is require additional pipeline that triggers this one
            when {
                expression { return params.update_ami }
            }
            steps {
                script {
                    echo 'Updating image in account'
                    lib.updateEC2cloudAMI   cloud: 'ec2-agents',
                                            template: 'linux-ami',
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'packer-output.txt', fingerprint: false
            cleanWs()
        }
    }
}
