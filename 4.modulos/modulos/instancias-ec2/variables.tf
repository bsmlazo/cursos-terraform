// variables para el modulo instancias-ec2

variable "puerto_servidor" {
  description   = "Puerto para las instancias EC2"
  type          = number
  default       = 8080

  validation {
    condition = var.puerto_servidor > 0 && var.puerto_servidor <= 65536
    error_message = "Puerto incorrecto"
  }
}

variable "tipo_instancia" {
  description = "Tipo de instancias EC2"
  type          = string
}

variable "ami_id" {
  description = "Identificador de la AMI"
  type = string
}

variable "servidores" {
  description = "Mapa de servidores con nombres son su correspondiente subnet_id"

  type = map(object({
      nombre         = string,
      subnet_id      = string
    })
  )
}