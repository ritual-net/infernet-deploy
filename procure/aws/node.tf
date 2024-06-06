# EC2 instances
resource "aws_instance" "nodes" {
  for_each          = var.nodes
  instance_type     = each.value.machine_type
  ami               = each.value.image
  availability_zone = each.value.zone

  subnet_id              = aws_subnet.node_subnet[each.value.zone].id
  vpc_security_group_ids = [aws_security_group.security_group.id]

  user_data = templatefile("${path.module}/scripts/node.tpl", {
    cluster-name = var.name
    node-name    = each.key
    region       = var.region
    gpu          = each.value.has_gpu
  })

  root_block_device {
    volume_size = 200
  }

  # IAM Role
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name

  # Stopping condition
  disable_api_termination = var.is_production ? true : false

  tags = {
    Name = "node-${each.key}"
  }
}
