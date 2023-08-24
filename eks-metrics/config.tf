resource "kubernetes_config_map" "cloudwatch_agent_config" {
  metadata {
    name      = "cwagentconfig"
    namespace = var.namespace
  }

  data = {
    "cwagentconfig.json" = templatefile("${path.module}/templates/config.json", {
      cluster_name = var.cluster_name
      region       = var.cloudwatch_region
    })
  }
}
