# main.tf

# Define provider and region
provider "aws" {
  region = "us-east-1" # Update with your desired region
}

# Create a default VPC
resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}

# Create a subnet within the default VPC
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.default.id
  cidr_block = "10.0.1.0/24"
}

# Create a security group for Jenkins
resource "aws_security_group" "jenkins" {
  name        = "jenkins-security-group"
  description = "Security group for Jenkins"

  vpc_id = aws_vpc.default.id

  # Allow SSH from your IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Update with your IP
  }

  # Allow traffic on port 8080
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an EC2 instance
resource "aws_instance" "jenkins_instance" {
  ami                         = "ami-0c7217cdde317cfec" # Ubuntu AMI, change as needed
  instance_type               = "t2.micro"
  key_name                    = "terraformpracticekey" # Use the existing key pair name here
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true

  user_data = <<-EOF
#!/bin/bash

sudo apt-get update -y
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y fontconfig openjdk-17-jre
sudo apt-get install -y jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

              EOF
}

resource "aws_s3_bucket" "jenkins-s3-bucket1234512345" { #MAKE SURE BUCKET NAME IS UNIQUE
  bucket = "jenkins-s3-bucket1234512345"

  tags = {
    Name = "Jenkins"
  }
}

resource "aws_s3_bucket_acl" "s3_bucket_acl" {
  bucket     = aws_s3_bucket.jenkins-s3-bucket1234512345.id
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

# Avoids error "AccessControlListNotSupported"
resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.jenkins-s3-bucket1234512345.id
  rule {
    object_ownership = "ObjectWriter"
  }
}