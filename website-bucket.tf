# The bucket that will hold the static website
#
resource "aws_s3_bucket" "static_site" {
  bucket = "gsavage-kosli-static-site-${var.env}"
}

resource "aws_s3_bucket_policy" "allow_access_from_cloudfront" {
  bucket = aws_s3_bucket.static_site.id
  policy = data.aws_iam_policy_document.allow_access_from_cloudfront.json
}

data "aws_iam_policy_document" "allow_access_from_cloudfront" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = ["s3:GetObject"]

    resources = ["${aws_s3_bucket.static_site.arn}/*"]
  }
  statement {
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.website_origin_access.iam_arn]
    }

    actions = ["s3:GetObject"]

    resources = ["${aws_s3_bucket.static_site.arn}/*"]
  }
}



# Should Terraform upload the website files?
#
resource "aws_s3_object" "upload_content" {
  bucket     = aws_s3_bucket.static_site.id
  depends_on = [aws_s3_bucket.static_site]

  for_each = var.upload_files_with_terraform ? fileset("website/", "**/*") : []

  key          = each.value
  source       = "website/${each.value}"
  content_type = each.value
  etag         = filemd5("website/${each.value}")
}
