terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.17.0"
    }
  }
}

provider "aws" {
    region = var.region
}

### data
data "aws_availability_zones" "available" {}
### VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.network_address_space
  tags = {
      Name = "My-vpc"
  }
}
### Internet gateway
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id
    tags = {
        Name = "My-igw"
    }
}
### subnet
resource "aws_subnet" "public_subnet" {
    cidr_block              = var.subnet_public
    vpc_id                  = aws_vpc.vpc.id
    map_public_ip_on_launch = true
    availability_zone       = data.aws_availability_zones.available.names[0] 
    tags = {
        Name = "My-subnet"
    }
}
### route table
resource "aws_route_table" "rtb" {
    vpc_id = aws_vpc.vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
        Name = "My-rtb"
    }
  
}
### route table association
resource "aws_route_table_association" "rtb_public" {
  subnet_id         = aws_subnet.public_subnet.id
  route_table_id    = aws_route_table.rtb.id
}
### security group
resource "aws_security_group" "allow_connection" {
  name        = "permit http"
  description = "This SG permit http from internet"
  vpc_id      = aws_vpc.vpc.id
    ### allow http
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ### allow ssh
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ### allow https
    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "TCP"
        cidr_blocks = ["0.0.0.0/0"] 
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]

    }
}
### instance 
resource "aws_instance" "public_instance" {
    ami                    = "ami-0b2251edd19986811"
    key_name               = var.key_name
    instance_type          = "t2.micro"
    subnet_id              = aws_subnet.public_subnet.id
    vpc_security_group_ids = [aws_security_group.allow_connection.id]
}