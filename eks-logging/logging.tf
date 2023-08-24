
resource "helm_release" "cloudwatch_logs" {
  depends_on = [var.mod_dependency, kubernetes_namespace.cloudwatch_logs, aws_iam_role.cloudwatch_logs]
  count      = var.enabled ? 1 : 0
  name       = var.helm_chart_name
  chart      = var.helm_chart_release_name
  repository = var.helm_chart_repo
  version    = var.helm_chart_version
  namespace  = var.namespace

  # Whole chart needs to be recreated on any config change

  values = [
    yamlencode({
      "clusterName": var.cluster_name,

      "service": {
        "extraParsers": file("${path.module}/assets/parsers.conf")
      }

      "serviceAccount": {
        "name": var.service_account_name
        "annotations": {
          "eks.amazonaws.com/role-arn": aws_iam_role.cloudwatch_logs[0].arn
        }
      }

      "input": {
        "enabled": false
        # "parser": "myparser"
      }

      "annotations": {
        "clusterName": var.cluster_name
        "fluentbit.io/exclude": "true"
      }

      "additionalInputs": file("${path.module}/assets/inputs.conf")
      "additionalFilters": file("${path.module}/assets/filters.conf")

      "cloudWatch": {
        "enabled": false
        "region": data.aws_region.current.name
        "logGroupName": "/aws/eks/${var.cluster_name}/$kubernetes['labels']['application']"
      }

      "cloudWatchLogs": {
        "enabled": true
        "region": data.aws_region.current.name
        "logGroupName": "/aws/eks/${var.cluster_name}/unknownApplicationLogs"
        "logGroupTemplate": "/aws/eks/${var.cluster_name}/$kubernetes['labels']['application']"
        "logStreamTemplate": "$kubernetes['container_name'].$kubernetes['pod_name']"
      }
    })
  ]
}