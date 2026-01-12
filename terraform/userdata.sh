#!/bin/bash
# Update system
apt update -y 

# Installing Docker
apt install -y docker.io
systemctl enable docker
systemctl start docker

# Installing docker compose
mkdir -p ~/.docker/cli-plugins

curl -SL https://github.com/docker/compose/releases/download/v2.27.0/docker-compose-linux-x86_64 \
  -o ~/.docker/cli-plugins/docker-compose

chmod +x ~/.docker/cli-plugins/docker-compose


# Installing AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Add ubuntu user to docker group (so we don't need sudo)
usermod -aG docker ubuntu
# After this we need to logout and login back so that ubuntu user can pickup new group membership
# Yes ✅ — the ubuntu user is already in the docker group, but existing shell sessions don’t pick up new group membership automatically, so you still get “permission denied” until you start a new session or run newgrp docker.
# Because your current shell hasn’t applied the new group membership — you need to log out and log back in (or newgrp docker) for ubuntu to use Docker without sudo.

# Create a project directory
mkdir -p ~/app
cd ~/app

# Get Docker Compose file from GitHub (Replace your URL)
# Note: Use the 'raw' URL of your docker-compose.yml
curl -O https://raw.githubusercontent.com/ShobhitBatra/ci-cd-project/refs/heads/main/docker-compose.yml


# Get AWS Account ID dynamically via STS
# Set environment variables for AWS
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export AWS_REGION="ap-south-1"

# Login to ECR
aws ecr get-login-password --region $AWS_REGION | \
docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

export ECR_REPO_FE="frontend-repo"
export ECR_REPO_BE="backend-repo"

# Pull images from ECR
docker pull $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_FE:latest
docker pull $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_BE:latest

# Run containers
docker compose up -d