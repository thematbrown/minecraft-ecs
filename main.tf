terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.8.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  #Using credentials file
  shared_credentials_files = ["credentials"]
  profile                  = "default"
}

### Networking
resource "aws_vpc" "main-vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "igw-1" {
  vpc_id = aws_vpc.main-vpc.id
  tags = {
    Name = "Internet Gateway 1"
  }
}

resource "aws_subnet" "publicsubnet1" { # Creating Public Subnets
  vpc_id            = aws_vpc.main-vpc.id
  cidr_block        = "10.0.2.0/24" # CIDR block of public subnets
  availability_zone = "us-east-1a"
  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "privatesubnet1" { # Creating Private Subnets
  vpc_id            = aws_vpc.main-vpc.id
  cidr_block        = "10.0.3.0/" # CIDR block of private subnets
  availability_zone = "us-east-1a"
  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_eip" "nateIP" {
  vpc = true
}

resource "aws_nat_gateway" "NATgw" {
  allocation_id = aws_eip.nateIP.id
  subnet_id     = aws_subnet.publicsubnet1.id
  tags = {
    Name = "nat-gw-1"
  }
}

resource "aws_route_table" "PublicRT" { # Creating RT for Public Subnet
  vpc_id = aws_vpc.main-vpc.id
  route {
    cidr_block = "0.0.0.0/0" # Traffic from Public Subnet reaches Internet via Internet Gateway
    gateway_id = aws_internet_gateway.igw-1.id
  }
  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table" "PrivateRT" { # Creating RT for Private Subnet
  vpc_id = aws_vpc.main-vpc.id
  route {
    cidr_block     = "0.0.0.0/0" # Traffic from Private Subnet reaches Internet via NAT Gateway
    nat_gateway_id = aws_nat_gateway.NATgw.id
  }
  tags = {
    Name = "private-route-table-1"
  }
}

resource "aws_route_table_association" "PublicRTassociation1" {
  subnet_id      = aws_subnet.publicsubnet1.id
  route_table_id = aws_route_table.PublicRT.id
}

resource "aws_route_table_association" "PrivateRTassociation1" {
  subnet_id      = aws_subnet.privatesubnet1.id
  route_table_id = aws_route_table.PrivateRT.id
}

## EC2 test instance
resource "aws_security_group" "serverSG" {
  name        = "test-server_sg"
  description = "Allow http,ssh,icmp"
  vpc_id      = aws_vpc.main-vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks =  ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "test_sg"
  }
}

resource "aws_network_interface" "test" {
  subnet_id   = aws_subnet.privatesubnet1.id
  private_ips = ["10.0.5.0/24"]

  tags = {
    Name = "primary_network_interface"
  }
}
resource "aws_instance" "test" {
  ami           = "ami-04505e74c0741db8d" # us-east-1, Ubuntu Server 20.04 LTS (HVM), SSD Volume Type
  instance_type = "t2.micro"

  network_interface {
    network_interface_id = aws_network_interface.test.id
    device_index         = 0
  }
}