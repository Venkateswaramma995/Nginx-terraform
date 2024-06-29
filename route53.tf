resource "aws_route53_zone" "primary" {
  name = "example.com"
}

resource "aws_route53_record" "nginx" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "nginx.example.com"
  type    = "A"
  ttl     = "300"
  records = [aws_nat_gateway.nat.public_ip]
}
