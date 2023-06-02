provider "aws" {
  region = var.region
}


# Security Group
resource "aws_security_group" "terraform_sg" {
  name        = "allow_http"
  description = "Allow inbound HTTP, HTTPS, and SSH traffic"
  vpc_id      = aws_vpc.my_vpc.id # ensure this is the same VPC 

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

# EC2 Configuration
resource "aws_launch_configuration" "Apache_Bootstrap" {
  image_id                    = var.image_id # Amazon Linux 2 AMI 
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.terraform_sg.id]
  associate_public_ip_address = true

  # Apache Installation User Data Script
  user_data = <<-EOF
    #!/bin/bash
    sudo su
    sudo yum update

    # apache install, enable, and status check
    sudo yum -y install httpd
    sudo systemctl start httpd
    sudo systemctl enable httpd
    sudo systemctl status httpd
    sudo systemctl restart httpd
    EOF

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "terraform_autoscaling_group" {
  vpc_zone_identifier  = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
  launch_configuration = aws_launch_configuration.Apache_Bootstrap.id
  min_size             = 2
  max_size             = 5
  desired_capacity     = 2

  tag {
    key                 = "Name"
    value               = "terraform_autoscaling_group"
    propagate_at_launch = true
  }
}

# Default VPC and Subnets
resource "aws_vpc" "my_vpc" {
  cidr_block = var.cidr_block
}

resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24" # Unique CIDR block for subnet1
}

resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.2.0/24" # Unique CIDR block for subnet2
}

# Internet Gateway
resource "aws_internet_gateway" "terraform_asg_gateway" {
  vpc_id = aws_vpc.my_vpc.id
}

# Route Table
resource "aws_route_table" "terraform_asg_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform_asg_gateway.id
  }
}

# Subnet Association
resource "aws_route_table_association" "terraform_asg_subnet_association" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.terraform_asg_rt.id
}

resource "aws_route_table_association" "terraform_asg_subnet_association_2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.terraform_asg_rt.id
}