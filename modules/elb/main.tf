terraform {
  required_version = ">= 1.2.3"
}

resource "aws_lb" "demo_lb" {
  name                             = "demo-lb"
  load_balancer_type               = "network"
  internal                         = false
  enable_cross_zone_load_balancing = true
  subnets                          = [var.aws_vpc_public_subnet_id]

  tags = {
    Name = "demo_lb"
  }
}

resource "aws_lb_target_group" "demo_lb_http_target_group" {
  name        = "aws-http-target-group"
  port        = "80"
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.aws_vpc_id

  health_check {
    enabled = true
    port    = 80
  }
}

resource "aws_lb_listener" "demo_lb_http_listener" {
  load_balancer_arn = aws_lb.demo_lb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.demo_lb_http_target_group.arn
  }
}

resource "aws_lb_target_group_attachment" "demo_lb_http_target_group_attachment" {
  target_group_arn = aws_lb_target_group.demo_lb_http_target_group.arn
  target_id        = var.aws_demo_instance_id
  port             = 80
}

resource "aws_lb_target_group" "demo_lb_ssh_target_group" {
  name        = "aws-ssh-target-group"
  port        = "22"
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.aws_vpc_id
}

resource "aws_lb_listener" "demo_lb_ssh_listener" {
  load_balancer_arn = aws_lb.demo_lb.arn
  port              = 22
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.demo_lb_ssh_target_group.arn
  }
}

resource "aws_lb_target_group_attachment" "demo_lb_ssh_target_group_attachment" {
  target_group_arn = aws_lb_target_group.demo_lb_ssh_target_group.arn
  target_id        = var.aws_demo_instance_id
  port             = 22
}
