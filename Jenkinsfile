pipeline {
    agent any

    environment {
        AWS_REGION = 'ap-south-2'
        ECR_REPO = '661979762009.dkr.ecr.ap-south-2.amazonaws.com/devops_ci_cd_final_prac_6_clean'
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo 'Checking out github repo...'
                checkout scm
            }
        }

        stage('Build App Docker Image') {
            steps {
                sh 'docker build -t my-app:latest .'
            }
        }

        stage('Push to ECR') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'aws-username-pass-access-key',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) 
                {
                    sh 'aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPO}'
                    sh 'docker tag my-app:latest ${ECR_REPO}:latest'
                    sh 'docker push ${ECR_REPO}:latest'
                }
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
            echo 'Deployment successful!'
        }
        failure {
            echo 'Deployment failed!'
        }
        always {
            echo 'Cleaning up workspace...'
            cleanWs()
        }
    }
}