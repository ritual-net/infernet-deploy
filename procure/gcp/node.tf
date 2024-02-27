# GCE instances
resource "google_compute_instance" "nodes" {
  for_each     = var.nodes
  name         = "node-${each.key}"
  zone         = each.value[1]
  machine_type = var.machine_type

  network_interface {
    network    = google_compute_network.node_net.id
    subnetwork = google_compute_subnetwork.node_subnet[each.value[0]].id
    stack_type = "IPV4_IPV6"

    access_config {
      nat_ip       = google_compute_address.static_ip[each.key].address
      network_tier = "PREMIUM"
    }

    ipv6_access_config {
      network_tier = "PREMIUM"
    }
  }

  service_account {
    email = var.service_account_email
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
    ]
  }

  metadata = {
    # Startup script
    startup-script = file("${path.module}/scripts/node.sh")

    # Deployment files
    deploy-tar = filebase64("${path.module}/../deploy.tar.gz")

    # Node config
    secret-config = filebase64("${path.module}/../../configs/${each.key}.json")
  }

  boot_disk {
    initialize_params {
      image = var.image
      size  = 200
    }
  }

  # Disabled in production
  allow_stopping_for_update = var.is_production ? false : true

  # Optional GPU
  dynamic "guest_accelerator" {
    for_each = var.gpu_count > 0 ? [1] : []
    content {
      type  = var.gpu_type
      count = var.gpu_count
    }
  }

  # Ensure to adjust the on_host_maintenance setting based on GPU
  dynamic "scheduling" {
    for_each = var.gpu_count > 0 ? [1] : []
    content {
      on_host_maintenance = "TERMINATE"
      automatic_restart   = false
      preemptible         = false
    }
  }
}
