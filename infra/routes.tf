resource "aws_route_table" "pub-rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table" "priv-rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.terraform-ngw.id
  }

  tags = {
    Name = "priv-rt"
  }
}

resource "aws_route_table_association" "pub-sub1-rt-ass" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.pub-rt.id
}

resource "aws_route_table_association" "pub-sub2-rt-ass" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.pub-rt.id
}

resource "aws_route_table_association" "priv-sub1-rt-ass" {
  subnet_id      = aws_subnet.private_subnet-1.id
  route_table_id = aws_route_table.priv-rt.id
}

resource "aws_route_table_association" "priv-sub2-rt-ass" {
  subnet_id      = aws_subnet.private_subnet-2.id
  route_table_id = aws_route_table.priv-rt.id
}

