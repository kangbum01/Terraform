terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.26.0"
    }
  }
}

# aws configure list 출력 결과로 확인한다.
# profile은 ~/.aws/credentials 를 통해 확인한다.
provider "aws" {
  region  = "us-east-2"
  profile = "default"
}

