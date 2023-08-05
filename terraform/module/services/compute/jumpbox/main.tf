resource "aws_security_group" "fithealthsshgroup1" {
  vpc_id = var.vpc_id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "ssh acccess only for ec2"
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = -1
  }
  tags = {
    "Name" = "fithealthssh_group"
  }
}

resource "aws_instance" "jumpboxec2instance" {
  subnet_id                   = var.subnet_id
  ami                         = var.ami
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.fithealthsshgroup1.id]
  associate_public_ip_address = true
  key_name = var.key_name
  tags = {
    "Name" = "jumpboxec2"
  }
}

