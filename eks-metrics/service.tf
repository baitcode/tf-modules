
resource "kubernetes_service" "service" {

  metadata {
    name      = "cloudwatch-agent"
    namespace = var.namespace
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-scheme"   = "internal"
      "service.beta.kubernetes.io/aws-load-balancer-internal" = "true"
      "service.beta.kubernetes.io/aws-load-balancer-type" : "nlb"
    }
  }

  spec {
    selector = {
      name = "cloudwatch-agent"
    }

    port {
      port        = "8125"
      target_port = "8125"
      protocol    = "UDP"
    }

    type = "ClusterIP"
  }

}


resource "kubernetes_service" "service-external" {

  metadata {
    name      = "cloudwatch-agent-lb"
    namespace = var.namespace
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-scheme"   = "internal"
      "service.beta.kubernetes.io/aws-load-balancer-internal" = "true"
      "service.beta.kubernetes.io/aws-load-balancer-type" : "nlb"
    }
  }

  spec {
    selector = {
      name = "cloudwatch-agent"
    }

    port {
      port        = "8125"
      target_port = "8125"
      protocol    = "UDP"
    }

    type = "LoadBalancer"
  }

}
