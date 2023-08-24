data "aws_acm_certificate" "issued" {
  count  = length(var.hosts) > 0 ? 1 : 0
  domain = "*.${var.cluster_name}.zamna.com"
  statuses = [
    "ISSUED"
  ]
}

resource "kubernetes_service" "service" {

  metadata {
    name      = var.app_name
    namespace = var.namespace
    annotations = merge({
      "service.beta.kubernetes.io/aws-load-balancer-type" : "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-backend-protocol" : "http"
      "service.beta.kubernetes.io/aws-load-balancer-ssl-cert" : data.aws_acm_certificate.issued[0].arn
      "service.beta.kubernetes.io/aws-load-balancer-ssl-ports" : "443"
      "service.beta.kubernetes.io/aws-load-balancer-ssl-negotiation-policy" : "ELBSecurityPolicy-TLS13-1-2-2021-06"
      "service.beta.kubernetes.io/aws-load-balancer-alpn-policy" : "HTTP2Optional"
    }, var.service_annotations)
  }

  spec {
    selector = {
      application = var.app_name
    }

    dynamic "port" {
      for_each = var.service_ports

      content {
        name        = port.key
        port        = port.value.port
        target_port = var.app_port
        protocol    = port.value.protocol
      }
    }

    type = "LoadBalancer"
  }

}
