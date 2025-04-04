provider "aws" {
  profile                  = var.aws_profile
  shared_credentials_files = ["/home/dev/.aws/credentials"]
  shared_config_files      = ["/home/dev/.aws/config"]
}

