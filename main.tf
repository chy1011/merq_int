provider "aws" {
  shared_config_files      = ["/Users/chanhouyong/.aws/config"]
  shared_credentials_files = ["/Users/chanhouyong/.aws/credentials"]
}

module "vpc" {
  source                  = "./modules/vpc"
  aws_vpc_cidr            = "118.189.0.0/16"
  aws_subnet_public_cidr  = "118.189.0.0/24"
  aws_subnet_private_cidr = "118.189.1.0/24"
}

module "instance" {
  depends_on = [
    module.vpc
  ]

  source            = "./modules/server"
  vpc_id            = module.vpc.vpc_id
  private_subnet_id = module.vpc.private_subnet_id
}

module "elb" {
  depends_on = [
    module.vpc,
    module.instance
  ]

  source                   = "./modules/elb"
  aws_security_group       = module.instance.security_group_id
  aws_vpc_public_subnet_id = module.vpc.public_subnet_id
  aws_demo_instance_id     = module.instance.instance_id
  aws_vpc_id               = module.vpc.vpc_id
}

module "iam" {
  source            = "./modules/iam"
  aws_iam_user_name = "merq-aws"
}

output "password" {
  value = module.iam.password
}

output "lb_dns" {
  value = module.elb.lb_dns
}
