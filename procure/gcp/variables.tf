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

variable "nodes" {
  description = "Map of node IDs to node names"
  type = map(string)
}

variable "name" {
  description = "Name of the Cluster"
  type        = string
}

variable "machine_type" {
  description = "The machine type of the GCE instances"
  type        = string
}

variable "image" {
  description = "The image to use for the GCE instance"
  type        = string
}

variable "ip_allow_http" {
  description = "IP addresses and/or ranges to allow HTTP traffic from"
  type	      = list(string)
}

variable "ip_allow_http_ports" {
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
