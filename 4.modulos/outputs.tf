
output "dns_load_balancer" {
  description = "DNS público de nuestro balaceador"
  value       = module.loadbalancer.dns_load_balancer
}