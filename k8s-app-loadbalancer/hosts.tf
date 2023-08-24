resource "aws_route53_record" "www" {
  count = length(var.hosts)

  zone_id = var.route53_zone_id
  name    = var.hosts[count.index]
  type    = "CNAME"
  ttl     = "300"

  records = [
    kubernetes_service.service.status.0.load_balancer.0.ingress.0.hostname
  ]
}
