resource "aws_key_pair" "fithealthkp" {
  key_name   = var.key_name
  public_key = var.public_key

}
