locals {
  # Extract all zones and include router zone, ensuring uniqueness
  all_zones = toset(concat([for node in var.nodes : node.zone], [var.router.zone]))

  # Generate unique CIDR blocks for each zone.
  # This assumes you have a limited number of zones and a /16 network allows for 256 /24 subnets.
  subnets_cidr    = { for idx, zone in tolist(local.all_zones) : zone => cidrsubnet(aws_vpc.node_vpc.cidr_block, 8, idx) }
  subnets_cidr_v6 = { for idx, zone in tolist(local.all_zones) : zone => cidrsubnet(aws_vpc.node_vpc.ipv6_cidr_block, 8, idx) }
}

# VPC
resource "aws_vpc" "node_vpc" {
  cidr_block                       = "192.168.0.0/16"
  assign_generated_ipv6_cidr_block = true
  enable_dns_support               = true
  enable_dns_hostnames             = true

  tags = {
    Name = "vpc-${var.name}"
  }
}

# Subnet (with IPv6 capabilities)
resource "aws_subnet" "node_subnet" {
  for_each                = local.all_zones
  vpc_id                  = aws_vpc.node_vpc.id
  cidr_block              = local.subnets_cidr[each.value]
  availability_zone       = each.value
  map_public_ip_on_launch = true

  ipv6_cidr_block                 = local.subnets_cidr_v6[each.value]
  assign_ipv6_address_on_creation = true

  tags = {
    Name = "subnet-${var.name}-${each.value}"
  }
}

# Network Interface
resource "aws_network_interface" "node_nic" {
  for_each  = var.nodes
  subnet_id = aws_subnet.node_subnet[each.value.zone].id
  tags = {
    Name = "nic-${each.key}"
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
    gateway_id      = aws_internet_gateway.gateway.id
  }

  tags = {
    Name = "rt-${var.name}"
  }
}

# Associate the route table with the subnet
resource "aws_route_table_association" "rta" {
  for_each       = local.all_zones
  subnet_id      = aws_subnet.node_subnet[each.value].id
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
    from_port = var.ip_allow_http_from_port
    to_port   = var.ip_allow_http_to_port
    protocol  = "tcp"

    # Allow traffic from configured IPs and router, if deployed
    cidr_blocks = var.router.deploy ? concat(var.ip_allow_http, ["${aws_eip.router_eip[0].public_ip}/32"]) : var.ip_allow_http
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
  for_each          = var.nodes
  depends_on        = [aws_internet_gateway.gateway]
  network_interface = aws_network_interface.node_nic[each.key].id
  instance          = aws_instance.nodes[each.key].id

  tags = {
    Name = "eip-${each.key}"
  }
}
