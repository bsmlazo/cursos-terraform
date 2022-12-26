# el provider es el componente que nos permite trabajar
# con un proveedor cloud determinado, en este caso aws
provider "aws" {
  region = local.region
}

# variables de tipo local
locals {
  region = "us-east-1"
  ami = var.ubuntu_ami[local.region]
}

# esto es una query que hacemos para consultar datos a AWS
# para este caso obtenemos la información de la VPC por defecto
data "aws_vpc" "vpc_default" {
  default = true
}

data "aws_subnet" "public_subnet" {
  for_each = var.servidores

  availability_zone = "${local.region}${each.value.az}"
  vpc_id = data.aws_vpc.vpc_default.id
}

# Se define el recurso que a crear
resource "aws_instance" "servidor" {
  for_each = var.servidores

  ami = local.ami
  instance_type = var.tipo_instancia
  subnet_id = data.aws_subnet.public_subnet[each.key].id # each.key es srv-1 o srv-2
  vpc_security_group_ids = [ aws_security_group.mi_sg_tf.id ]

  # enviamos un script de inicio de la instancia
  user_data = <<-EOF
              #!/bin/bash
              echo "Hola Terraformers! Desde ${each.value.nombre}" > index.html
              nohup busybox httpd -f -p ${var.puerto_servidor} &
              EOF

  # agregamos tags para nuestro recurso, en este caso el nombre de la instancia
  tags = {
    "Name" = each.value.nombre
  }
}

# creamos el grupo de seguridad para el acceso a la instancia desde afuera
resource "aws_security_group" "mi_sg_tf" {
    name = "primer-servidor-sg"

    ingress {
      security_groups = [ aws_security_group.alb.id ]
      description = "Acceso al puerto ${var.puerto_servidor} desde internet"
      from_port   = var.puerto_servidor
      protocol    = "TCP"
      to_port     = var.puerto_servidor
    }
}

#creamos el load balancer
resource "aws_lb" "alb_tf" {
  load_balancer_type  = "application"
  name                = "terraformers-alb"
  security_groups     = [ aws_security_group.alb.id ]
  subnets             = [ for subnet in data.aws_subnet.public_subnet : subnet.id ]
}

# grupo de seguridad para el load balancer
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

# es una practica de terraform, que si no tenemos otro recurso
# de este tipo, se le puede llamar 'this'
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

# asociamos los servidores al target group del balanceador
resource "aws_lb_target_group_attachment" "servidor" {
  for_each = var.servidores
  target_group_arn  = aws_lb_target_group.this.arn
  target_id         = aws_instance.servidor[each.key].id
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