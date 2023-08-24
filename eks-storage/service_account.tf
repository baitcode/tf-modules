resource "kubernetes_service_account" "eks_ebs_controller_service_account" {
  metadata {
    name      = var.controller_service_account_name
    namespace = var.namespace

    annotations = {
      "eks.amazonaws.com/role-arn" : aws_iam_role.controller_service_account_role.arn
    }
  }
}

resource "kubernetes_service_account" "eks_ebs_driver_account" {
  metadata {
    name      = var.driver_service_account_name
    namespace = var.namespace

    annotations = {
      "eks.amazonaws.com/role-arn" : aws_iam_role.driver_service_account_role.arn
    }
  }
}



