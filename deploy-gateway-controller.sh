#!/bin/bash

# Usage: ./deploy-gateway-controller.sh red
# $1 = color (blue | green | red)

# Check if color argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <color>"
  echo "Example: $0 blue"
  exit 1
fi

COLOR=$1
EKS_CLUSTER_NAME="eks-$COLOR"
CLUSTER_VPC_ID=$(terraform output -raw "${COLOR}_vpc_id")

SERVICE_NETWORK="nginx-blue-green-sn"
LATTICE_IAM_ROLE=$(aws iam get-role --role-name VPCLatticeRole --query "Role.Arn" --output text)
AWS_REGION=$(aws configure get region)
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Install Gateway API CRDs
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.0/standard-install.yaml

# Authenticate Helm to AWS Public ECR
aws ecr-public get-login-password --region us-east-1 \
  | helm registry login --username AWS --password-stdin public.ecr.aws

# Deploy AWS Gateway Controller for VPC Lattice
helm upgrade -i gateway-api-controller \
    oci://public.ecr.aws/aws-application-networking-k8s/aws-gateway-controller-chart \
    --version=v1.1.5 \
    --create-namespace \
    --set=deployment.replicas=1 \
    --set=awsRegion=${AWS_REGION} \
    --set=clusterVpcId=${CLUSTER_VPC_ID} \
    --set=clusterName=${EKS_CLUSTER_NAME} \
    --set=defaultServiceNetwork=${SERVICE_NETWORK} \
    --set=awsAccountId=${AWS_ACCOUNT_ID} \
    --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="$LATTICE_IAM_ROLE" \
    --namespace gateway-api-controller
