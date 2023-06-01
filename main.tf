provider "aws" {
  region = var.region
}

# Remote Backend Storage with S3 Bucket
terraform {
  backend "s3" {
    bucket = var.bucket_name
    key    = "terraform.tfstate"
    region = var.region
  }
}

# Launch Configuration
resource "aws_launch_configuration" "Apache_Bootstrap" {
  image_id      = "ami-0bef6cc322bfff646" # Amazon Linux 2 AMI 
  instance_type = "t2.micro"
  key_name      = var.key_name
  security_groups = [aws_security_group.sg.id]
  associate_public_ip_address = true

  # Apache Installation User Data Script
  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y httpd
    sudo systemctl start httpd
    sudo systemctl enable httpd
    echo "<h1>Hello from $(hostname -f)</h1>" > /var/www/html/index.html
    EOF

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "terraform_autoscaling_group" {
  vpc_zone_identifier  = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
  launch_configuration = aws_launch_configuration.example.id
  min_size             = 2
  max_size             = 5
  desired_capacity     = 2

  tag {
    key                 = "Name"
    value               = "terraform_autoscaling_group"
    propagate_at_launch = true
  }
}

# Security Group
resource "aws_security_group" "terraform_sg" {
  name        = "allow_http"
  description = "Allow inbound HTTP, HTTPS, and SSH traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
  


# Default VPC and Subnets
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

resource "aws_subnet" "subnet1" {
  vpc_id     = data.aws_vpc.default.id
  cidr_block = data.aws_subnet_ids.default.ids[0]
}

resource "aws_subnet" "subnet2" {
  vpc_id     = data.aws_vpc.default.id
  cidr_block = data.aws_subnet_ids.default.ids[1]
}
