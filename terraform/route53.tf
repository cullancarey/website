resource "aws_route53_zone" "cullancarey" {
  name = "${var.root_domain_name}"
  comment = "HostedZone created by Route53 Registrar"
}



resource "aws_route53_record" "ns_cullancarey" {
  name            = "${var.root_domain_name}"
  ttl             = 172800
  type            = "NS"
  zone_id         = aws_route53_zone.cullancarey.zone_id

  records = [
    aws_route53_zone.cullancarey.name_servers[0],
    aws_route53_zone.cullancarey.name_servers[1],
    aws_route53_zone.cullancarey.name_servers[2],
    aws_route53_zone.cullancarey.name_servers[3],
  ]
}

resource "aws_route53_record" "soa_cullancarey" {
  name            = "${var.root_domain_name}"
  ttl             = 900
  type            = "SOA"
  zone_id         = aws_route53_zone.cullancarey.zone_id
  records = [
    "${trim(aws_route53_zone.cullancarey.name_servers[3], ".")}. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400"
  ]
}

resource "aws_route53_record" "cloudfront_cullancarey" {
  zone_id = aws_route53_zone.cullancarey.zone_id
  name    = "${var.root_domain_name}"
  type    = "A"
  alias {
    evaluate_target_health = false
    name = aws_cloudfront_distribution.website_distribution.domain_name
    zone_id = aws_cloudfront_distribution.website_distribution.hosted_zone_id
  }
}

resource "aws_route53_record" "cloudfront_wwwcullancarey" {
  zone_id = aws_route53_zone.cullancarey.zone_id
  name    = "${var.sub_domain}"
  type    = "A"
  alias {
    evaluate_target_health = false
    name = aws_cloudfront_distribution.website_distribution.domain_name
    zone_id = aws_cloudfront_distribution.website_distribution.hosted_zone_id
  }
} 

resource "aws_route53_record" "acm_val_records" {
  for_each = {
    for dvo in aws_acm_certificate.certificate.domain_validation_options : dvo.domain_name => {
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
  zone_id         = aws_route53_zone.cullancarey.zone_id
}

