# Config files as secrets
resource "aws_ssm_parameter" "config_file" {
  for_each = var.nodes

  name  = "${each.key}.json"
  type  = "SecureString"
  value = filebase64("${path.module}/../../configs/${each.key}.json")
}

# Deployment files
resource "aws_ssm_parameter" "deploy_tar" {
  for_each = var.nodes

  name  = "deploy-tar-${each.key}"
  type  = "SecureString"
  value = each.value.has_gpu ? filebase64("${path.module}/../deploy-gpu.tar.gz") : filebase64("${path.module}/../deploy.tar.gz")
}

# Node IPs
resource "aws_ssm_parameter" "node_ips" {
  name  = "node-ips-${var.name}"
  type  = "String"
  value = join("\n", [for key, _ in aws_instance.nodes : "${aws_eip.static_ip[key].public_ip}:4000"])
}
