resource "aws_vpc" "week-2" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = var.name
    terraform = true
  }
}

resource "aws_subnet" "week-2" {
  vpc_id     = aws_vpc.week-2.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = var.name
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "WEEK-2-SG"
  description = "Allow SSH inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.week-2.id

  tags = {
    Name = "WEEK-2-SG"
  }
}


resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = aws_vpc.week-2.cidr_block
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}