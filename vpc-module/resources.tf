resource "aws_vpc" "projectx_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.projectx_vpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

locals {
  public_subnets = {
    public_1 = { cidr = var.public_subnet_cidrs[0], az = var.azs[0] }
    public_2 = { cidr = var.public_subnet_cidrs[1], az = var.azs[1] }
    public_3 = { cidr = var.public_subnet_cidrs[2], az = var.azs[2] }
  }

  private_subnets = {
    private_1 = { cidr = var.private_subnet_cidrs[0], az = var.azs[0] }
    private_2 = { cidr = var.private_subnet_cidrs[1], az = var.azs[1] }
    private_3 = { cidr = var.private_subnet_cidrs[2], az = var.azs[2] }
  }
}

resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id                  = aws_vpc.projectx_vpc.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name                                        = "${var.project_name}-${each.key}"
    environment                                 = var.environment
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }
}

resource "aws_subnet" "private" {
  for_each = local.private_subnets

  vpc_id                  = aws_vpc.projectx_vpc.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = false


  tags = {
    Name                                        = "${var.project_name}-${each.key}"
    environment                                 = var.environment
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.projectx_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.projectx_vpc.id

  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rt.id
}