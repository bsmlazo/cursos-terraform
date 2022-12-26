// variables para el modulo loadbalancer

variable "subnet_ids" {
  description = "Todos los ids de las subnets donde provisionaremos el loadbalancer"
  type = set(string)
}

variable "instancia_ids" {
  description = "Todos los ids de las instancias para el target group"
  type = list(string)
}

variable "puerto_servidor" {
  description   = "Puerto para las instancias EC2"
  type          = number
  default       = 8080

  validation {
    condition = var.puerto_servidor > 0 && var.puerto_servidor <= 65536
    error_message = "Puerto incorrecto"
  }
}

variable "puerto_lb" {
  description = "Puerto para el ELB"
  type          = number
  default       = 80
}