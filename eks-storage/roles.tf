resource "kubernetes_cluster_role" "ebs_csi_node_role" {
  metadata {
    labels = {
      "app.kubernetes.io/name" : "aws-ebs-csi-driver"
    }
    name = "ebs-csi-node-role"
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["get"]
  }
}
resource "kubernetes_cluster_role_binding" "ebs_csi_node_getter_binding" {
  metadata {
    labels = {
      "app.kubernetes.io/name" : "aws-ebs-csi-driver"
    }
    name = "ebs-csi-node-getter-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "ebs-csi-node-role"
  }

  subject {
    kind      = "ServiceAccount"
    namespace = var.namespace
    name      = "ebs-csi-node-sa"
  }

  depends_on = [
    kubernetes_cluster_role.ebs_csi_node_role,
    kubernetes_service_account.eks_ebs_driver_account
  ]
}


resource "kubernetes_cluster_role" "ebs_external_attacher_role" {
  metadata {
    labels = {
      "app.kubernetes.io/name" : "aws-ebs-csi-driver"
    }
    name = "ebs-external-attacher-role"
  }

  rule {
    api_groups = [""]
    resources  = ["persistentvolumes"]
    verbs = [
      "get", "list", "watch", "update", "patch",
    ]
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs = [
      "get", "list", "watch",
    ]
  }

  rule {
    api_groups = ["csi.storage.k8s.io"]
    resources  = ["csinodeinfos"]
    verbs = [
      "get", "list", "watch",
    ]
  }

  rule {
    api_groups = ["storage.k8s.io"]
    resources  = ["volumeattachments"]
    verbs = [
      "get", "list", "watch", "update", "patch",
    ]
  }

  rule {
    api_groups = ["storage.k8s.io"]
    resources  = ["volumeattachments/status"]
    verbs = [
      "patch",
    ]
  }
}
resource "kubernetes_cluster_role_binding" "ebs_csi_attacher_binding" {
  metadata {
    labels = {
      "app.kubernetes.io/name" : "aws-ebs-csi-driver"
    }
    name = "ebs-csi-attacher-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "ebs-external-attacher-role"
  }

  subject {
    kind      = "ServiceAccount"
    namespace = var.namespace
    name      = var.controller_service_account_name
  }

  depends_on = [
    kubernetes_cluster_role.ebs_external_attacher_role,
    kubernetes_service_account.eks_ebs_controller_service_account
  ]
}

resource "kubernetes_cluster_role" "ebs_external_provisioner_role" {
  metadata {
    labels = {
      "app.kubernetes.io/name" : "aws-ebs-csi-driver"
    }
    name = "ebs-external-provisioner-role"
  }

  rule {
    api_groups = [""]
    resources  = ["persistentvolumes"]
    verbs      = ["get", "list", "watch", "create", "delete"]
  }

  rule {
    api_groups = [""]
    resources  = ["persistentvolumeclaims"]
    verbs      = ["get", "list", "watch", "update"]
  }

  rule {
    api_groups = ["storage.k8s.io"]
    resources  = ["storageclasses"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["list", "watch", "create", "update", "patch"]
  }

  rule {
    api_groups = ["snapshot.storage.k8s.io"]
    resources  = ["volumesnapshots"]
    verbs      = ["get", "list"]
  }

  rule {
    api_groups = ["snapshot.storage.k8s.io"]
    resources  = ["volumesnapshotcontents"]
    verbs      = ["get", "list"]
  }

  rule {
    api_groups = ["storage.k8s.io"]
    resources  = ["csinodes"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
    verbs      = ["get", "watch", "list", "delete", "update", "create"]
  }

  rule {
    api_groups = ["storage.k8s.io"]
    resources  = ["volumeattachments"]
    verbs      = ["get", "list", "watch"]
  }

}
resource "kubernetes_cluster_role_binding" "ebs_csi_provisioner_binding" {
  metadata {
    labels = {
      "app.kubernetes.io/name" : "aws-ebs-csi-driver"
    }
    name = "ebs-csi-provisioner-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "ebs-external-provisioner-role"
  }

  subject {
    kind      = "ServiceAccount"
    namespace = var.namespace
    name      = var.controller_service_account_name
  }

  depends_on = [
    kubernetes_cluster_role.ebs_external_provisioner_role,
    kubernetes_service_account.eks_ebs_controller_service_account
  ]
}

resource "kubernetes_cluster_role" "ebs_external_resizer_role" {
  metadata {
    labels = {
      "app.kubernetes.io/name" : "aws-ebs-csi-driver"
    }
    name = "ebs-external-resizer-role"
  }

  rule {
    api_groups = [""]
    resources  = ["persistentvolumes"]
    verbs      = ["get", "list", "watch", "update", "patch"]
  }

  rule {
    api_groups = [""]
    resources  = ["persistentvolumeclaims"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["persistentvolumeclaims/status"]
    verbs      = ["update", "patch"]
  }

  rule {
    api_groups = ["storage.k8s.io"]
    resources  = ["storageclasses"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["list", "watch", "create", "update", "patch"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list", "watch"]
  }

}
resource "kubernetes_cluster_role_binding" "ebs_external_resizer_binding" {
  metadata {
    labels = {
      "app.kubernetes.io/name" : "aws-ebs-csi-driver"
    }
    name = "ebs-external-resizer-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "ebs-external-resizer-role"
  }

  subject {
    kind      = "ServiceAccount"
    namespace = var.namespace
    name      = var.controller_service_account_name
  }

  depends_on = [
    kubernetes_cluster_role.ebs_external_resizer_role,
    kubernetes_service_account.eks_ebs_controller_service_account
  ]
}


resource "kubernetes_cluster_role" "ebs_external_snapshotter_role" {
  metadata {
    labels = {
      "app.kubernetes.io/name" : "aws-ebs-csi-driver"
    }
    name = "ebs-external-snapshotter-role"
  }

  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["list", "watch", "create", "update", "patch"]
  }

  rule {
    api_groups = ["snapshot.storage.k8s.io"]
    resources  = ["volumesnapshotclasses"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["snapshot.storage.k8s.io"]
    resources  = ["volumesnapshotclasses"]
    verbs      = ["create", "get", "list", "watch", "update", "patch", "delete"]
  }

  rule {
    api_groups = ["snapshot.storage.k8s.io"]
    resources  = ["volumesnapshotcontents/status"]
    verbs      = ["update"]
  }
}
resource "kubernetes_cluster_role_binding" "ebs_csi_snapshotter_binding" {
  metadata {
    labels = {
      "app.kubernetes.io/name" : "aws-ebs-csi-driver"
    }
    name = "ebs-csi-snapshotter-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "ebs-external-snapshotter-role"
  }

  subject {
    kind      = "ServiceAccount"
    namespace = var.namespace
    name      = var.controller_service_account_name
  }

  depends_on = [
    kubernetes_cluster_role.ebs_external_snapshotter_role,
    kubernetes_service_account.eks_ebs_controller_service_account
  ]
}

