output "router_ip" {
  value = length(google_compute_address.router_static_ip) > 0 ? google_compute_address.router_static_ip[0].address : ""
}

output "nodes" {
  value = [
    for i in range(length(google_compute_instance.nodes)): {
      name = google_compute_instance.nodes[i].name
      zone = google_compute_instance.nodes[i].zone
      project = google_compute_instance.nodes[i].project
      ip = google_compute_address.static_ip[i].address
    }
  ]
}
