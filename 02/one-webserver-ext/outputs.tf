# [출력 변수]
output "public_ip" {
  description = "My EC2 Public Ip"
  value       = aws_instance.myinstance.public_ip
}

output "public_dns" {
  description = "My EC2 Public DNS name"
  value       = aws_instance.myinstance.public_dns
}

