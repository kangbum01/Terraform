#################################################
# 0. Infra
# 1. ALB 생성
# * SG 생성 - For ALB
# * TG 생성
# * ALB 생성
#   +- Listener & rule 생성
# 2. ASG 생성 - Auto Scaling Group
# * SG 생성 - For ASG
# * launch template 생성
# * ASG 생성
#################################################

# 0. Infra
# VPC 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc

data "aws_vpc" "default" {
  default = true
}

# 서브넷 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# 1. ALB 생성
# 생성 순서 SG -> TG -> ALB

#   SG 생성 -> ingress: 80/tcp, egress: all
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "myalb_sg" {
  name        = "myalb_sg"
  description = "Allow TLS inbound 80 traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "myalb_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_myalb_80" {
  security_group_id = aws_security_group.myalb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = var.web_port
  to_port           = var.web_port
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_myalb_all" {
  security_group_id = aws_security_group.myalb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# * TG 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
resource "aws_lb_target_group" "myalb_tg" {
  name     = "myalb-tg"
  port     = var.web_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
}

# * ALB 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
resource "aws_lb" "myalb" {
  name               = "myalb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.myalb_sg.id]
  subnets            = data.aws_subnets.default.ids

  tags = {
    Name = "myalb"
  }
}

#   +- Listener & rule 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener 
resource "aws_lb_listener" "myalb_listener" {
  load_balancer_arn = aws_lb.myalb.arn # arn은 리소스 고유 식별자
  port              = "${var.web_port}"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.myalb_tg.arn
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule
# Forward action - 신호가 들어오면 전달한다.
resource "aws_lb_listener_rule" "myalb_listener_rule" {
  listener_arn = aws_lb_listener.myalb_listener.arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.myalb_tg.arn
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }
}


# 2. ASG 생성
# * SG 생성 - For ASG
# * launch template 생성
# * ASG 생성




#   SG 생성 for ASG -> ingress: 80/tcp, egress: all
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "myasg_sg" {
  name        = "myasg_sg"
  description = "Allow TLS inbound 80 traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "myasg_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_myasg_80" {
  security_group_id = aws_security_group.myasg_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = var.web_port
  to_port           = var.web_port
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_myasg_all" {
  security_group_id = aws_security_group.myasg_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


# * ami id 찾기
# * launch template 생성


# ami id 찾기 - aws EC2 -> AMI 카탈로그에서 ID 확인 -> AMI
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
data "aws_ami" "amazonlinux2023" {
  most_recent = true
  owners = [var.aws]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.9.*.0-kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# * launch template 생성
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template
resource "aws_launch_template" "mylt" {
  name = "mylt"

  image_id               = data.aws_ami.amazonlinux2023.id
  instance_type          = var.vCPU2_MEM1g
  vpc_security_group_ids = [aws_security_group.myasg_sg.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "mylt"
    }
  }

  user_data = filebase64("./user_data.sh") # 현재 폴더에 user_data.sh 파일을 불러온다
}


# * ASG 생성 -> TG 연결
# * target_group_arns
# * depends_on
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group
resource "aws_autoscaling_group" "myasg" {
  # 우린 VPC랑 Subnet으로 만들었기에 vpc_zone 옵션 사용
  vpc_zone_identifier = data.aws_subnets.default.ids
  desired_capacity    = var.intEC2num
  max_size            = var.maxEC2num
  min_size            = var.minEC2num

  # lb에 설정한 tg와 ASG를 연결한다.
  target_group_arns = [aws_lb_target_group.myalb_tg.arn]
  depends_on        = [aws_lb_target_group.myalb_tg]

  launch_template {
    id      = aws_launch_template.mylt.id
    version = "$Default"
  }
}





