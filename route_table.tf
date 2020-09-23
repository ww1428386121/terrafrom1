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