// main con la logica para el modulo instancias-ec2

resource "aws_instance" "servidor" {
  for_each = var.servidores

  ami = var.ami_id
  instance_type = var.tipo_instancia
  subnet_id = each.value.subnet_id
  vpc_security_group_ids = [ aws_security_group.mi_sg_tf.id ]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hola Terraformers! Desde ${each.value.nombre}" > index.html
              nohup busybox httpd -f -p ${var.puerto_servidor} &
              EOF

  tags = {
    "Name" = each.value.nombre
  }
}

resource "aws_security_group" "mi_sg_tf" {
    name = "primer-servidor-sg"

    ingress {
      cidr_blocks = [ "0.0.0.0/0" ]
      description = "Acceso al puerto ${var.puerto_servidor} desde internet"
      from_port   = var.puerto_servidor
      protocol    = "TCP"
      to_port     = var.puerto_servidor
    }
}