# Data Source를 이용해보자
################################
# 1) provider
# 2) EC2
################################

# 1) provider
provider "aws" {
  region = "us-east-2"
}

# 2) EC2
# * AMI ID 자동 선택하도록 data source를 생성
#   - Amazon linux 2023 ami
data "aws_ami" "amazon2023" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.9.20251208.0-kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"] # Canonical
}

resource "aws_instance" "myInstance" {
  ami           = data.aws_ami.amazon2023.id
  instance_type = "t3.micro"

  tags = {
    Name = "myInstance"
  }
}

output "ami_id" {
  description = "AMI ID"
  value       = aws_instance.myInstance.id
}
