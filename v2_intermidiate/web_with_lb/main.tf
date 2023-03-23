/*
References
https://registry.terraform.io/providers/hashicorp/aws/latest/docs
*/

#####
# Providers
#####

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

#####
# Data
#####

data "aws_availability_zones" "available" {
  state = "available"
}


#####
# Resources
#####

# Datacenter/Networking
# 1 VPC

resource "aws_vpc" "anjlab_vpc" {
  cidr_block = var.cidr_block_vpc

  tags = {
    Name = "${var.name_prefix}-VPC"
  }
}

resource "aws_internet_gateway" "anjlab_igw" {
  vpc_id = aws_vpc.anjlab_vpc.id

  tags = {
    Name = "${var.name_prefix}-IGW"
  }
}

# ROUTING #
resource "aws_route_table" "anjlab_rtb" {
  vpc_id = aws_vpc.anjlab_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.anjlab_igw.id
  }

  tags = {
    Name = "${var.name_prefix}-RTB"
  }
}

resource "aws_subnet" "anjlab_pubsubnet1" {
  cidr_block              = var.cidr_block_subnets[0]
  vpc_id                  = aws_vpc.anjlab_vpc.id
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "${var.name_prefix}-PUB-SUBNET-1"
  }
}

resource "aws_subnet" "anjlab_pubsubnet2" {
  cidr_block              = var.cidr_block_subnets[1]
  vpc_id                  = aws_vpc.anjlab_vpc.id
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "${var.name_prefix}-PUB-SUBNET-2"
  }
}


resource "aws_route_table_association" "anjlab_pubsubnet1" {
  subnet_id      = aws_subnet.anjlab_pubsubnet1.id
  route_table_id = aws_route_table.anjlab_rtb.id
}

resource "aws_route_table_association" "anjlab_pubsubnet2" {
  subnet_id      = aws_subnet.anjlab_pubsubnet2.id
  route_table_id = aws_route_table.anjlab_rtb.id
}



# SECURITY GROUPS #
# ALB Security Group
resource "aws_security_group" "anjlab_webalb_sg" {
  name   = "anjlab-web-alb-sg"
  vpc_id = aws_vpc.anjlab_vpc.id

  #Allow HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.name_prefix}-WEB-ALBSG"
  }

}

# Nginx security group
resource "aws_security_group" "anjlab_nginx_sg" {
  name   = "anjlab-nginx-sg"
  vpc_id = aws_vpc.anjlab_vpc.id

  # HTTP access from VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block_vpc]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-WEB-NGINXSG"
  }
}

# Web INSTANCES #
# To be configured via instances.tf