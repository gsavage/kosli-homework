resource "aws_ecr_repository" "kosli_site_ecr" {

  count = var.env == "dev" ? 1 : 0

  name                 = "kosli-site"
  force_delete         = true
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
