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
    "ns-849.awsdns-42.net. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400"
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

resource "aws_route53_record" "acm1_cullancarey" {
  name            = "_a10f9613f746f05e06ec39e402705646.cullancarey.com"
  ttl             = 300
  type            = "CNAME"
  zone_id         = aws_route53_zone.cullancarey.zone_id
  records = [
    "_c39103ffa3979b109d29c1b653c16be8.pczglchxlc.acm-validations.aws."
  ]
}

resource "aws_route53_record" "acm2_cullancarey" {
  name            = "_658a13af77bf89bc1df122a70cbcae35.www.cullancarey.com"
  ttl             = 300
  type            = "CNAME"
  zone_id         = aws_route53_zone.cullancarey.zone_id
  records = [
    "_745d90c3e5c428210f368c964e49a25a.pczglchxlc.acm-validations.aws."
  ]
}