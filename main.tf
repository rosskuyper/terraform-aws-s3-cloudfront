# https://www.terraform.io/docs/modules/index.html#standard-module-structure

provider "aws" {
  alias = "main"
}

provider "aws" {
  alias = "virginia"
}

data "aws_region" "current" {}

#######
# S3 Buckets
#######
resource "aws_s3_bucket" "main" {
  provider = aws.main
  bucket   = "rk-website-${var.name}-${data.aws_region.current.name}"
  acl      = "private"

  versioning {
    enabled = var.versioning_enabled
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = var.s3_kms_key_id
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

#######
# Cloudfront distribution
#######
locals {
  s3_origin_id = "S3OriginId-${var.name}"
}

resource "aws_cloudfront_origin_access_identity" "main" {
  provider = aws.virginia
  comment  = "Created by Terraform (${var.name})"
}

resource "aws_cloudfront_distribution" "main" {
  provider            = aws.virginia
  aliases             = var.domain_names
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.default_root_object
  price_class         = "PriceClass_All"

  origin {
    domain_name = aws_s3_bucket.main.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.main.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = true
      headers      = []

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 7200
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.certificate_arn
    minimum_protocol_version = var.minimum_protocol_version
    ssl_support_method       = "sni-only"
  }
}

#######
# DNS for Cloudfront
#######
resource "aws_route53_record" "main" {
  count    = length(var.domain_names)
  provider = aws.virginia

  zone_id = var.zone_id
  name    = var.domain_names[count.index]
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = false
  }
}
