variable "env" {
  description = "The deployment environment"
  type        = string
}

variable "upload_files_with_terraform" {
  description = "Should terraform apply upload website content?"
  type        = bool
}
