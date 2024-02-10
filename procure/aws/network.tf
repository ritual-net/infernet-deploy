
# VPC
resource "aws_vpc" "node_vpc" {
  cidr_block = "10.0.0.0/16"
  assign_generated_ipv6_cidr_block = true
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-${var.name}"
  }
}

# Subnet (with IPv6 capabilities)
resource "aws_subnet" "node_subnet" {
  vpc_id = aws_vpc.node_vpc.id
  cidr_block = cidrsubnet(aws_vpc.node_vpc.cidr_block, 4, 1)
  map_public_ip_on_launch = true

  ipv6_cidr_block = cidrsubnet(aws_vpc.node_vpc.ipv6_cidr_block, 8, 1)
  assign_ipv6_address_on_creation = true

  tags = {
    Name = "subnet-${var.name}"
  }
}

# Network Interface
resource "aws_network_interface" "node_nic" {
  for_each = var.nodes
  subnet_id = aws_subnet.node_subnet.id
  tags = {
    Name = "nic-${each.value}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.node_vpc.id

  tags = {
    Name = "igw-${var.name}"
  }
}

# Route table to allow access to the Internet Gateway
resource "aws_route_table" "route_table" {
    vpc_id = aws_vpc.node_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gateway.id
    }

    route {
        ipv6_cidr_block = "::/0"
        gateway_id = aws_internet_gateway.gateway.id
    }

    tags = {
      Name = "rt-${var.name}"
    }
}

# Associate the route table with the subnet
resource "aws_route_table_association" "rta" {
    subnet_id      = aws_subnet.node_subnet.id
    route_table_id = aws_route_table.route_table.id
}

# Security group
resource "aws_security_group" "security_group" {
  vpc_id = aws_vpc.node_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ip_allow_ssh
  }

  ingress {
    from_port   = var.ip_allow_http_from_port
    to_port     = var.ip_allow_http_to_port
    protocol    = "tcp"

    # Allow traffic from configured IPs and router, if deployed
    # cidr_blocks = concat(var.ip_allow_http, ["${aws_eip.router_eip.public_ip}/32"])
    cidr_blocks = var.deploy_router ? concat(var.ip_allow_http, ["${aws_eip.router_eip[0].public_ip}/32"]) : var.ip_allow_http
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-${var.name}"
  }
}

#------------------------------------------------------------------------------

# Node IPs
resource "aws_eip" "static_ip" {
  for_each = var.nodes
  depends_on = [aws_internet_gateway.gateway]
  network_interface = aws_network_interface.node_nic[each.key].id
  instance = aws_instance.nodes[each.key].id

  tags = {
    Name = "eip-${each.value}"
  }
}
