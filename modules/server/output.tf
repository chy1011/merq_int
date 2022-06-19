output "instance_password" {
  description = "Value of instance"
  value       = aws_instance.demo_instance.get_password_data
}

output "instance_id" {
  description = "Value of instance id for elb"
  value       = aws_instance.demo_instance.id
}

output "security_group_id" {
  description = "Value of security group id for elb"
  value       = aws_security_group.demo_sg.id
}
