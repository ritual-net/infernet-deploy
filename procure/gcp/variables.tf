# Project

variable "gcp_credentials_file_path" {
  description = "Path to the GCP credentials file"
  type        = string
  default     = "ritual-deployer-key.json"
}

variable "service_account_email" {
  description = "Email address of the service account in the GCP credentials file."
  type        = string
}

variable "project" {
  description = "The GCP project ID"
  type        = string
}

variable "name" {
  description = "Name of the Cluster"
  type        = string
}

# Nodes

# NOTE: needs to be N2D or C2D instance if using confidential computing is enabled,
# i.e. if is_confidential_compute is true
# e.g. "n2d-standard-2", "c2d-standard-4", etc.
# https://cloud.google.com/confidential-computing/confidential-vm/docs/os-and-machine-type#machine-type
variable "nodes" {
  description = "Map of node IDs to node configurations"
  type = map(object({
    region               = string
    zone                 = string
    machine_type         = string
    image                = string
    gpu_type             = optional(string, "")
    gpu_count            = optional(number, 0)
    confidential_compute = optional(bool, false)
  }))
}

variable "router" {
  description = "The router configuration"
  type = object({
    deploy       = bool
    region       = optional(string, "us-east1")
    zone         = optional(string, "us-east1-a")
    machine_type = optional(string, "e2-small")
    image        = optional(string, "ubuntu-2004-focal-v20231101")
  })
}

variable "ip_allow_http" {
  description = "IP addresses and/or ranges to allow HTTP traffic from"
  type        = list(string)
}

variable "ip_allow_http_ports" {
  description = "Ports that accept HTTP traffic"
  type        = list(string)
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
