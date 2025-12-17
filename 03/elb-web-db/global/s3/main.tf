################################
#
################################

# 1. provider
provider "aws" {
  region = "us-east-2"
}

# 2. bucket
resource "aws_s3_bucket" "mytfstate" {
  bucket = "kbs-1217"
  tags = {
    Name        = "My bucket"
  }
}

# 3. DynamoDB
# * S3 bucket ARN -> output
# * DynamoDB table name -> output
resource "aws_dynamodb_table" "mylocktable" {
  name           = "mylocktable"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "mylocktable"
  }
}
