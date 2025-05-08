variable "region" {
  default = "us-east-1"
}

variable "ami_id" {
  default = "ami-0f88e80871fd81e91"
}

variable "bucket_name" {
  description = "S3 bucket to allow access from EC2"
}



