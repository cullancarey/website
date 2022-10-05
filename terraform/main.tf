provider "aws" {
  region = "us-east-2"
  default_tags {
    tags = {
      Project = "portfolio-website"
    }
  }
}

terraform {
  backend "s3" {
  }
}

provider "aws" {
  alias  = "cloudfront-certificate"
  region = "us-east-1"
  default_tags {
    tags = {
      Project = "portfolio-website"
    }
  }
}

provider "aws" {
  alias  = "backup-website-region"
  region = "us-east-1"
  default_tags {
    tags = {
      Project = "portfolio-website"
    }
  }
}

