#==== The VPC ======#
resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "eks-cluster"
  }
}

#==== Availability Zones ======#
data "aws_availability_zones" "available" {
}

#==== Public Subnets ======#
resource "aws_subnet" "public_subnets" {
  count                   = var.az_count
  vpc_id                  = aws_vpc.eks_vpc.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = cidrsubnet(aws_vpc.eks_vpc.cidr_block, var.subnet_cidr_bits, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "eks-pub-${(element(data.aws_availability_zones.available.names, count.index))}"
  }
}

#==== Private Subnets ======#
resource "aws_subnet" "private_subnets" {
  count                   = var.az_count
  vpc_id                  = aws_vpc.eks_vpc.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = cidrsubnet(aws_vpc.eks_vpc.cidr_block, var.subnet_cidr_bits, count.index + var.az_count)
  map_public_ip_on_launch = false

  tags = {
    Name = "eks-prv-${(element(data.aws_availability_zones.available.names, count.index))}"
  }
}

#==== Internet gateway for the public subnets ======#
resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = {
    Name = "eks_igw"
  }
}

#====== Elastic IP for NAT Gateway ======#
resource "aws_eip" "eks_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.eks_igw]
  tags = {
    Name = "eks_igw"
  }
}

#====== NAT ======#
resource "aws_nat_gateway" "eks_nat" {
  allocation_id = aws_eip.eks_eip.id
  subnet_id     = element(aws_subnet.public_subnets.*.id, 0)
  depends_on    = [aws_internet_gateway.eks_igw]
  tags = {
    Name = "eks_nat"
  }
}

#====== Routing table for public subnets ======#
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = {
    Name = "eks_pub_rt"
  }
}

#====== Routing table for private subnets ======#
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = {
    Name = "eks_prv_rt"
  }
}

#====== Add route for Public route table to Internet Gateway ======#
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.eks_igw.id
}

#====== Add route for Private route table to NAT Gateway ======#
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.eks_nat.id
}

#====== Route table associations to Public Subnets ======#
resource "aws_route_table_association" "public_internet" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)
  route_table_id = aws_route_table.public_rt.id
}

#====== Route table associations to Private Subnets ======#
resource "aws_route_table_association" "private_internet" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.private_subnets.*.id, count.index)
  route_table_id = aws_route_table.private_rt.id
}