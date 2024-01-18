#!/bin/bash

echo "Authenticating with Google Cloud..."
gcloud auth login

# Set your GCP project ID
read -p "Enter your GCP Project ID: " PROJECT_ID
gcloud config set project $PROJECT_ID

# Service Account details
SA_NAME="ritual-deployer"
SA_DISPLAY_NAME="Ritual Deployer Service Account"

# Create the service account in the specified project
echo "Creating service account..."
gcloud iam service-accounts create $SA_NAME --display-name "$SA_DISPLAY_NAME"

# Assign roles to the service account
echo "Assigning roles to the service account..."
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member "serviceAccount:$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
    --role "roles/compute.admin" &> /dev/null
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member "serviceAccount:$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
    --role "roles/iam.serviceAccountUser" &> /dev/null
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member "serviceAccount:$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
    --role "roles/resourcemanager.projectIamAdmin" &> /dev/null

# Create key file for the service account
echo "Creating key file..."
gcloud iam service-accounts keys create "$SA_NAME-key.json" \
    --iam-account "$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com"

echo "Service account and key file created successfully."
echo "Key file: $PWD/$SA_NAME-key.json"

echo "Service account details:"
cat $PWD/$SA_NAME-key.json
