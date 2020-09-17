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
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "subnet-pu"
  }
}

resource "aws_subnet" "subnet-pr" {
  vpc_id     = aws_vpc.vpc_test.id
  cidr_block = "192.168.2.0/24"
  availability_zone = "ap-northeast-1c"
  tags = {
    Name = "subnet-pr"
  }
}

resource "aws_internet_gateway" "igw-test" {
  vpc_id = aws_vpc.vpc_test.id

  tags = {
    Name = "igw-test"
  }
}

resource "aws_route_table" "pu" {
  vpc_id = aws_vpc.vpc_test.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-test.id
  }

  tags = {
    Name = "pu"
  }
}

resource "aws_route_table" "pr" {
  vpc_id = aws_vpc.vpc_test.id

  tags = {
    Name = "pr"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-pu.id
  route_table_id = aws_route_table.pu.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.subnet-pr.id
  route_table_id = aws_route_table.pr.id
}

resource "aws_security_group" "sg-pu" {
  name        = "sg-pu"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc_test.id

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-pu"
  }
}

resource "aws_security_group" "sg-pr" {
  name        = "sg-pr"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc_test.id

  tags = {
    Name = "sg-pr"
  }
}

resource "aws_instance" "web1" {
  ami           = "ami-0cc75a8978fbbc969"
  instance_type = "t2.micro"
  key_name = "EC2-VPC-wei-01"
  subnet_id = aws_subnet.subnet-pu.id
  security_groups = [aws_security_group.sg-pu.id]
  tags = {
    Name = "ec2-pu"
  }
  user_data = file("yum.sh")
}

resource "aws_instance" "pr2" {
  ami           = "ami-0cc75a8978fbbc969"
  instance_type = "t2.micro"
  key_name = "EC2-VPC-wei-01"
  subnet_id = aws_subnet.subnet-pr.id
  security_groups = [aws_security_group.sg-pr.id]
  tags = {
    Name = "ec2-pr"
  }
}