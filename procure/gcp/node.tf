# GCE instances
resource "google_compute_instance" "nodes" {
  for_each     = var.nodes
  name         = "node-${each.key}"
  zone         = each.value.zone
  machine_type = each.value.machine_type

  network_interface {
    network    = google_compute_network.node_net.id
    subnetwork = google_compute_subnetwork.node_subnet[each.value.region].id
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
    startup-script = templatefile("${path.module}/scripts/node.tpl", {
      gpu = each.value.gpu_count > 0 ? true : false,
    })

    # Deployment files
    deploy_tar = each.value.gpu_count > 0 ? filebase64("${path.module}/../deploy-gpu.tar.gz") : filebase64("${path.module}/../deploy.tar.gz")

    # Node config
    secret-config = filebase64("${path.module}/../../configs/${each.key}.json")
  }

  boot_disk {
    initialize_params {
      image = each.value.image
      size  = 200
    }
  }

  # Disabled in production
  allow_stopping_for_update = var.is_production ? false : true

  # Optional GPU
  dynamic "guest_accelerator" {
    for_each = each.value.gpu_count > 0 ? [1] : []
    content {
      type  = each.value.gpu_type
      count = each.value.gpu_count
    }
  }

  # Ensure to adjust the on_host_maintenance setting based on GPU or confidential compute
  dynamic "scheduling" {
    for_each = each.value.gpu_count > 0 || each.value.confidential_compute ? [1] : []
    content {
      on_host_maintenance = "TERMINATE"
      automatic_restart   = false
    }
  }

  # confidential computing
  dynamic "confidential_instance_config" {
    for_each = each.value.confidential_compute ? [1] : []
    content {
      enable_confidential_compute = each.value.confidential_compute ? true : false
    }
  }
}
