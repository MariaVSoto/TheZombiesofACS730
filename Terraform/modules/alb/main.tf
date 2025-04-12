# Application Load Balancer
resource "aws_lb" "web_alb" {
  name               = "${var.environment}-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-web-alb"
    }
  )
}

# Target Group for Web Servers
resource "aws_lb_target_group" "web" {
  name     = "${var.environment}-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval            = 30
    matcher            = "200"
    path               = "/"
    port               = "traffic-port"
    protocol           = "HTTP"
    timeout            = 5
    unhealthy_threshold = 2
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.environment}-web-tg"
    }
  )
}

# Attach instances to target group
resource "aws_lb_target_group_attachment" "webserver1" {
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = var.webserver1_id
  port             = 80
}

resource "aws_lb_target_group_attachment" "webserver3" {
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = var.webserver3_id
  port             = 80
}

# Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
} 
} 