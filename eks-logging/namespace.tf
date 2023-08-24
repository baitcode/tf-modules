resource "kubernetes_namespace" "cloudwatch_logs" {
  depends_on = [var.mod_dependency]
  count      = (var.enabled && var.create_namespace && var.namespace != "kube-system") ? 1 : 0

  metadata {
    name = var.namespace

    annotations = {
      "fluentbit.io/exclude" = "true"
    }
  }
}
