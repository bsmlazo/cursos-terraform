// main con la logica del modulo loadbalancer

resource "aws_lb" "alb_tf" {
  load_balancer_type  = "application"
  name                = "terraformers-alb"
  security_groups     = [ aws_security_group.alb.id ]
  subnets             = var.subnet_ids
}

resource "aws_security_group" "alb" {
  name = "alb-sg"

  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Acceso al puerto 80 desde internet"
    from_port = var.puerto_lb
    protocol = "TCP"
    to_port = var.puerto_lb
  }

  egress {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Acceso al puerto 8080 hacia las instancias"
    from_port = var.puerto_servidor
    protocol = "TCP"
    to_port = var.puerto_servidor
  }
}

data "aws_vpc" "vpc_default" {
  default = true
}

resource "aws_lb_target_group" "this" {
  name      = "terraform-alb-tg"
  port      = var.puerto_lb
  vpc_id    = data.aws_vpc.vpc_default.id
  protocol  = "HTTP"

  health_check {
    enabled   = true
    matcher   = "200"
    path      = "/"
    port      = var.puerto_servidor
    protocol  = "HTTP" 
  }
}

resource "aws_lb_target_group_attachment" "servidor" {
  count = length(var.instancia_ids)

  target_group_arn  = aws_lb_target_group.this.arn
  target_id         = element(var.instancia_ids, count.index)
  port              = var.puerto_servidor 
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.alb_tf.arn
  port              = var.puerto_lb
  protocol          = "HTTP"

  default_action {
    target_group_arn  = aws_lb_target_group.this.arn
    type              = "forward"
  }
}