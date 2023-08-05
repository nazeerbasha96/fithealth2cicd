output "lbr_dns_name" {
  value = aws_lb.albr.dns_name
}
output "tg" {
  value = "${aws_lb_target_group.lbr_tg.arn}"
}
