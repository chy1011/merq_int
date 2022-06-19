variable "vpc_id" {
  description = "Value of aws_vpc for security group to attach to"
  type        = string
}

variable "public_subnet_id" {
  description = "Value of aws_public_subnet for instance"
  type        = string
}
