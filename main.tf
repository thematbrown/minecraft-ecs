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
  shared_credentials_file = "credentials"
  profile                 = "default"
}

### Networking
resource "aws_vpc" "main-vpc-vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "igw-1" {
  vpc_id = aws_vpc.main-vpc-vpc.id
  tags = {
    Name = "Internet Gateway 1"
  }
}

resource "aws_subnet" "publicsubnet1" { # Creating Public Subnets
  vpc_id            = aws_vpc.main-vpc.id
  cidr_block        = "10.0.1.0/24" # CIDR block of public subnets
  availability_zone = "us-east-1"
  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "privatesubnet1" { # Creating Private Subnets
  vpc_id            = aws_vpc.main-vpc.id
  cidr_block        = "10.0.1.0/24" # CIDR block of private subnets
  availability_zone = "us-east-1"
  tags = {
    Name = "private-subnet-1"
  }
}
