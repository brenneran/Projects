// Creating  the Application Load Balancer for staging instance
resource "aws_lb" "staging_lb" {
  name               = "${var.name}-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = var.alb_security_groups
  subnets            = var.alb_subnets
  tags = merge(local.tags, {
    Role = "jama/infra"
  })
  lifecycle {
    ignore_changes = [
      subnets
    ]
  }
}

// Creating Target Group for 443
resource "aws_lb_target_group" "jama-staging-alb-443" {
  name                 = "${var.name}-443-tg"
  target_type          = "ip"
  port                 = 443
  protocol             = "HTTPS"
  vpc_id               = data.aws_subnet.app_subnet.vpc_id
  deregistration_delay = 120
  stickiness {
    type    = "lb_cookie"
    enabled = true
  }
  health_check {
    path                = "/"
    protocol            = "HTTPS"
    port                = "443"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 2
    interval            = 5
    matcher             = "200-399"
  }
  tags = merge(local.tags, {
    Role = "${var.name}/infra/tg"
  })
}

// Attach Target Group of 443 to our ALB
resource "aws_lb_target_group_attachment" "jama-staging-alb-443-attach" {
  target_group_arn = aws_lb_target_group.jama-staging-alb-443.arn
  target_id        = aws_instance.jama.private_ip
  port             = 443
}

// Creating Target Group for 8800
resource "aws_lb_target_group" "jama-staging-alb-8800" {
  name                 = "${var.name}-8800-tg"
  target_type          = "ip"
  port                 = 8800
  protocol             = "HTTPS"
  vpc_id               = data.aws_subnet.app_subnet.vpc_id
  deregistration_delay = 120
  stickiness {
    type    = "lb_cookie"
    enabled = true
  }
  health_check {
    path                = "/"
    protocol            = "HTTPS"
    port                = "443"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 2
    interval            = 5
    matcher             = "200-399"
  }
  tags = merge(local.tags, {
    Role = "${var.name}/infra/tg"
  })

}

// Attach Target Group of 8800 to our ALB
resource "aws_lb_target_group_attachment" "jama-staging-alb-8800-attach" {
  target_group_arn = aws_lb_target_group.jama-staging-alb-8800.arn
  target_id        = aws_instance.jama.private_ip
  port             = 8800
}

// Create listener for port 80 forward to 443
resource "aws_lb_listener" "alb_http_listener" {
  load_balancer_arn = aws_lb.staging_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jama-staging-alb-443.arn
  }
}

// Create listener for port 443 to 443
resource "aws_lb_listener" "alb_https_listener" {
  load_balancer_arn = aws_lb.staging_lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jama-staging-alb-443.arn
  }
}

// Create listener for port 8800
resource "aws_lb_listener" "alb_https8800_listener" {
  load_balancer_arn = aws_lb.staging_lb.arn
  port              = "8800"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jama-staging-alb-8800.arn
  }
}
