output "instance_id" {
  value = aws_instance.jama.id
}

output "appserver_ip" {
  value = aws_instance.jama.private_ip
}

output "lb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.staging_lb.dns_name
}