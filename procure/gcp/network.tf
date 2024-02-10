# VPC network
resource "google_compute_network" "node_net" {
  provider = google
  name = "net-${var.name}"
  auto_create_subnetworks = false
}

# Subnet with IPv6 capabilities
resource "google_compute_subnetwork" "node_subnet" {
  provider = google
  name = "subnet-${var.name}"
  network = google_compute_network.node_net.name
  ip_cidr_range = "10.0.0.0/8"
  stack_type = "IPV4_IPV6"
  ipv6_access_type = "EXTERNAL"
}

# Node ssh firewall
resource "google_compute_firewall" "allow-ssh" {
  provider = google
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
  source_ranges = var.deploy_router ? concat(var.ip_allow_http, [google_compute_address.router_static_ip[0].address]) : var.ip_allow_http

  allow {
    protocol = "tcp"
    ports    = var.ip_allow_http_ports
  }
}

#------------------------------------------------------------------------------

# Node external IPs
resource "google_compute_address" "static_ip" {
  provider = google
  for_each = var.nodes
  name = "ip-${each.value}"

  address_type = "EXTERNAL"
  network_tier = "PREMIUM"
}
