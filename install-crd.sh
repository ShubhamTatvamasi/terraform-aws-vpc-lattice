#!/bin/bash

# EKS_CLUSTER_NAME="eks-blue"
# CLUSTER_VPC_ID=$(terraform output -raw blue_vpc_id)

EKS_CLUSTER_NAME="eks-green"
CLUSTER_VPC_ID=$(terraform output -raw green_vpc_id)

SERVICE_NETWORK=nginx-blue-green-sn
LATTICE_IAM_ROLE=$(aws iam get-role --role-name VPCLatticeRole --query "Role.Arn" --output text)
AWS_REGION=$(aws configure get region)
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.0/standard-install.yaml

aws ecr-public get-login-password --region us-east-1 \
  | helm registry login --username AWS --password-stdin public.ecr.aws

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
