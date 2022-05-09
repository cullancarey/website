provider "aws" {
  region = "us-east-2"
}


terraform {
  backend "s3" {
    bucket = "terraform-045107234435"
    key    = "portfolio-website.tfstate"
    region = "us-east-2"
  }
}
