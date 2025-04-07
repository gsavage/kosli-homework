resource "aws_security_group" "lb_sg" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.env}-app-lb-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress80" {
  security_group_id = aws_security_group.lb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  tags = {
    Name = "${var.env}-ingress-port80"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress443" {
  security_group_id = aws_security_group.lb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  tags = {
    Name = "${var.env}-ingress-port443"
  }
}

resource "aws_vpc_security_group_egress_rule" "egress" {
  security_group_id = aws_security_group.lb_sg.id
  cidr_ipv4         = "10.0.0.0/16"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_lb" "load_balancer" {
  name               = "${var.env}-kosli-app-lb"
  load_balancer_type = "application"
  subnets            = [aws_subnet.a.id, aws_subnet.b.id]
  internal           = false
  security_groups    = [aws_security_group.lb_sg.id]
}

resource "aws_lb_target_group" "target_group_ip" {
  name        = "${var.env}-kosli-app-tg-ip"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    unhealthy_threshold = 3
  }
  deregistration_delay = 5
}

resource "aws_lb_listener" "listener_http" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_ip.arn
  }
}

resource "aws_lb_listener" "listener_https" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.wildcard_acm_cert_eu_west_2
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_ip.arn
  }
}
