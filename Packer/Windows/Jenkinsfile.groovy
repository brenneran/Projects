@Library('Utils')
import com.cd.cd_utils
lib = new cd_utils()
import com.cloudbees.tools

yal = new tools()
def ami_id = ''

pipeline {
    agent {
        label 'windows-packer'
    }
    parameters {
        booleanParam  defaultValue: false,     name: 'Update AMI for Windows', description: "Check to update agent's ami-id in config"
    }
    stages {
        stage('Checkout Code') {
            steps {
                script {
                    checkout([$class: 'GitSCM',
                              branches: [[name: env.GIT_BRANCH]],
                              doGenerateSubmoduleConfigurations: false,
                              submoduleCfg: [],
                              userRemoteConfigs: [[credentialsId: 'repo_creds', url: 'REPO_URL']]])
                }
            }
        }

        stage('Build with Packer') {
            steps {
                dir('win-ami-build') {
                    withCredentials([usernamePassword(credentialsId: 'aws-credentials', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID'),
                                     usernamePassword(credentialsId: 'conan_creds', passwordVariable: 'CONAN_PASSWORD', usernameVariable: 'CONAN_USER'),
                                     sshUserPrivateKey(credentialsId: 'packer_user-ssh', keyFileVariable: 'SSH_AGENT'),
                                     usernamePassword(credentialsId: 'aws-cloud-hsm-creds', passwordVariable: 'HSM_PASSWORD', usernameVariable: 'HSM_USER'),]) {
                            script {
                                bat '''
                                packer init packer-for-win.pkr.hcl
                                packer build -machine-readable -var="hsm_u=%HSM_USER%" -var="hsm_p=%HSM_PASSWORD%" -var="conan_u=%CONAN_USER%" -var="conan_p=%CONAN_PASSWORD%" packer-for-win.pkr.hcl
                                '''
                                def manifest = readJSON file: 'manifest.json'
                                ami_id       = manifest.builds[0].artifact_id.split(':')[-1]
                            }
                                     }
                }
            }
        }
        stage('Update AMI') {
            when {
                expression { return params.update_ami }
            }
            steps {
                script {
                    echo 'Updating image in infra-dev account'
                    yal.updateEC2cloudAMI   cloud: 'Atlas',
                                            template: 'win-ami-build-tests',
                                            ami: ami_id
                }
            }
        }
    }

    post {
        always {
            // archiveArtifacts artifacts: 'win-ami-build-test/packer-output.txt', fingerprint: true
            cleanWs()
        }
    }
}
