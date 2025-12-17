output "ALB_DNSname" {
  value = aws_lb.myALB.dns_name
}

output "ALB_URL" {
  value = "http://${aws_lb.myALB.dns_name}"
}
