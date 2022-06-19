output "instance_password" {
  description = "Value of instance"
  value       = aws_instance.demo_instance.password_data
}
