terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.27.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "my_vpc" {
  source = "../modules/vpc" # 모듈 소스 위치 지정 
}

module "my_ec2" {
  source = "../modules/ec2"

  subnet_id = module.my_vpc.subnet_id
}


