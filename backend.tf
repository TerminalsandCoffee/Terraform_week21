terraform {
  backend "s3" {
    bucket = "my-terraform-backend-bucket-luit" 
    key    = "terraform.tfstate"
    region = "us-east-1" 
  }
}
