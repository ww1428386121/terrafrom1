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