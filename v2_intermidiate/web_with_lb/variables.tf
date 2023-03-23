variable "aws_access_key" {
  type        = string
  description = "AWS  access key"
  sensitive   = true
}
variable "aws_secret_key" {
  type        = string
  description = "AWS  secret key"
  sensitive   = true
}

variable "aws_region" {
  type        = string
  description = "AWS region to configure resources."
  default     = "us-west-2"
}

variable "cidr_block_vpc" {
  type        = string
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "cidr_block_subnets" {
  type        = list(string)
  description = "CIDR Blocks for Subnets in VPC"
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}
variable "ec2_instance_type" {
  type        = string
  description = "Type for EC2 Instance"
  default     = "t2.micro"
}
variable "project_name" {
  type        = string
  description = "Project name"
  default     = "AnjLabPoc"
}

variable "name_prefix" {
  type        = string
  description = "Prefix for Name tag in resources"
  default     = "AnjLab"
}