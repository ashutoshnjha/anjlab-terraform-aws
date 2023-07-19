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
  region     = "us-west-2"
  access_key = "AWS_ACCESS_KEY"
  secret_key = "AWS_SECRET_KEY"
}


#####
# Data
#####
# https://aws.amazon.com/blogs/compute/query-for-the-latest-amazon-linux-ami-ids-using-aws-systems-manager-parameter-store/
data "aws_ssm_parameter" "anjlab_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

#####
# Resources
#####

# Datacenter/Networking
# 1 VPC

resource "aws_vpc" "anjlab_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "AnjLab-VPC"
  }
}

resource "aws_internet_gateway" "anjlab_igw" {
  vpc_id = aws_vpc.anjlab_vpc.id

  tags = {
    Name = "AnjLab-IGW"
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
    Name = "AnjLab-RTB"
  }
}

resource "aws_subnet" "anjlab_subnet1" {
  cidr_block              = "10.0.0.0/24"
  vpc_id                  = aws_vpc.anjlab_vpc.id
  map_public_ip_on_launch = true # To get public ip at launch
  tags = {
    Name = "AnjLab-SUBNET-1"
  }
}

resource "aws_route_table_association" "anjlab_rta_subnet1" {
  subnet_id      = aws_subnet.anjlab_subnet1.id
  route_table_id = aws_route_table.anjlab_rtb.id
}


# SECURITY GROUPS #
# Webserver(Nginx) security group
resource "aws_security_group" "anjlab_websg" {
  name   = "anjlab-websg"
  vpc_id = aws_vpc.anjlab_vpc.id

  # Allo HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  /*
  # Allo HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  */

  # Outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "AnjLab-WEB-SG1"
  }
}


# Web INSTANCES #
resource "aws_instance" "anjlab_webvm" {
  ami                    = nonsensitive(data.aws_ssm_parameter.anjlab_ami.value)
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.anjlab_subnet1.id
  vpc_security_group_ids = [aws_security_group.anjlab_websg.id]

  user_data = <<EOF
#! /bin/bash
sudo amazon-linux-extras install -y nginx1
sudo rm /usr/share/nginx/html/index.html
echo '<html><head><title>AnjLab</title></head><body><p>Hello Ashu</p></body></html>' | sudo tee /usr/share/nginx/html/index.html
sudo service nginx start
EOF
  tags = {
    Name = "AnjLab-WEB-VM1"
  }
}
