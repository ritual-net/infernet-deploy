SHELL := /bin/bash

# Define the Terraform command
TERRAFORM_CMD := terraform

# Define phony targets
.PHONY: install init plan apply destroy

# Define the install target to run the install_terraform.sh script
install:
	@echo "Running install_terraform.sh script..."
	chmod +x ../install_terraform.sh
	../install_terraform.sh

# Common target for provider check
check-provider:
	@[[ "$(provider)" == "aws" || "$(provider)" == "gcp" ]] || (echo "Usage: make [target] provider={aws, gcp}" && exit 1)

# Define the init target
init: check-provider
	@echo "Initializing Terraform..."
	$(TERRAFORM_CMD) -chdir=$(provider) init

# Define the plan target
plan: check-provider
	@echo "Preparing deployment files..."
	@chmod +x prepare_files.sh
	@./prepare_files.sh
	@echo "Generating Terraform plan..."
	$(TERRAFORM_CMD) -chdir=$(provider) plan

# Define the apply target
apply: check-provider
	@echo "Preparing deployment files..."
	@chmod +x prepare_files.sh
	@./prepare_files.sh
	@echo "Applying Terraform changes..."
	@$(TERRAFORM_CMD) -chdir=$(provider) apply

# Define the destroy target
destroy: check-provider
	@echo "Destroying Terraform resources..."
	@$(TERRAFORM_CMD) -chdir=$(provider) destroy
