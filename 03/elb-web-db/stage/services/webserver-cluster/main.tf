#############################################
# 1. provider
# * terraform
# * provider
# * terraform_remote_state
# 2. ASG
# * SG
# * launch template
# * TG
# * ASG
# 3. ALB
# * ALB
# * ALB listener
# * ALB listener rule
############################################

########################################
# 1. provider
########################################
# * terraform
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.26.0"
    }
  }
}

# * provider
provider "aws" {
  region = "us-east-2"
}

# * terraform_remote_state
data "terraform_remote_state" "myremotestate" {
  backend = "s3"

  config = {
    bucket = "kbs-1217"
    key    = "global/s3/terraform.tfstate"
    region = "us-east-2"
    dynamodb_table = "mylocktable"
  }
}

########################################
# 2. ASG
########################################
# * default VPC
data "aws_vpc" "default" {
  default = true
}

# * default subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
# * SG
# * 80/tcp
resource "aws_security_group" "myLTSG" {
  name        = "myLTSG"
  description = "Allow TLS inbound 80/tcp traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "myLTSG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "myLTSG-in-80" {
  security_group_id = aws_security_group.myLTSG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "myLTSG-out-all" {
  security_group_id = aws_security_group.myLTSG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# * launch template - LT는 EC2와 비슷하기 때문에 SG가 필요하다
#   - aws_ami data source
data "aws_ami" "amazon2023" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.9.*.0-kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"]
}

resource "aws_launch_template" "myLT" {
  name = "myLT"
  image_id = data.aws_ami.amazon2023.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.myLTSG.id]
  user_data = base64encode(templatefile("./user_data.sh",
  {
    dbaddress = data.terraform_remote_state.myremotestate.outputs.dbaddress,
    dbport = data.terraform_remote_state.myremotestate.outputs.dbport,
    dbname = data.terraform_remote_state.myremotestate.outputs.dbname
  })
  )
}
# * TG
resource "aws_lb_target_group" "myALBTG" {
  name     = "myALBTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
}

# * ASG
# target_group_arns
# depends_on
resource "aws_autoscaling_group" "myASG" {
  name                      = "myASG"
  max_size                  = 2
  min_size                  = 2
  desired_capacity          = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  launch_template {
    id      = aws_launch_template.myLT.id
    version = "$Latest"
  }
  vpc_zone_identifier       = data.aws_subnets.default.ids
  target_group_arns = [aws_lb_target_group.myALBTG.arn]
  depends_on = [aws_lb_target_group.myALBTG]
  tag {
    key                 = "name"
    value               = "myASG"
    propagate_at_launch = false
  }
}

########################################
# 3. ALB
########################################
# SG - ALB을 위한 SG
# * 80/tcp

# * ALB
resource "aws_lb" "myALB" {
  name               = "myALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.myLTSG.id]
  subnets            = data.aws_subnets.default.ids
}

# * ALB listener
resource "aws_lb_listener" "myALB-listener" {
  load_balancer_arn = aws_lb.myALB.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.myALBTG.arn
  }
}

# * ALB listener rule
resource "aws_lb_listener_rule" "myALB-listener-rule" {
  listener_arn = aws_lb_listener.myALB-listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.myALBTG.arn
  }

  condition { # 값이 들어오면 action으로 보내라
    path_pattern {
      values = ["*"]
    }
  }
}


