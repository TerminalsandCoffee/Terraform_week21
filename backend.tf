terraform {
  backend "s3" {
    bucket = "ThisismyWeek21Bucket"  # Replace with your desired S3 bucket name
    key    = "example.tfstate"  # Replace with your desired state file name
    region = "us-east-1"        # Replace with your desired region
  }
}
