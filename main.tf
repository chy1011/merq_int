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

resource "aws_iam_user" "merq" {
  name = "merq-aws"
}
resource "aws_iam_user_policy_attachment" "merq-policy" {
  user       = aws_iam_user.merq.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_user_policy_attachment" "merq-policy-change-password" {
  user       = aws_iam_user.merq.name
  policy_arn = "arn:aws:iam::aws:policy/IAMUserChangePassword"
}

resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 8
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
}

resource "aws_iam_user_login_profile" "merq-login" {
  user                    = aws_iam_user.merq.name
  password_reset_required = true
}

output "encrypted_password" {
  value = aws_iam_user_login_profile.merq-login.encrypted_password
}

output "password" {
  value = aws_iam_user_login_profile.merq-login.password
}
