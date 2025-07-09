resource "aws_lb" "this" {
  name               = var.name
  load_balancer_type = "network"
  subnets            = var.subnet_ids
  internal           = true

  tags = {
    Name = var.name
  }
}

resource "aws_lb_target_group" "this" {
  name     = "${var.name}-tg"
  port     = var.target_port
  protocol = "TCP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    protocol = "TCP"
    port     = var.target_port
  }

  tags = {
    Name = "${var.name}-tg"
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.listener_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_lb_target_group_attachment" "this" {
  for_each = {
    for ip in var.target_ips :
    ip => {
      ip = ip
    }
  }

  target_group_arn = aws_lb_target_group.this.arn
  target_id        = each.value.ip
  port             = var.target_port
  # Do NOT specify availability_zone
}
