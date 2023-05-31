variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Name for the S3 bucket"
}

variable "key_name" {
  description = "Name for the EC2 key pair"
}
