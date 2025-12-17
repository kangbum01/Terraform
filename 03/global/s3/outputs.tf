# output "mybucket_arn" {
#   value = aws_s3_bucket.my_tfstate.arn
#   description = "My S3 Bucket ARN"
# }

output "my_dynamodb_table_name" {
  value = aws_dynamodb_table.my_tflocks.name
  description = "My Dynamodb Table Name"
}
