locals {
  name = "eks-vpc-terraform"
  team = "devops"
  discovery = "eks-with-terraform"
}

resource "aws_vpc" "eks-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = local.name
    team = local.team
  }
}

#Adding Internet Gateway
resource "aws_internet_gateway" "eks-vpc-IGW" {
  vpc_id = aws_vpc.eks-vpc.id
  tags = {
    Name = local.name
    team = local.team
  }
}
# EIP 
resource "aws_eip" "nat_eip" {
}


#NatGateway
resource "aws_nat_gateway" "eks-NatGateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = values(aws_subnet.eks-public-subnets)[0].id
  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.eks-vpc-IGW]
}

#Public RT
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.eks-vpc.id

  route {
    cidr_block = aws_vpc.eks-vpc.cidr_block
    gateway_id = "local"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks-vpc-IGW.id
  }
  tags = {
    Name = "public-rt"
  }
}
# Public RT Subnet Association
resource "aws_route_table_association" "public_subnet_association" {
    for_each = aws_subnet.eks-public-subnets
    subnet_id = each.value.id
    route_table_id = aws_route_table.public_rt.id
}
#Private RT Subnet Association
resource "aws_route_table_association" "private_subnet_association" {
    for_each = aws_subnet.eks-private-subnets
    subnet_id = each.value.id
    route_table_id = aws_route_table.private_rt.id
}
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.eks-vpc.id

  route {
    cidr_block = aws_vpc.eks-vpc.cidr_block
    gateway_id = "local"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.eks-NatGateway.id
  }
  tags = {
    Name = "private-rt"
  }
}

# Subnets, 3 public
resource "aws_subnet" "eks-public-subnets" {
  for_each          = var.public
  vpc_id            = aws_vpc.eks-vpc.id
  availability_zone = each.value
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, each.key)
  tags = {
    Name = "PublicSubnet-${each.key}"
    team = local.team
    "kubernetes.io/role/elb" = 1
    "kubernetes.io/cluster/eks-with-terraform" = owned
  }
}

# Subnets, 3 private
resource "aws_subnet" "eks-private-subnets" {
  for_each          = var.private
  vpc_id            = aws_vpc.eks-vpc.id
  availability_zone = each.value
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, each.key)
  tags = {
    Name = "Private-${each.key}"
    team = local.team
    "karpenter.sh/discovery" = local.discovery
    "kubernetes.io/role/internal-elb" = 1
    "kubernetes.io/cluster/eks-with-terraform" = owned
  }
}