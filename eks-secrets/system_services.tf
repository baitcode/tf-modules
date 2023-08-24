resource "helm_release" "secret_store_csi" {
  name = "secrets-store-csi-driver"

  repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  chart = "secrets-store-csi-driver"
  namespace = "kube-system"

  set {
    name  = "syncSecret.enabled"
    value = "true"
  }

  set {
    name  = "enableSecretRotation"
    value = "true"
  }

}

resource "kubernetes_manifest" "aws-secret-provider-service-account" {
  manifest = {
    apiVersion = "v1"
    kind = "ServiceAccount"
    metadata = {
      name = "csi-secrets-store-provider-aws"
      namespace = "kube-system"
    }
  }
}

resource "kubernetes_manifest" "aws-secret-provider-cluster-role" {
  manifest = {
    apiVersion = "rbac.authorization.k8s.io/v1"
    kind = "ClusterRole"
    metadata = {
      name = "csi-secrets-store-provider-aws-cluster-role"
    }
    rules = [
      {
        apiGroups = [""]
        resources = ["serviceaccounts/token"]
        verbs = ["create"]
      },
      {
        apiGroups = [""]
        resources = ["serviceaccounts"]
        verbs = ["get"]
      },
      {
        apiGroups = [""]
        resources = ["pods"]
        verbs = ["get"]
      },
      {
        apiGroups = [""]
        resources = ["nodes"]
        verbs = ["get"]
      }
    ]
  }
}

resource "kubernetes_manifest" "aws-secret-provider-rolebinding" {
  manifest = {
    apiVersion: "rbac.authorization.k8s.io/v1"
    kind: "ClusterRoleBinding"
    metadata = {
      name: "csi-secrets-store-provider-aws-cluster-rolebinding"
    }
    roleRef = {
      apiGroup: "rbac.authorization.k8s.io"
      kind: "ClusterRole"
      name: "csi-secrets-store-provider-aws-cluster-role"
    }
    subjects = [
      {
        kind: "ServiceAccount"
        name: "csi-secrets-store-provider-aws"
        namespace: "kube-system"
      }
    ]
  }
}

resource "kubernetes_manifest" "aws-secret-provider-daemonset" {
  manifest = {
    apiVersion: "apps/v1"
    kind: "DaemonSet"
    metadata: {
      namespace: "kube-system"
      name: "csi-secrets-store-provider-aws"
      labels: {
        app: "csi-secrets-store-provider-aws"
      }
    }
    spec: {
      updateStrategy: {
        type: "RollingUpdate"
      }
      selector: {
        matchLabels: {
          app: "csi-secrets-store-provider-aws"
        }
      }
      template: {
        metadata: {
          labels: {
            app: "csi-secrets-store-provider-aws"
          }
        }
        spec: {
          serviceAccountName: "csi-secrets-store-provider-aws"
          hostNetwork: true
          containers: [
            {
              name: "provider-aws-installer"
              image: "public.ecr.aws/aws-secrets-manager/secrets-store-csi-driver-provider-aws:1.0.r2-6-gee95299-2022.04.14.21.07"
              imagePullPolicy: "Always"
              args: [
                "--provider-volume=/etc/kubernetes/secrets-store-csi-providers"
              ]
              resources: {
                requests: {
                  cpu: "50m"
                  memory: "100Mi"
                }
                limits: {
                  cpu: "50m"
                  memory: "100Mi"
                }
              }
              volumeMounts: [
                {
                  name: "providervol"
                  mountPath: "/etc/kubernetes/secrets-store-csi-providers"
                },
                {
                  name: "mountpoint-dir"
                  mountPath: "/var/lib/kubelet/pods"
                  mountPropagation: "HostToContainer"
                }
              ]
            }
          ]
          volumes: [
            {
              name: "providervol"
              hostPath: {
                path: "/etc/kubernetes/secrets-store-csi-providers"
              }
            },
            {
              name: "mountpoint-dir"
              hostPath: {
                path: "/var/lib/kubelet/pods"
                type: "DirectoryOrCreate"
              }
            }
          ]
          nodeSelector: {
            "kubernetes.io/os": "linux"
          }
        }
      }
    }
  }
}




