resource "aws_vpc" "main_network" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true # AWS provides a "Private Phonebook" (AmazonProvidedDNS) an instances can now resolve names
  enable_dns_hostnames = true # AWS gives EC2 instance a DNS name

  tags = {
    Name = "production-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_network.id

  tags = {
    Name = "production-igw"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_network.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-1a"

  tags = {
    Name = "public-subnet-1a"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main_network.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-southeast-1b"

  tags = {
    Name = "private-subnet-1b"
  }
}

# Route table is egress "Forwarding"
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_network.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }

}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id

}

resource "aws_eip" "eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "production-nat-gateway"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main_network.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "private_assco" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id

}