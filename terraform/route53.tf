data "aws_route53_zone" "root_zone" {
  name = var.root_domain_name
}


resource "aws_route53_record" "root_cloudfront_record" {
  zone_id = data.aws_route53_zone.root_zone.zone_id
  name    = var.root_domain_name
  type    = "A"
  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.website_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.website_distribution.hosted_zone_id
  }
}

resource "aws_route53_record" "acm_val_records" {
  for_each = {
    for dvo in aws_acm_certificate.cloudfront_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 300
  type            = each.value.type
  zone_id         = data.aws_route53_zone.root_zone.zone_id
}


resource "aws_route53_record" "sub_cloudfront_record" {
  zone_id = data.aws_route53_zone.root_zone.zone_id
  name    = "www.${var.root_domain_name}"
  type    = "A"
  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.website_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.website_distribution.hosted_zone_id
  }
}

#############################################
#########intake api records##################
#############################################

resource "aws_route53_record" "intake_api_domain_record" {
  zone_id = data.aws_route53_zone.root_zone.zone_id
  name    = var.intake_api_domain
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.contact_form_intake_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.contact_form_intake_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "intake_api_acm_val_records" {
  for_each = {
    for dvo in aws_acm_certificate.intake_api_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 300
  type            = each.value.type
  zone_id         = data.aws_route53_zone.root_zone.zone_id
}
