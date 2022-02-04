resource "aws_s3_bucket" "website" {
  bucket = "${var.root_domain_name}"
  acl = "private"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  lifecycle_rule {
    id      = "delete versions"
    enabled = true
    abort_incomplete_multipart_upload_days = 0
    noncurrent_version_expiration {
      days = 2
    }

  }

    replication_configuration {
    role = aws_iam_role.replication.arn

    rules {
      id     = "backup-website"
      status = "Enabled"
    destination {
        bucket  = aws_s3_bucket.backup-website.arn
      }
    }
  }
  
  versioning {
    enabled = true
  }

    tags = {
    Name        = "website-bucket"
  }
}

resource "aws_s3_bucket_policy" "website-bucket-policy" {
  bucket = aws_s3_bucket.website.bucket
  policy = file("s3_policy.json") 
}   

provider "aws" {
  alias = "virginia-s3"
  region = "us-east-1"
}

resource "aws_s3_bucket" "backup-website" {
  bucket = "backup-${var.root_domain_name}"
  acl = "private"
  provider    = aws.virginia-s3

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  lifecycle_rule {
    id      = "delete versions"
    enabled = true
    abort_incomplete_multipart_upload_days = 0
    noncurrent_version_expiration {
      days = 2
    }

  }

  versioning {
    enabled = true
  }

    tags = {
    Name        = "backup-website-bucket"
  }
}

resource "aws_s3_bucket_policy" "backup-website-bucket-policy" {
  bucket = aws_s3_bucket.backup-website.bucket
  provider = aws.virginia-s3
  policy = file("backup_s3_policy.json") 
}  


resource "aws_iam_role" "replication" {
  name = "s3crr_role_for_cullancarey.com"
  path = "/service-role/"

  assume_role_policy = file("s3_assume_role_policy.json") 
  }


resource "aws_iam_policy" "s3_replication_exec_policy" {
    name = "s3crr_for_cullancarey.com_3e75e7"
    path = "/service-role/"
    policy = file("s3_exec_policy.json")
  }