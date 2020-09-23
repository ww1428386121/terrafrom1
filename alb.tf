resource "aws_lb_target_group" "test_target_group" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_test.id
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg-pu.id]
  subnets            = [aws_subnet.subnet-pu1.id,aws_subnet.subnet-pu2.id]

  enable_deletion_protection = true

  tags = {
    Environment = "production"
  }
}