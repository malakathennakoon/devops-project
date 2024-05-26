terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.51.1"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}


resource "aws_instance" "demo-server" {
  ami           = "ami-0d94353f7bad10668"
  instance_type = "t2.micro"
  key_name      = "DevOps_Project"
  security_groups = [ "demo-sg" ]
  subnet_id = aws_subnet.ms-subnet-01.id
}

resource "aws_security_group" "demo-sg" {
  name        = "demo-sg"
  description = "SSH access"
  vpc_id =  aws_vpc.ms-vpc.id

ingress {
    description = "SSH_access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssh-port"
  }
}

#Define VPC

resource "aws_vpc" "ms-vpc" {
  cidr_block       = "10.1.0.0/16"
  tags = {
    Name = "ms-vpc"
  }
}

#Define subnets

resource "aws_subnet" "ms-subnet-01" {
  vpc_id     = aws_vpc.ms-vpc.id
  cidr_block = "10.1.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1a"
  tags = {
    Name = "ms-subnet-01"
  }
}

resource "aws_subnet" "ms-subnet-02" {
  vpc_id     = aws_vpc.ms-vpc.id
  cidr_block = "10.1.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1b"
  tags = {
    Name = "ms-subnet-02"
  }
}

#AWS internet gateway

resource "aws_internet_gateway" "ms-igw" {
  vpc_id = aws_vpc.ms-vpc.id
  tags = {
    Name = "ms-igw"
  }
}

#Route table

resource "aws_route_table" "ms-route-table" {
  vpc_id = aws_vpc.ms-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ms-igw.id
  }

  tags = {
    Name = "ms-route-table"
  }
}

#Route table assosiations

resource "aws_route_table_association" "subnet01-2-rt" {
  subnet_id      = aws_subnet.ms-subnet-01.id
  route_table_id = aws_route_table.ms-route-table.id
}

resource "aws_route_table_association" "subnet01-2-rt" {
  subnet_id      = aws_subnet.ms-subnet-02.id
  route_table_id = aws_route_table.ms-route-table.id
}