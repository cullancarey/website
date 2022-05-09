module "static-s3-website-template" {
  source  = "cullancarey/static-s3-website-template/aws"
  version = "1.1.2"
  backup-website-bucket-region = "us-east-1"
  website-bucket-region = "us-east-2"
  root_domain_name = "cullancarey.com"
}