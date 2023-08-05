resource "aws_subnet" "javaserver_subnet" {
  vpc_id     = var.vpc_id
  availability_zone = var.availabilty_zone
  cidr_block = var.subnet_cidr
  tags = {
    Name = var.subnet_name
  }
  

}
