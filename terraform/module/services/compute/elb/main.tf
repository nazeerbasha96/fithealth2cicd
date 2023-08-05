resource "aws_security_group" "lbr_sg" {
  vpc_id = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "lbr_sg"
  }

}
resource "aws_lb" "albr" {
  name               = var.lbrname
  internal           = false
  load_balancer_type = "application"
  subnets            = var.subnet_id
  security_groups    = [resource.aws_security_group.lbr_sg.id]
}
resource "aws_alb_listener" "lbr_listener" {
  load_balancer_arn = aws_lb.albr.arn
  protocol          = "HTTP"
  port              = 80
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lbr_tg.arn
  }

}
resource "aws_lb_target_group" "lbr_tg" {
  health_check {
    interval            = 30
    path                = "/fithealth2/healthcheck"
    protocol            = "HTTP"
    timeout             = 3
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
  name     = var.nametg
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group_attachment" "lbr_tg_attachment1" {
  # count             = 2
  target_group_arn = aws_lb_target_group.lbr_tg.arn
  target_id        = var.instance1_id
  # availability_zone =  element(var.availability_zone, count.index)
  port = 8080

}
resource "aws_lb_target_group_attachment" "lbr_tg_attachment2" {
  # count             = 2
  target_group_arn = aws_lb_target_group.lbr_tg.arn
  target_id        = var.instance2_id
  # availability_zone = "${var.availability_zone}"
  port = 8080

}



