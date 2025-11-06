pipeline {
    agent any

    environment {
        AWS_REGION = 'ap-south-2'
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo 'Checking out github repo...'
                checkout scm
            }
        }

        stage('Provision Infrastrucutre using Terraform') {
            steps {
                echo 'Running terraform to provision infrastructure...'
                withCredentials([
                    usernamePassword(
                        credentialsId: 'aws-username-pass-access-key',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) 
                {
                    dir('terraform') {
                        sh 'export AWS_DEFAULT_REGION=${AWS_REGION}'
                        sh 'export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}'
                        sh 'export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}'
                        sh 'terraform init -reconfigure'
                        sh 'terraform plan'
                        sh 'terraform apply -auto-approve'
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Deployment successful!!'
        }
        failure {
            echo 'Deployment failed!!'
        }
        always {
            echo 'Cleaning up workspace...'
            cleanWs()
        }
    }
}