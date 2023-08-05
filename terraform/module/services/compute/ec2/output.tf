output "fithealthec2_private_ip" {
  value = aws_instance.fithealthec2instance.private_ip

}
output "instance_id" {
  value = "${aws_instance.fithealthec2instance.id}"
  
}

# output "jumpboxec2_public_ip" {
#   value = aws_instance.fithealthec2instance.public_ip
# }
