#!/bin/bash

# Authenticate with AWS
echo "Authenticating with AWS CLI..."
aws configure

# User and policy details
IAM_USER_NAME="ritual-deployer"
POLICY_NAME="RitualNodeDeploymentPolicy"

# Create IAM user
echo "Creating IAM user..."
aws iam create-user --user-name $IAM_USER_NAME

# IAM Policy JSON
POLICY_DOCUMENT='{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:*",
                "iam:*",
                "ssm:*"
            ],
            "Resource": "*"
        }
    ]
}'

# Create custom IAM policy
echo "Creating custom IAM policy for Ritual..."
POLICY_ARN=$(aws iam create-policy --policy-name "$POLICY_NAME" --policy-document "$POLICY_DOCUMENT" --query 'Policy.Arn' --output text)

# Attach policy to the user
echo "Attaching custom policy to the user..."
aws iam attach-user-policy --user-name $IAM_USER_NAME --policy-arn $POLICY_ARN

# Create access key for the user
echo "Service account details:"
aws iam create-access-key --user-name $IAM_USER_NAME
