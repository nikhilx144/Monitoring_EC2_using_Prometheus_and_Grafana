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

        stage('Wait for EC2 to be Ready') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'aws-username-pass-access-key',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    ),
                    sshUserPrivateKey(
                        credentialsId: 'ec2-ssh-key',
                        keyFileVariable: 'KEY_FILE'
                    )
                ]) 
                {
                    script {
                        sh 'export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID'
                        sh 'export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY'
                        sh 'export AWS_DEFAULT_REGION=${AWS_REGION}'

                        def EC2_PUBLIC_IP = sh (
                            script: "cd terraform && terraform output -raw ec2_public_ip",
                            returnStdout: true
                        ).trim()

                        echo "⏳ Waiting for EC2 to finish cloud-init..."

                        sh """
                        ssh -i $KEY_FILE -o StrictHostKeyChecking=no ec2-user@${EC2_PUBLIC_IP} '
                            echo "Checking readiness..."

                            # Wait for docker to be installed and daemon ready
                            until command -v docker >/dev/null 2>&1; do
                                echo "Docker not installed yet... waiting"
                                sleep 5
                            done

                            until sudo docker ps >/dev/null 2>&1; do
                                echo "Docker daemon not ready... waiting"
                                sleep 5
                            done

                            # Wait for docker-compose to be installed
                            until command -v docker-compose >/dev/null 2>&1; do
                                echo "docker-compose not installed yet... waiting"
                                sleep 5
                            done

                            # Wait for user-data to create the directory
                            until [ -d /opt/monitoring ]; do
                                echo "/opt/monitoring directory missing... waiting"
                                sleep 5
                            done

                            echo "✅ EC2 is fully ready!"
                        '
                        """
                    }
                }
            }
        }

        stage('Deploy Latest App to EC2') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'aws-username-pass-access-key',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    ),
                    sshUserPrivateKey(
                        credentialsId: 'ec2-ssh-key',
                        keyFileVariable: 'KEY_FILE'
                    )
                ]) {
                    script {
                        def EC2_PUBLIC_IP = sh (
                            script: "cd terraform && terraform output -raw ec2_public_ip",
                            returnStdout: true
                        ).trim()
                        
                        sh """
                        ssh -i $KEY_FILE -o StrictHostKeyChecking=no ec2-user@${EC2_PUBLIC_IP} '
                            aws ecr get-login-password --region ${AWS_REGION} | sudo docker login --username AWS --password-stdin ${ECR_REPO}
                            cd /opt/monitoring
                            sudo docker-compose pull app
                            sudo docker-compose up -d app
                        '
                        """
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