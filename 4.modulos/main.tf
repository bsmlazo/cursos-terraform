provider "aws" {
  region = local.region
}

locals {
  region = "us-east-1"
  ami    = var.ubuntu_ami[local.region]
}

data "aws_vpc" "vpc_default" {
  default = true
}

data "aws_subnet" "public_subnet" {
  for_each = var.servidores

  availability_zone = "${local.region}${each.value.az}"
  vpc_id            = data.aws_vpc.vpc_default.id
}

# referenciamos el modulo
module "servidores_ec2" {
  source = "./modulos/instancias-ec2"

  puerto_servidor = 8080
  tipo_instancia  = "t2.micro"
  ami_id          = local.ami

  # iteramos sobre un mapa, para poder hacerlo se hace con 2 variables, una que itera sobre las claves
  # y el otro itera sobre los valores del mapa
  servidores = {
    # donde id_srv será srv-1 o srv-2
    # y datos serán nombre y az
    for id_srv, datos in var.servidores :
    id_srv => { nombre = datos.nombre, subnet_id = data.aws_subnet.public_subnet[id_srv].id }
  }
}

module "loadbalancer" {
  source = "./modulos/loadbalancers"

  subnet_ids      = [for subnet in data.aws_subnet.public_subnet : subnet.id]
  instancia_ids   = module.servidores_ec2.instancia_ids
  puerto_lb       = 80
  puerto_servidor = 8080
}