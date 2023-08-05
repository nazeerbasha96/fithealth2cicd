resource "aws_vpc" "javaserver_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "fithealthvpc"
  }
}
