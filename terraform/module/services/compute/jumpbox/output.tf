
output "jumpboxec2_public_ip" {
  value = aws_instance.jumpboxec2instance.public_ip
}
