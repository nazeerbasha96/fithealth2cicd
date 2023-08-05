
resource "aws_eip" "fithealth_EIP" {
  vpc = true
  tags = {
    "Name" = "fithealth_eip"
  }
}

resource "aws_nat_gateway" "fithealth_NG" {
  subnet_id  = var.public_subnet_id
  allocation_id     = aws_eip.fithealth_EIP.id
  connectivity_type = "public"
  tags = {
    "Name" = "fithealth_NAT"
  }

}

#NAT 
resource "aws_route_table" "fithealth_ng_rt" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.fithealth_NG.id


  }
  tags = {
    Name = " fithealth_nat_rt"
  }
}
resource "aws_route_table_association" "fithealth_ng_association" {
  count          = length(var.subnet_id)
  route_table_id = aws_route_table.fithealth_ng_rt.id
  subnet_id      = element(var.subnet_id, count.index)

}





