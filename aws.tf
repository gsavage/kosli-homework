provider "aws" {
  profile                  = "kosli"
  shared_credentials_files = ["/home/dev/.aws/credentials"]
  shared_config_files      = ["/home/dev/.aws/config"]
}

