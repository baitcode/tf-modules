resource "kubernetes_namespace" "name" {
  metadata {
    name = var.namespace

    labels = {
      "app.kubernetes.io/name" = var.namespace
      "name"                   = var.namespace
    }

    annotations = {
      "fluentbit.io/exclude" = "true"
    }

  }
}
