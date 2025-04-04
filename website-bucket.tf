# The bucket that will hold the static website
#
resource "aws_s3_bucket" "static_site" {
  bucket = "gsavage-kosli-static-site-${var.env}"
}

# Should Terraform upload the website files?
#
resource "aws_s3_object" "upload_content" {
  bucket = aws_s3_bucket.static_site.id
  depends_on = [aws_s3_bucket.static_site]

  for_each = var.upload_files_with_terraform ? fileset("website/", "**/*") : []

  key    = each.value
  source = "website/${each.value}"
  content_type = each.value
  etag   = filemd5("website/${each.value}")
}
