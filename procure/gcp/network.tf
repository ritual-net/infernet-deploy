locals {
  # Extract all regions and include router, ensuring uniqueness
  all_regions = toset(concat([for node in var.nodes : node.region], [var.router.region]))

  # Generate unique CIDR blocks for each zone.
  subnets_cidr = { for idx, region in tolist(local.all_regions) : region => cidrsubnet("192.168.0.0/16", 8, idx) }
}

# VPC network
resource "google_compute_network" "node_net" {
  name                    = "net-${var.name}"
  auto_create_subnetworks = false
}

# Subnet with IPv6 capabilities
resource "google_compute_subnetwork" "node_subnet" {
  for_each = local.all_regions
  region   = each.value
  name     = "subnet-${var.name}-${each.value}"

  network          = google_compute_network.node_net.name
  ip_cidr_range    = local.subnets_cidr[each.value]
  stack_type       = "IPV4_IPV6"
  ipv6_access_type = "EXTERNAL"
}

# Node ssh firewall
resource "google_compute_firewall" "allow-ssh" {
  name    = "allow-ssh-${var.name}"
  network = google_compute_network.node_net.name

  allow {
    protocol = "icmp"
  }

  source_ranges = var.ip_allow_ssh

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

# Node http firewall
resource "google_compute_firewall" "allow-web" {
  name    = "allow-web-${var.name}"
  network = google_compute_network.node_net.name

  # Always allow traffic from router, if deployed
  source_ranges = var.router.deploy ? concat(var.ip_allow_http, [google_compute_address.router_static_ip[0].address]) : var.ip_allow_http

  allow {
    protocol = "tcp"
    ports    = var.ip_allow_http_ports
  }
}

#------------------------------------------------------------------------------

# Node external IPs
resource "google_compute_address" "static_ip" {
  for_each = var.nodes
  region   = each.value.region
  name     = "ip-${each.key}"

  address_type = "EXTERNAL"
  network_tier = "PREMIUM"
}
