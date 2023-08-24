resource "kubernetes_manifest" "aws-ebs-csi-driver" {

  manifest = {
    apiVersion = "storage.k8s.io/v1"
    kind       = "CSIDriver"
    metadata = {
      labels = {
        "app.kubernetes.io/name" : "aws-ebs-csi-driver"
      }
      name = "ebs.csi.aws.com"
    }

    spec = {
      attachRequired = true
      fsGroupPolicy  = "File"
      podInfoOnMount = false
    }
  }
}
