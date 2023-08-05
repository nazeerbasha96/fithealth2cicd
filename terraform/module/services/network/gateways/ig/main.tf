resource "aws_internet_gateway" "fithealthig" {
  vpc_id = var.vpc_id
  tags = {
    "Name" = "fithealth_ig"
  }
}
resource "aws_route_table" "fithealth_ig_rt" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.fithealthig.id
  }
  tags = {
    "Name" = "fithealth_ig_rt"
  }

}
resource "aws_route_table_association" "fithealthrtassociation" {
  count          = length(var.subnet_id)
  route_table_id = aws_route_table.fithealth_ig_rt.id
  subnet_id      = element(var.subnet_id, count.index)
}
