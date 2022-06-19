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
