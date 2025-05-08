# S3 Bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = "EC2-Access-Bucket"
    Environment = "Dev"
  }

  force_destroy = true
}

# IAM Role for EC2 to Access S3
resource "aws_iam_role" "ec2_s3_role" {
  name = "EC2-S3-Access-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# IAM Policy for S3 Access
resource "aws_iam_role_policy" "s3_access_policy" {
  name = "AllowS3Access"
  role = aws_iam_role.ec2_s3_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = [
        "s3:GetObject",
        "s3:ListBucket",
        "s3:PutObject"
      ],
      Effect   = "Allow",
      Resource = [
        aws_s3_bucket.my_bucket.arn,
        "${aws_s3_bucket.my_bucket.arn}/*"
      ]
    }]
  })
}

# Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "EC2-S3-Instance-Profile"
  role = aws_iam_role.ec2_s3_role.name
}

