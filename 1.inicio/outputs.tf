output "dns_publico_servidor" {
  description = "DNS público de nuestra instancia"
  value = [ for servidor in aws_instance.servidor : 
    "http://${servidor.public_dns}:${var.puerto_servidor}"
  ]
}

output "dns_load_balancer" {
  description = "DNS público de nuestro balaceador"
  value = "http://${aws_lb.alb_tf.dns_name}:${var.puerto_lb}"
}