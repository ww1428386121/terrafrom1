provider "aws" {
  version = "3.6.0"
}

resource "aws_vpc" "vpc_test" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames =true
  region  = "ap-northeast-1"

  tags = {
    Name = "vpc_test"
  }
}

