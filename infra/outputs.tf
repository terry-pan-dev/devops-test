output "loadbalancer_dns_name" {
  value = aws_alb.ecs_load_balancer.dns_name
}
