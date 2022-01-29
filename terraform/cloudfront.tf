resource "aws_cloudfront_distribution" "website_distribution" {
  // origin is where CloudFront gets its content from.
  origin {
    // We need to set up a "custom" origin because otherwise CloudFront won't
    // redirect traffic from the root domain to the www domain, that is from
    // runatlantis.io to www.runatlantis.io.
    custom_origin_config {
      // These are all the defaults.
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }

    // Here we're using our S3 bucket's URL!
    domain_name = "${aws_s3_bucket.website.website_endpoint}"
    // This can be any name to identify this origin.
    origin_id   = "${var.root_domain_name}"
    custom_header {
          name  = "${var.header_name}"
          value = "${var.custom_header}"
        }
  }


  aliases = ["cullancarey.com", "www.cullancarey.com"]
  enabled             = true
  comment = "Distribution for cullancarey.com" 
  price_class = "PriceClass_100"
  wait_for_deployment = true

  // All values are defaults from the AWS console.
  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    // This needs to match the `origin_id` above.
    target_origin_id       = "${var.root_domain_name}"
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

  // Here's where our certificate is loaded in!
  viewer_certificate {
    acm_certificate_arn = "${aws_acm_certificate.certificate.arn}"
    ssl_support_method  = "sni-only"
    cloudfront_default_certificate = false
    minimum_protocol_version = "TLSv1.2_2021"
  }
}