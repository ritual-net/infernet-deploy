# Project

variable "gcp_credentials_file_path" {
  description = "Path to the GCP credentials file"
  type        = string
  default     = "terraform-deployer-key.json"
}

variable "service_account_email" {
  description = "Email address of the service account in the GCP credentials file."
  type        = string
}

variable "project" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The region where GCP resources will be created"
  type        = string
}

variable "zone" {
  description = "The zone where GCP resources will be created"
  type        = string
}

variable "deploy_router" {
  description = "Whether or not to deploy the router"
  type        = bool
  default     = false
}

# Nodes

variable "node_count" {
  description = "Number of nodes to create"
  type        = number
}

variable "instance_name" {
  description = "Name of the GCE instances"
  type        = string
}

# NOTE: needs to be N2D or C2D instance if using confidential computing is enabled,
# i.e. if is_confidential_compute is true
# e.g. "n2d-standard-2", "c2d-standard-4", etc.
# https://cloud.google.com/confidential-computing/confidential-vm/docs/os-and-machine-type#machine-type
variable "machine_type" {
  description = "The machine type of the GCE instance"
  type        = string
}

# See machine_type note above
variable "is_confidential_compute" {
  description = "whether or not confidential computing is enabled"
  type        = bool
  default     = false
}

variable "image" {
  description = "The image to use for the GCE instance"
  type        = string
}

variable "ip_allow_http" {
  description = "IP addresses and/or ranges to allow HTTP traffic from"
  type	      = list(string)
}

variable"ip_allow_http_ports" {
  description = "Ports that accept HTTP traffic"
  type	      = list(string)
}

variable "ip_allow_ssh" {
  description = "IP addresses and/or ranges to allow SSH access from"
  type        = list(string)
}

variable "is_production" {
  description = "Whether or not this is a production deployment"
  type        = bool
  default     = false
}
