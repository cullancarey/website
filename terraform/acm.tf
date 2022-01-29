provider "aws" {
  alias = "virginia"
  region = "us-east-1"
}

resource "aws_acm_certificate" "certificate" {
  domain_name  = "${var.root_domain_name}"
  provider = aws.virginia
  subject_alternative_names = [
              "www.cullancarey.com"
            ]
  validation_method = "DNS"
  options {
      certificate_transparency_logging_preference = "ENABLED"   
          }

}