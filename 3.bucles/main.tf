provider "aws" {
  region = "us-east-1"
}

variable "usuarios" {
  description   = "Numero usuarios IAM"
  type          = number

  # si quito este valor por defecto, se solicitará por
  # ventana interactiva
  default = 4
}

resource "aws_iam_user" "ejemplo_user_tf" {
  count = var.usuarios

  name = "usuario-tf-${count.index}"
}

# se imprime el arn de un usuario de la lista
output "arn_usuario" {
  description = "ARN del usuario"
  value = aws_iam_user.ejemplo_user_tf[1].arn
}

output "arn_todos_usuarios" {
  description = "ARN todos usuarios"
  value = aws_iam_user.ejemplo_user_tf[*].arn
}