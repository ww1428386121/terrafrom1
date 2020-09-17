provider "aws" {
  version = "3.6.0"
  region  = var.aws_region
}

resource "aws_vpc" "vpc_test" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames =true

  tags = {
    Name = "vpc_test"
  }
}

resource "aws_subnet" "subnet-pu" {
  vpc_id     = aws_vpc.vpc_test.id
  cidr_block = "192.168.1.0/24"
  tags = {
    Name = "subnet-pu"
  }
}

resource "aws_instance" "web" {
  ami           = "ami-0cc75a8978fbbc969"
  instance_type = "t2.micro"
  key_name = "key_test"
  subnet_id = aws_subnet.subnet-pu.id
  tags = {
    Name = "HelloWorld"
  }
}