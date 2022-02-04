resource "aws_cloudfront_distribution" "website_distribution" {
  origin {
    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }

    domain_name = "${aws_s3_bucket.website.website_endpoint}"
    origin_id   = "${var.root_domain_name}"
    custom_header {
          name  = "${var.header_name}"
          value = "${var.custom_header}"
        }
  }

  origin {
    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }

    domain_name = "${aws_s3_bucket.backup-website.website_endpoint}"
    origin_id   = "backup-${var.root_domain_name}"
    custom_header {
          name  = "${var.header_name}"
          value = "${var.custom_header}"
        }
  }

    origin_group {
    origin_id = "HA-website"

    failover_criteria {
      status_codes = [500, 502, 503, 504]
    }

    member {
      origin_id = "${var.root_domain_name}"
    }

    member {
      origin_id = "backup-${var.root_domain_name}"
    }
  }


  aliases = ["cullancarey.com", "www.cullancarey.com"]
  enabled             = true
  comment = "Distribution for cullancarey.com" 
  price_class = "PriceClass_100"
  wait_for_deployment = true

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    target_origin_id       = "HA-website"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    smooth_streaming = false
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = "${aws_acm_certificate.certificate.arn}"
    ssl_support_method  = "sni-only"
    cloudfront_default_certificate = false
    minimum_protocol_version = "TLSv1.2_2021"
  }
}