pipeline {
    agent any
    environment {
        AWS_ACCOUNT_ID = credentials('AWS_ACCOUNT_ID')
        AWS_REGION     = credentials('AWS_REGION')
        ECR_REPO_FE    = 'frontend-repo'
        ECR_REPO_BE    = 'backend-repo'
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }
    
    stages {
        stage('checkout code') {
            steps {
                git branch: 'main', url: 'https://github.com/ShobhitBatra/ci-cd-project.git'
            }
        }

        stage('Build Docker images'){
            steps{
                // Build frontend
                dir('frontend'){
                    sh "docker build -t frontend-app:${env.BUILD_ID} ."
                }

                // Build Backend
                dir('backend') {
                    sh "docker build -t backend-app:${env.BUILD_ID} ."
                }
            }
        }

        // Aap login ke baad bhi kar sakte hain, lekin logical flow mein pehle "Ghar" (Repo) banta hai, phir "Entry" (Login) hoti hai aur phir "Saman" (Images) rakha jata hai.
        stage('Create ECR Repo') {
            steps {
                // 1. Create Repositories if they don't exist
                sh "aws ecr describe-repositories --repository-names ${ECR_REPO_FE} || aws ecr create-repository --repository-name ${ECR_REPO_FE}"
                sh "aws ecr describe-repositories --repository-names ${ECR_REPO_BE} || aws ecr create-repository --repository-name ${ECR_REPO_BE}"
            }
        }

         stage('Push to ECR'){
            steps{
                script{
                    // 1. ECR Login
                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

                    // 2. Tag and Push Frontend
                    sh "docker tag frontend-app:${env.BUILD_ID} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_FE}:latest"
                    sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_FE}:latest"

                    // 3. Tag and Push Backend
                    sh "docker tag backend-app:${env.BUILD_ID} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_BE}:latest"
                    sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_BE}:latest"
                }
                
            }
        }

         stage('Creating infra using Terraform'){
            steps{
                dir('terraform'){
                    sh 'terraform init'
                    sh 'terraform plan'
                    sh 'terraform apply --auto-approve'
                }
            }
        }

    }
}


        // stage('Copy Compose File to EC2'){
        //     steps {
        //         sh """
        //         scp -o StrictHostKeyChecking=no docker-compose.yml ubuntu@${EC2_IP}:/home/ubuntu/
        //         """
        //     }
        // }
