variable "vpc_id" {
  description = "Value of aws_vpc for security group to attach to"
  type        = string
}

variable "private_subnet_id" {
  description = "Value of aws_private_subnet for instance"
  type        = string
}
