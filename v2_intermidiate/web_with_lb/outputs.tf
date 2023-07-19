output "aws_alb_public_dns" {
  value = aws_lb.anjlab_web_alb.dns_name
}