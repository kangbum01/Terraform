# tf state list
# tf state show ~ 
output "myEC2IP" {
  description = "My EC2 Public IP"
  value = aws_instance.myEC2.public_ip
}

output "myEC2URL" {
  description = "My EC2 URL"
  value = "ssh -i ~/.ssh/mykeypair ubuntu@${aws_instance.myEC2.public_dns}"
}