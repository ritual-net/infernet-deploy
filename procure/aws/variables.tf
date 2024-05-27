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

/**
  * In AWS, to deploy in different regions, we need a different provider block
  * for each region. This is because the region is a required field in the provider
  * block, and we cannot use variables in the provider block (or for_each, etc.)
  * Therefore, we allow multi-zone deployments within the same region, but we restrict
  * the region to a single value.
  */
variable "region" {
  description = "The region where AWS resources will be created"
  type        = string
}

# Nodes

variable "nodes" {
  description = "Map of node IDs to node configurations"
  type = map(object({
    zone         = string
    machine_type = string
    image        = string
    has_gpu      = bool
  }))
}

variable "router" {
  description = "The router configuration"
  type = object({
    deploy       = bool
    zone         = optional(string, "us-east-1a")
    machine_type = optional(string, "t2.small")
    image        = optional(string, "ami-0b4750268a88e78e0")
  })
}

variable "name" {
  description = "Name of the Cluster"
  type        = string
}

variable "ip_allow_http" {
  description = "IP addresses and/or ranges to allow HTTP traffic from"
  type        = list(string)
}

variable "ip_allow_http_from_port" {
  description = "Ports that accept HTTP traffic. Start of range."
  type        = number
}

variable "ip_allow_http_to_port" {
  description = "Ports that accept HTTP traffic. End of range."
  type        = number
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
