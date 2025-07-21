#!/bin/bash
set -e

# Script: build-and-push.sh
# Usage: ./scripts/build-and-push.sh <git-sha>

if [ $# -eq 0 ]; then
    echo "Error: Git SHA required"
    echo "Usage: $0 <git-sha>"
    exit 1
fi

GIT_SHA=$1
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION="us-west-2"

# Get ECR repository URL from Terraform output
cd terraform
ECR_REPO=$(terraform output -raw ecr_repository_url)
cd ..

# Build Docker image
echo "Building Docker image..."
docker build -t hello-world-app ./infrastructure

# Tag images
echo "Tagging images..."
docker tag hello-world-app:latest ${ECR_REPO}:latest
docker tag hello-world-app:latest ${ECR_REPO}:${GIT_SHA}

# Push images to ECR
echo "Pushing images to ECR..."
docker push ${ECR_REPO}:latest
docker push ${ECR_REPO}:${GIT_SHA}

echo "Successfully pushed images:"
echo "  - ${ECR_REPO}:latest"
echo "  - ${ECR_REPO}:${GIT_SHA}"
