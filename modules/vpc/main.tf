terraform {
  required_version = ">= 1.2.3"
}

resource "aws_vpc" "main" {
  cidr_block       = var.aws_vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "demo"
  }

  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "internet_gateway" {
  depends_on = [
    aws_vpc.main
  ]

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "internet-gateway"
  }
}

# Public subnet creation with route table and EIP
resource "aws_subnet" "public_subnet" {
  depends_on = [
    aws_vpc.main
  ]

  vpc_id     = aws_vpc.main.id
  cidr_block = var.aws_subnet_public_cidr

  availability_zone_id = "use1-az1"

  tags = {
    Name = "public_subnet"
  }

  map_public_ip_on_launch = true
}

resource "aws_route_table" "public_route_table" {
  depends_on = [
    aws_vpc.main,
    aws_internet_gateway.internet_gateway
  ]

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "public_route_table"
  }
}

resource "aws_route_table_association" "associate_public_subnet" {
  depends_on = [
    aws_subnet.public_subnet,
    aws_route_table.public_route_table
  ]

  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}


resource "aws_eip" "elastic" {
  vpc = true

  tags = {
    Name = "eip-1"
  }
}

resource "aws_eip" "elastic_lb" {
  vpc = true

  tags = {
    Name = "eip-lb"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  depends_on = [
    aws_subnet.public_subnet,
    aws_eip.elastic
  ]

  allocation_id = aws_eip.elastic.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "nat-gateway"
  }
}

# Private subnet and its NAT routing table association
resource "aws_subnet" "private_subnet" {
  depends_on = [
    aws_vpc.main
  ]

  vpc_id     = aws_vpc.main.id
  cidr_block = var.aws_subnet_private_cidr

  availability_zone_id = "use1-az1"

  tags = {
    Name = "private_subnet"
  }
}

resource "aws_route_table" "private_route_table" {
  depends_on = [
    aws_vpc.main,
    aws_nat_gateway.nat_gateway
  ]

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "private_route_table"
  }
}

resource "aws_route_table_association" "associate_private_subnet" {
  depends_on = [
    aws_subnet.private_subnet,
    aws_route_table.private_route_table
  ]

  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}



