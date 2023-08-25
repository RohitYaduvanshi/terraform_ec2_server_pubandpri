provider "aws" {
  region = "ap-southeast-2"
}
resource "aws_vpc" "demo" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    name = "demo"
  }
}
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.demo.id
  cidr_block = "10.0.0.0/24"

  tags = {
    name = "public"
  }
}
resource "aws_subnet" "private" {
  vpc_id = aws_vpc.demo.id
  cidr_block = "10.0.16.0/24"
  tags = {
    name = "private"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.demo.id

  tags = {
    Name = "igw"
  }
}
resource "aws_route_table" "pubroute" {
  vpc_id = aws_vpc.demo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "pubrou"
  }
}
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.pubroute.id
}

resource "aws_eip" "OPEIP" {
#  instance = aws_instance.web.id
#   vpc = aws_vpc.demo.id


  tags = {
    name = "opeip"
  }
}

resource "aws_nat_gateway" "natg" {
#  connectivity_type = "private"
  subnet_id         = aws_subnet.public.id
  allocation_id = aws_eip.OPEIP.id

  tags = {
    name = "natg"
  }
}
resource "aws_route_table" "prirout" {
  vpc_id = aws_vpc.demo.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natg.id
  }

  tags = {
    Name = "prirout"
  }
}
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.prirout.id
}
resource "aws_key_pair" "rohitkey" {
  key_name   = "rohit-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDhTkshUzCy/Ee8qc6RNYFtfce2kixxJKb5/GQWOGRlm/yWxTBCT/ON0gdpxGm17vq9rRBipJB2ngaA4mug9WcBTdHw/VruKCGcQ9PUXYo3f5w1RFsqutMysDERfNZAna1boHfi1HjaeTp5x1zuEKFqP5cO2Wwl6L59+hwVaONoy5pP4tuSDNMlKwftPvX+mfRLV6zlxB1rhtyHAmC1y047VjBYsxZdapUy0oGE2phPY2kwuJkKqGfzgaExKbWaxIGZt1cTC5MwM03QCjD0vsmhEmVihsRtg5TAQjwbw7UG2gugM+jCgFWhgJphEaluUpZXJvSGlSUWmuhMuqWxGx1xKEVGRZkPPnHAziF9bRxs38fQcWDbR0Cfexieh/dg3ZYSSs5+stLJANuo+HQimsyIv1wWFlu06HVz2Nn6myE35G/d/2g0p47s+C6tyvuXNCaon+fsoOK4rd4ofNUSQr1KrPnBlswrgOws3HkRj49+5o1kjKPR/YobKAuCoimwBbU= rohit@rohit"
}
resource "aws_security_group" "sec1" {
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.demo.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    #    ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    #    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "sec1"
  }
}
resource "aws_instance" "public" {
  ami           = "ami-0310483fb2b488153"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public.id
  key_name =  aws_key_pair.rohitkey.key_name
  security_groups = aws_security_group.sec1[*].id
  associate_public_ip_address = true

  tags = {
    Name = "pubins"
  }
}
resource "aws_security_group" "sec2" {
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.demo.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    #    ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    #    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "sec2"
  }
}
resource "aws_instance" "private" {
  ami                         = "ami-0310483fb2b488153"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.private.id
  key_name                    = aws_key_pair.rohitkey.key_name
  security_groups             = aws_security_group.sec2[*].id

  tags = {
    Name = "priins"
  }
}