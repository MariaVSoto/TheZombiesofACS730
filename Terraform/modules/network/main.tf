resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    {
      Name = "${var.team_name}-${var.environment}-vpc"
    },
    var.common_tags
  )
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    {
      Name = "${var.team_name}-${var.environment}-igw"
    },
    var.common_tags
  )
}

resource "aws_subnet" "public" {
  count             = 4
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = true

  tags = merge(
    {
      Name = "${var.team_name}-${var.environment}-public-subnet-${count.index + 1}"
      Type = "Public"
    },
    var.common_tags
  )
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    {
      Name = "${var.team_name}-${var.environment}-private-subnet-${count.index + 1}"
      Type = "Private"
    },
    var.common_tags
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
    {
      Name = "${var.team_name}-${var.environment}-public-rt"
    },
    var.common_tags
  )
}

resource "aws_route_table_association" "public" {
  count = 4

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(
    {
      Name = "${var.team_name}-${var.environment}-nat-eip"
    },
    var.common_tags
  )
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id  # Placed in the first public subnet

  tags = merge(
    {
      Name = "${var.team_name}-${var.environment}-nat"
    },
    var.common_tags
  )

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = merge(
    {
      Name = "${var.team_name}-${var.environment}-private-rt"
    },
    var.common_tags
  )
}

resource "aws_route_table_association" "private" {
  count = 2

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Bastion Host Security Group
resource "aws_security_group" "bastion" {
  name        = "${var.team_name}-${var.environment}-bastion-sg"
  description = "Security group for Bastion Host (Webserver2)"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "SSH from Internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from ALB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "${var.team_name}-${var.environment}-bastion-sg"
    },
    var.common_tags
  )
}

# ALB Security Group
resource "aws_security_group" "alb" {
  name        = "${var.team_name}-${var.environment}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "${var.team_name}-${var.environment}-alb-sg"
    },
    var.common_tags
  )
}

# Web Servers Security Group
resource "aws_security_group" "web" {
  name        = "${var.team_name}-${var.environment}-web-sg"
  description = "Security group for Web Servers"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "HTTP from ALB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description = "SSH from Bastion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "${var.team_name}-${var.environment}-web-sg"
    },
    var.common_tags
  )
}

# Update Private Security Group to allow traffic from web servers
resource "aws_security_group" "private" {
  name        = "${var.team_name}-${var.environment}-private-sg"
  description = "Security group for Private Subnet instances"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "SSH from Bastion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "${var.team_name}-${var.environment}-private-sg"
    },
    var.common_tags
  )
}

