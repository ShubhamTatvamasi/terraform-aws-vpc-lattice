#!/bin/bash

# Usage: ./set-security-group-rules.sh red
# $1 = color (blue | green | red)

# Check if color argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <color>"
  echo "Example: $0 blue"
  exit 1
fi

COLOR=$1
EKS_CLUSTER_NAME="eks-$COLOR"

# Get the AWS region from the AWS CLI configuration
AWS_REGION=$(aws configure get region)

# Get the security group ID associated with the EKS cluster
CLUSTER_SG=$(aws eks describe-cluster \
  --name "$EKS_CLUSTER_NAME" \
  --output json | jq -r '.cluster.resourcesVpcConfig.clusterSecurityGroupId')

# Get the prefix list ID for VPC Lattice and allow all traffic from it
PREFIX_LIST_ID=$(aws ec2 describe-managed-prefix-lists \
  --query "PrefixLists[?PrefixListName=='com.amazonaws.$AWS_REGION.vpc-lattice'].PrefixListId" \
  | jq -r '.[]')

# Allow all traffic from the VPC Lattice prefix list
aws ec2 authorize-security-group-ingress \
  --group-id "$CLUSTER_SG" \
  --ip-permissions "PrefixListIds=[{PrefixListId=${PREFIX_LIST_ID}}],IpProtocol=-1"

# Get the prefix list ID for VPC Lattice IPv6 and allow all traffic from it
PREFIX_LIST_ID_IPV6=$(aws ec2 describe-managed-prefix-lists \
  --query "PrefixLists[?PrefixListName=='com.amazonaws.$AWS_REGION.ipv6.vpc-lattice'].PrefixListId" \
  | jq -r '.[]')

# Allow all IPv6 traffic from the VPC Lattice IPv6 prefix list
aws ec2 authorize-security-group-ingress \
  --group-id "$CLUSTER_SG" \
  --ip-permissions "PrefixListIds=[{PrefixListId=${PREFIX_LIST_ID_IPV6}}],IpProtocol=-1"
