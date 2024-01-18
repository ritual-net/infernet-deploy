# Config files as secrets
resource "aws_ssm_parameter" "config_file" {
  count = var.node_count

  name  = "config_${count.index}"
  type  = "SecureString"
  value = filebase64("${path.module}/../../configs/${count.index}.json")
}

# Deployment files
resource "aws_ssm_parameter" "deploy_tar" {
  name  = "deploy_tar"
  type  = "SecureString"
  value = filebase64("${path.module}/../deploy.tar.gz")
}

# Node IPs
resource "aws_ssm_parameter" "node_ips" {
  name  = "node_ips"
  type  = "String"
  value = join("\n", [for ip in aws_eip.static_ip[*].public_ip : "${ip}:4000"])
}
