# A simple repository for storing the built application images

# Note that we only want one of these.  In a larger project we'd have 
# the images stored in a central account, and then pulled into each
# environment.  To simulate this, I've put a "count" here that will
# only create the ECR in the dev environment.

resource "aws_ecr_repository" "kosli_site_ecr" {

  count = var.env == "dev" ? 1 : 0

  name                 = "kosli-site"
  force_delete         = true
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
