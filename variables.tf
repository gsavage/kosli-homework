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

variable "wildcard_acm_cert" {
  description = "Wildcard TLS cert for the grahamandsarah.com domain"
  type        = string
  default     = "arn:aws:acm:us-east-1:359024362939:certificate/f362f432-83e1-4427-91a6-2a1e484af485"
}

variable "personal_domain" {
  description = "The domain on which I'll be hosting the two websites"
  type        = string
  default     = "grahamandsarah.com"
}

