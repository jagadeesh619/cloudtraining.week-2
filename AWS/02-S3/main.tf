resource "aws_s3_bucket" "week-2" {
  bucket = var.name

  tags = {
    Name        = var.name
    terraform = true
  }
}
resource "aws_s3_bucket_ownership_controls" "week-2" {
  bucket = aws_s3_bucket.week-2.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "week-2" {
  bucket = aws_s3_bucket.week-2.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "week-2" {
  bucket = aws_s3_bucket.week-2.id
  acl    = "public-read"
  depends_on = [ aws_s3_bucket_ownership_controls.week-2 , aws_s3_bucket_public_access_block.week-2 ]
}

resource "aws_s3_bucket_versioning" "versioning_week-2" {
  bucket = aws_s3_bucket.week-2.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "public_bucket_policy" {
  bucket = aws_s3_bucket.week-2.bucket

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.week-2.arn}/*"
      }
    ]
  })
}
