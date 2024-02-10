# Project

variable "access_key_id" {
  description = "AWS_ACCESS_KEY_ID for the AWS account"
  type        = string
}

variable "secret_access_key" {
  description = "AWS_SECRET_ACCESS_KEY for the AWS account"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "The region where AWS resources will be created"
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
  description = "The machine type of the EC2 instance"
  type        = string
}

variable "image" {
  description = "The image to use for the EC2 instance"
  type        = string
}

variable "ip_allow_http" {
  description = "IP addresses and/or ranges to allow HTTP traffic from"
  type	      = list(string)
}

variable "ip_allow_http_from_port" {
  description = "Ports that accept HTTP traffic. Start of range."
  type	      = number
}

variable "ip_allow_http_to_port" {
  description = "Ports that accept HTTP traffic. End of range."
  type	      = number
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
