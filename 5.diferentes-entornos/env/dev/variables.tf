variable "puerto_servidor" {
  description = "Puerto para las instancias EC2"
  type        = number
  default     = 8080

  validation {
    condition     = var.puerto_servidor > 0 && var.puerto_servidor <= 65536
    error_message = "El valor del puerto debe estar comprendido entre 1 y 65536."
  }
}

variable "ubuntu_ami" {
  description = "AMI por region"
  type        = map(string)

  default = {
    # podemos nombrar la variable con o sin comillas dobles
    "us-east-1" = "ami-0574da719dca65348" # Ubuntu en Virginia
    us-east-2   = "ami-0283a57753b18025b" # Ubuntu en Ohio
  }
}

variable "servidores" {
  description = "Mapa de servidores con su correspondiente AZ"

  type = map(object({
    nombre = string,
    az     = string
    })
  )

  default = {
    "ser-1" = { nombre = "servidor-1", az = "a" },
    "ser-2" = { nombre = "servidor-2", az = "b" },
  }
}