#!/bin/bash
# Update system
apt update -y 

# Install Docker, Docker compose, aws cli
apt install -y docker.io docker-compose-plugin awscli
systemctl start docker
systemctl enable docker

# Get AWS Account ID dynamically via STS
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION="ap-south-1"

# Login to ECR
aws ecr get-login-password --region $REGION | \
docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

ECR_REPO_FE="frontend-repo"
ECR_REPO_BE="backend-repo"

# Pull images
docker pull $AWS_ACCOUNT_ID.dkr.ecr.ap-south-1.amazonaws.com/$ECR_REPO_FE:latest
docker pull $AWS_ACCOUNT_ID.dkr.ecr.ap-south-1.amazonaws.com/$ECR_REPO_BE:latest

# Run containers
# docker compose -f /home/ubuntu/docker-compose.yml up -d