terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.26.0"
    }
  }

  backend "s3" {
    bucket = "kbs-1207"
    key    = "global/s3/terraform.tfstate" # Terraform state가 S3 버킷의 "global/s3/terraform.tfstate" key(객체 경로)에 저장된다."
    dynamodb_table = "my_tflocks" # Lock에 대한 string 정보 저장 DB table
    region = "us-east-2"
  }
}

provider "aws" {
  region = "us-east-2"
}