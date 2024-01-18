# EC2 instances
resource "aws_instance" "nodes" {
  instance_type = var.machine_type
  count         = var.node_count
  ami           = var.image

  subnet_id = aws_subnet.node_subnet.id
  vpc_security_group_ids = [aws_security_group.security_group.id]

  user_data = templatefile("${path.module}/scripts/node.tpl", {
      region       = var.region
      node_id      = count.index
  })

  root_block_device {
    volume_size = 200
  }

  # IAM Role
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name

  # Stopping condition
  disable_api_termination = var.is_production ? true : false

  tags = {
    Name = "${var.instance_name}-${count.index}"
  }
}
