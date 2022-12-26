output "instancia_ids" {
  description = "Valores de todos los IDs de las instancias"
  value = [ for srv in aws_instance.servidor : srv.id ]
}