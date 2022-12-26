output "dns_load_balancer" {
  description = "DNS público de nuestro balaceador"
  value = "http://${aws_lb.alb_tf.dns_name}:${var.puerto_lb}"
}