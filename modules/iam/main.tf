terraform {
  required_version = ">= 1.2.3"
}

resource "aws_iam_user" "merq" {
  name = var.aws_iam_user_name
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
