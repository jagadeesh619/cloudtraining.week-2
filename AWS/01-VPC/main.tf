resource "aws_vpc" "aws-week-2" {
  cidr_block = "172.16.0.0/16"
  tags = {
    Name = var.name
    terraform = true
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.aws-week-2.id

  tags = {
    Name = var.name
  }
}

resource "aws_subnet" "week-2-public" {
  vpc_id     = aws_vpc.aws-week-2.id
  cidr_block = "172.16.11.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.name}-public"
  }
}

resource "aws_subnet" "week-2-private" {
  vpc_id     = aws_vpc.aws-week-2.id
  cidr_block = "172.16.12.0/24"

  tags = {
    Name = "${var.name}-private"
  }
}


resource "aws_eip" "eip" {
  domain= "vpc"
}


resource "aws_nat_gateway" "week-2" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.week-2-public.id

  tags = {
    Name = "WEEK-2-NAT-GW"
  }
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "week-2-public" {
  vpc_id = aws_vpc.aws-week-2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "week2-pulic-route-table"
  }
}

resource "aws_route_table" "week-2-private" {
  vpc_id = aws_vpc.aws-week-2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.week-2.id
  }

  tags = {
    Name = "week2-private-route-table"
  }
}


resource "aws_route_table_association" "week2-public" {
  subnet_id      = aws_subnet.week-2-public.id
  route_table_id = aws_route_table.week-2-public.id
}

resource "aws_route_table_association" "week2-private" {
  subnet_id      = aws_subnet.week-2-private.id
  route_table_id = aws_route_table.week-2-private.id
}

resource "aws_instance" "week2-public" {
  ami           = var.ami
  instance_type = "t2.micro"
  key_name="jagadeesh-test"
  subnet_id     = aws_subnet.week-2-public.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  tags = {
    Name = "Week-2-public"
  }
}

resource "aws_instance" "week2-private" {
  ami           = var.ami
  instance_type = "t2.micro"
  key_name="jagadeesh-test"
  vpc_security_group_ids = [aws_security_group.allow_ec2-public-private.id]

  subnet_id     = aws_subnet.week-2-private.id
  tags = {
    Name = "Week-2-private"
  }
}


resource "aws_security_group" "allow_ssh" {
  name        = "AWS-week-2-SG"
  description = "Allow ssh inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.aws-week-2.id

  tags = {
    Name = "AWS-week-2-SG"
  }
}

resource "aws_security_group" "allow_ec2-public-private" {
  name        = "AWS-week-2--private-SG"
  description = "Allow inbound traffic from public ec2 to private ec2"
  vpc_id      = aws_vpc.aws-week-2.id

  tags = {
    Name = "AWS-week-2-private-SG"
  }
}

resource "aws_security_group_rule" "allow_public" {
  security_group_id = aws_security_group.allow_ssh.id
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}


resource "aws_security_group_rule" "egress_from_public" {
  security_group_id = aws_security_group.allow_ssh.id
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_public_private" {
  source_security_group_id = aws_security_group.allow_ssh.id
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.allow_ec2-public-private.id
}


resource "aws_security_group_rule" "egress_from_private" {
  source_security_group_id = aws_security_group.allow_ssh.id
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.allow_ec2-public-private.id
}