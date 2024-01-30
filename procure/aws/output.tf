output "router_ip" {
  value = length(aws_eip.router_eip) > 0 ? aws_eip.router_eip[0].public_ip : ""
}

output "nodes" {
  value = [
    for key, node in aws_instance.nodes : {
      key  = key
      id   = aws_instance.nodes[key].id
      ip   = aws_eip.static_ip[key].public_ip
    }
  ]
}
