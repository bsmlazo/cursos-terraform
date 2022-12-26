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

variable "tipo_instancia" {
  description = "Tipo de instancias EC2"
  type          = string
  default       = "t2.micro"
}

variable "ubuntu_ami" {
  description = "AMI por region"
  type = map(string)

  default = {
    # podemos nombrar la variable con o sin comillas dobles
    "us-east-1" = "ami-0574da719dca65348" # Ubuntu en Virginia
    us-east-2   = "ami-0283a57753b18025b" # Ubuntu en Ohio
  }
}

# variable de tipo mapa
variable "servidores" {
  description = "Mapa de servidores con nombres y AZs"

  type = map(object({
      nombre  = string,
      az      = string
    })
  )

  default = {
    "srv-1" = {
      nombre = "servidor-1",
      az = "a"
    },
    "srv-2" = {
      nombre = "servidor-2",
      az = "b"
    }
  }
}