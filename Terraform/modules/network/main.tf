resource "aws_vpc" "VPC" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.team_name}-${var.environment}-Vpc"
  }
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "${var.team_name}-${var.environment}-Igw"
  }
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                  = aws_vpc.VPC.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.team_name}-${var.environment}-PublicSubnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.VPC.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index % 2 == 0 ? 0 : 1]

  tags = {
    Name = "${var.team_name}-${var.environment}-PrivateSubnet-${count.index + 1}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }

  tags = {
    Name = "${var.team_name}-${var.environment}-PublicRt"
  }
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "NATGW" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id # First public subnet

  tags = {
    Name = "${var.team_name}-${var.environment}-NatGw"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NATGW.id
  }

  tags = {
    Name = "${var.team_name}-${var.environment}-PrivateRt"
  }
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Bastion Host Security Group
resource "aws_security_group" "bastion_sg" {
  name        = "${var.team_name}-${var.environment}-bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = aws_vpc.VPC.id

  # Allow SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH from anywhere"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "${var.team_name}-${var.environment}-bastion-sg"
    Environment = var.environment
    Team        = var.team_name
    Project     = "ACS730"
    Terraform   = "true"
  }
}

# Private Subnet Security Group
resource "aws_security_group" "private_sg" {
  name        = "${var.team_name}-${var.environment}-private-sg"
  description = "Security group for resources in private subnets"
  vpc_id      = aws_vpc.VPC.id

  # Allow SSH access from bastion host
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
    description     = "Allow SSH from bastion host"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "${var.team_name}-${var.environment}-private-sg"
    Environment = var.environment
    Team        = var.team_name
    Project     = "ACS730"
    Terraform   = "true"
  }
}

