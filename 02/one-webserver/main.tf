# 단일 웹 서버 배포
#
# provider
#
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.25.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

#
# resource
#
resource "aws_instance" "myinstance" {
  ami                    = "ami-0f5fcdfbd140e4ab7"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.allow_8080.id]

  # user_data_replace_on_change : user_data값이 변경될 경우 꼭 붙여야 한다
  # <<-EOF일 경우 tap 들여쓰기를 해서 작성
  user_data_replace_on_change = true
  user_data                   = <<-EOF
        #!/bin/bash
        echo "Hello World" > index.html
        nohup busybox httpd -f -p 8080
        EOF
  tags = {
    Name = "My First Instnace"
  }
}

# 보안 그룹(security group) 설정
# 보안 그룹 생성
resource "aws_security_group" "allow_8080" {
  name        = "allow_8080"
  description = "Allow TLS inbound traffic and all outbound traffic"
  tags = {
    Name = "allow_8080"
  }
}

# ingress 설정
resource "aws_vpc_security_group_ingress_rule" "allow_8080_http" {
  security_group_id = aws_security_group.allow_8080.id # aws_security_group의 allow_8080이름을 가진 보안 그룹의 id
  cidr_ipv4         = "0.0.0.0/0"                      # 클라이언트
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}

# egress 설정
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_8080.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # -1번은 ALL을 의미한다
}