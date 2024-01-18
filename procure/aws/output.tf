output "router_ip" {
  value = length(aws_eip.router_eip) > 0 ? aws_eip.router_eip[0].public_ip : ""
}

output "nodes" {
  value = [
    for i in range(length(aws_instance.nodes)): {
      id   = aws_instance.nodes[i].id
      ip   = aws_eip.static_ip[i].public_ip
    }
  ]
}
