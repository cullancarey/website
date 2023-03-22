provider "aws" {
  region = "us-east-2"
  default_tags {
    tags = {
      Project     = "portfolio-website"
      Website     = var.root_domain_name
      Environment = var.environment
    }
  }
}

terraform {
  backend "s3" {
  }
  required_providers {
    aws = {
      version = "~> 4.38.0"
    }
    archive = {
      version = "~> 2.2.0"
    }
  }

  required_version = "~> 1.4.2"
}

provider "archive" {}

provider "aws" {
  alias  = "cloudfront-certificate"
  region = "us-east-1"
  default_tags {
    tags = {
      Project     = "portfolio-website"
      Website     = var.root_domain_name
      Environment = var.environment
    }
  }
}

provider "aws" {
  alias  = "backup-website-region"
  region = "us-east-1"
  default_tags {
    tags = {
      Project     = "portfolio-website"
      Website     = var.root_domain_name
      Environment = var.environment
    }
  }
}
