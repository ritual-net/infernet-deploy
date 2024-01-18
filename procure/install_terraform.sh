#!/bin/bash

# General Update
sudo apt update
sudo apt upgrade

# Base deps
sudo apt install curl software-properties-common make

# Hashicorp
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

# Installing terraform
sudo apt update
sudo apt install terraform

# Verifying version
terraform version
