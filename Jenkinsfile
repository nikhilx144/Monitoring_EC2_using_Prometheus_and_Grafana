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
                withCredentials([usernamePassword(
                    credentialsId: 'aws_credentials', 
                    usernameVariable:'AWS_ACCESS_KEY_ID' , 
                    passwordVariable:'AWS_SECRET_ACCESS_KEY'
                    )
                ]) 
                {
                    dir('terraform') {
                        export AWS_DEFAULT_REGION=${AWS_REGION}
                        export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                        export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                        
                        sh 'terraform init -reconfigure'
                        sh 'terraform plan'
                        sh 'terraform apply -auto-approve'
                    }
                }
            }
        }

        stage('Terraform Output') {
            steps {
                dir('terraform') { 
                    echo 'EC2 Public IP and DNS:'
                    sh 'terraform output ec2_public_ip || true'
                    sh 'terraform output ec2_public_dns || true'
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