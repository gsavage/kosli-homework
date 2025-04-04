variable "env" {
  description = "The deployment environment"
  type        = string
}

variable "upload_files_with_terraform" {
  description = "Should terraform apply upload website content?"
  type        = bool
}

variable "aws_profile" {
  description = "The name of the local AWS profile (from ~/.aws/config)"
  type        = string
}

variable "aws_account" {
  description = "The AWS account id - numeric string"
  type        = string
}
