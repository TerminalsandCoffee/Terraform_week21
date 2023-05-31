variable "region" {
  description = "The region to deploy the resources"
  default = "us-west-1"
}

variable "image_id" {
  description = "The image id for the launch configuration"
  default = "ami-0bef6cc322bfff646" # You might want to replace this with a more recent AMI
}

variable "instance_type" {
  description = "The instance type for the launch configuration"
  default = "t2.micro"
}

variable "desired_capacity" {
  description = "The desired capacity for the Auto Scaling group"
  default = 2
}

variable "max_size" {
  description = "The maximum size of the Auto Scaling group"
  default = 5
}

variable "min_size" {
  description = "The minimum size of the Auto Scaling group"
  default = 2
}

variable "bucket_name" {
  description = "The name of the S3 bucket"
  default = "my-terraform-backend-bucket-luit"
}
