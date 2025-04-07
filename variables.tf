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

# The Cert stored in us-east-1, suitable for use in Cloudfront
variable "wildcard_acm_cert_global" {
  description = "Wildcard TLS cert for the grahamandsarah.com domain"
  type        = string
  default     = "arn:aws:acm:us-east-1:359024362939:certificate/f362f432-83e1-4427-91a6-2a1e484af485"
}

# The Cert stored in eu-west-2, suitable for use in an ALB
variable "wildcard_acm_cert_eu_west_2" {
  description = "Wildcard TLS cert for the grahamandsarah.com domain"
  type        = string
  default     = "arn:aws:acm:eu-west-2:359024362939:certificate/4df3c09c-2065-4ed6-ad56-b730e9292641"
}

variable "personal_domain" {
  description = "The domain on which I'll be hosting the two websites"
  type        = string
  default     = "grahamandsarah.com"
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "service_task_count" {
  description = "How many copies of the app task should run in the service?"
  type        = number
}

