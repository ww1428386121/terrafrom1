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

resource "aws_subnet" "subnet-pu1" {
  vpc_id     = aws_vpc.vpc_test.id
  cidr_block = "192.168.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "subnet-pu1"
  }
}

resource "aws_subnet" "subnet-pr1" {
  vpc_id     = aws_vpc.vpc_test.id
  cidr_block = "192.168.2.0/24"
  availability_zone = "ap-northeast-1c"
  tags = {
    Name = "subnet-pr1"
  }
}

resource "aws_subnet" "subnet-pu2" {
  vpc_id     = aws_vpc.vpc_test.id
  cidr_block = "192.168.3.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "subnet-pu2"
  }
}

resource "aws_subnet" "subnet-pr2" {
  vpc_id     = aws_vpc.vpc_test.id
  cidr_block = "192.168.4.0/24"
  availability_zone = "ap-northeast-1c"
  tags = {
    Name = "subnet-pr2"
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
  subnet_id      = aws_subnet.subnet-pu1.id
  route_table_id = aws_route_table.pu.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.subnet-pu2.id
  route_table_id = aws_route_table.pu.id
}

resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.subnet-pr1.id
  route_table_id = aws_route_table.pr.id
}

resource "aws_route_table_association" "d" {
  subnet_id      = aws_subnet.subnet-pr2.id
  route_table_id = aws_route_table.pr.id

}
resource "aws_security_group" "sg-pu" {
  name        = "trsgpu"
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
    Name = "grsgpu"
  }
}

resource "aws_security_group" "sg-pr" {
  name        = "trsgpr"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc_test.id

  tags = {
    Name = "trsgpr"
  }
}

resource "aws_instance" "web1" {
  ami           = "ami-0cc75a8978fbbc969"
  instance_type = "t2.micro"
  key_name = "EC2-VPC-wei-01"
  subnet_id = aws_subnet.subnet-pu1.id
  security_groups = [aws_security_group.sg-pu.id]
  tags = {
    Name = "ec2-pu1"
  }
  user_data = file("yum.sh")
}

resource "aws_instance" "pr1" {
  ami           = "ami-0cc75a8978fbbc969"
  instance_type = "t2.micro"
  key_name = "EC2-VPC-wei-01"
  subnet_id = aws_subnet.subnet-pr1.id
  security_groups = [aws_security_group.sg-pr.id]
  tags = {
    Name = "ec2-pr1"
  }
}

  resource "aws_instance" "web2" {
  ami           = "ami-0cc75a8978fbbc969"
  instance_type = "t2.micro"
  key_name = "EC2-VPC-wei-01"
  subnet_id = aws_subnet.subnet-pu2.id
  security_groups = [aws_security_group.sg-pu.id]
  tags = {
    Name = "ec2-pu2"
  }
  user_data = file("yum.sh")
}

resource "aws_instance" "pr2" {
  ami           = "ami-0cc75a8978fbbc969"
  instance_type = "t2.micro"
  key_name = "EC2-VPC-wei-01"
  subnet_id = aws_subnet.subnet-pr2.id
  security_groups = [aws_security_group.sg-pr.id]
  tags = {
    Name = "ec2-pr2"
  }
}

resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = true
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.sg-pu.id}"]
  subnets            = ["${aws_subnet.subnet-pu1.id},${aws_subnet.subnet-pu2.id}"]

  enable_deletion_protection = true
  }

  tags {
    Name = "test-lb-tf"
  }

resource "aws_lb_target_group" "test_target_group" {
  name = "tf-example-lb-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.vpc_test.id
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = "${aws_lb.test.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.test_target_group.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group_attachment" "test1" {
  target_group_arn = aws_lb_target_group.test_target_group.arn
  target_id        = aws_instance.web1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "test2" {
  target_group_arn = aws_lb_target_group.test_target_group.arn
  target_id        = aws_instance.web2.id
  port             = 80
}
