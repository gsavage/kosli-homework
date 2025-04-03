resource "aws_s3_bucket" "static_site" {
  bucket = "gsavage-kosli-static-site-${var.env}"
} 

resource "aws_s3_object" "upload_content" {
  bucket = "gsavage-kosli-static-site-${var.env}"

  for_each = fileset("website/", "**/*")

  key = each.value
  source = "website/${each.value}"
  etag = filemd5("website/${each.value}")
}
