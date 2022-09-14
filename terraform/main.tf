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
    bucket = "terraform-045107234435"
    key    = "portfolio-website.tfstate"
    region = "us-east-2"
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

