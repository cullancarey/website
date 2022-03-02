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
  policy = <<POLICY
{
    "Version": "2008-10-17",
    "Id": "PolicyForCloudFrontPrivateContent",
    "Statement": [
        {
            "Sid": "AllowPublicAccess",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "${aws_s3_bucket.website.arn}/*"
        },
        {
            "Sid": "DenyAccessWithoutCustomHeader",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "${aws_s3_bucket.website.arn}/*",
            "Condition": {
                "StringNotLike": {
                    "aws:${var.custom_header}": "${random_string.header_value.result}"
                }
            }
        }
    ]
}

POLICY
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
  policy = <<POLICY
{
    "Version": "2008-10-17",
    "Id": "PolicyForCloudFrontPrivateContent",
    "Statement": [
        {
            "Sid": "AllowPublicAccess",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "${aws_s3_bucket.backup-website.arn}/*"
        },
        {
            "Sid": "DenyAccessWithoutCustomHeader",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "${aws_s3_bucket.backup-website.arn}/*",
            "Condition": {
                "StringNotLike": {
                    "aws:${var.custom_header}": "${random_string.header_value.result}"
                }
            }
        }
    ]
}

POLICY 
}  


resource "aws_iam_role" "replication" {
  name = "s3crr_role_for_${var.root_domain_name}"
  path = "/service-role/"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}

POLICY 
  }


resource "aws_iam_policy" "s3_replication_exec_policy" {
    name = "s3crr_for_${var.root_domain_name}_3e75e7"
    path = "/service-role/"
    policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:ListBucket",
                "s3:GetReplicationConfiguration",
                "s3:GetObjectVersionForReplication",
                "s3:GetObjectVersionAcl",
                "s3:GetObjectVersionTagging",
                "s3:GetObjectRetention",
                "s3:GetObjectLegalHold"
            ],
            "Effect": "Allow",
            "Resource": [
                "${aws_s3_bucket.website.arn}",
                "${aws_s3_bucket.website.arn}/*",
                "${aws_s3_bucket.backup-website.arn}",
                "${aws_s3_bucket.backup-website.arn}/*"
            ]
        },
        {
            "Action": [
                "s3:ReplicateObject",
                "s3:ReplicateDelete",
                "s3:ReplicateTags",
                "s3:ObjectOwnerOverrideToBucketOwner"
            ],
            "Effect": "Allow",
            "Resource": [
                "${aws_s3_bucket.website.arn}/*",
                "${aws_s3_bucket.backup-website.arn}/*"
            ]
        }
    ]
}

POLICY
  }