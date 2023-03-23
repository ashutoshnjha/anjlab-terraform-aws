##################################################################################
# RESOURCES
##################################################################################

resource "aws_lb" "anjlab_web_alb" {
  name               = "anjlab-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.anjlab_webalb_sg.id]
  subnets            = [aws_subnet.anjlab_pubsubnet1.id, aws_subnet.anjlab_pubsubnet2.id]

  enable_deletion_protection = false

  tags = {
    Name = "AnjLab-WEB-ALB"
  }
}

resource "aws_lb_target_group" "anjlab_web_alb_tg" {
  name     = "anjlab-web-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.anjlab_vpc.id
  tags = {
    Name = "AnjLab-WEB-ALB-TG"
  }
}

resource "aws_lb_listener" "anjlab_lb_listner" {
  load_balancer_arn = aws_lb.anjlab_web_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.anjlab_web_alb_tg.arn
  }

  tags = {
    Name = "AnjLab-WEB-ALB-TG"
  }
}

resource "aws_lb_target_group_attachment" "anjlab_web_tg_instance1" {
  target_group_arn = aws_lb_target_group.anjlab_web_alb_tg.arn
  target_id        = aws_instance.anjlab_webvm1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "anjlab_web_tg_instance2" {
  target_group_arn = aws_lb_target_group.anjlab_web_alb_tg.arn
  target_id        = aws_instance.anjlab_webvm2.id
  port             = 80
}