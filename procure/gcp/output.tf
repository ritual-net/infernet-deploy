output "router_ip" {
  value = length(google_compute_address.router_static_ip) > 0 ? google_compute_address.router_static_ip[0].address : ""
}

output "nodes" {
  value = [
    for key, node in google_compute_instance.nodes : {
      key = key
      id  = node.name
      ip  = google_compute_address.static_ip[key].address
    }
  ]
}
