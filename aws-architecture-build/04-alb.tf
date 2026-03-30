resource "aws_lb" "frontend_alb" {
  name               = "production-frontend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]

  subnets = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]

  tags = {
    Name = "frontend-alb"
  }
}

resource "aws_lb_target_group" "frontend_tg" {
  name     = "frontend-target-group"
  port     = "80"
  protocol = "HTTP" # Default port/protocol
  vpc_id   = aws_vpc.main_network.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "frontend_listener" {
  load_balancer_arn = aws_lb.frontend_alb.arn
  port              = 80
  protocol          = "HTTP" # Listen to the world

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "web_attachment" {
  target_group_arn = aws_lb_target_group.frontend_tg.arn
  target_id        = aws_instance.web_server.id
  port             = 80
}