locals {
  s3_origin_id = "website-origin"
}

resource "aws_cloudfront_origin_access_identity" "website_origin_access" {
  comment = "The OAI for this ${var.env} distro"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  count = 1
  origin {
    domain_name = aws_s3_bucket.static_site.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.website_origin_access.cloudfront_access_identity_path
    }
  }

  enabled = true

  is_ipv6_enabled     = false
  default_root_object = "index.html"
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
