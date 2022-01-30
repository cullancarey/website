resource "aws_s3_bucket" "website" {
  bucket = "${var.root_domain_name}"
  acl = "private"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
    tags = {
    Name        = "website-bucket"
  }
}

resource "aws_s3_bucket_policy" "website-bucket-policy" {
  bucket = aws_s3_bucket.website.bucket
  policy = file("s3_policy.json") 
}   