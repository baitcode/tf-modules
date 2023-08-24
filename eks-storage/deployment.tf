resource "kubernetes_manifest" "pod_disruption_budget__ebs_csi_controller" {
  manifest = {
    apiVersion: "policy/v1"
    kind: "PodDisruptionBudget"
    metadata = {
      labels = {
        "app.kubernetes.io/name" : "aws-ebs-csi-driver"
      }
      name      = "ebs-csi-controller"
      namespace = var.namespace
    }
    
    spec = {
      maxUnavailable = 1
      selector = {
        matchLabels = {
          "app" : "ebs-csi-controller"
          "app.kubernetes.io/name" : "aws-ebs-csi-driver"
        }
      }
    }
  }
}


resource "kubernetes_deployment" "ebs_csi_controller" {
  metadata {
    labels = {
      "app.kubernetes.io/name" : "aws-ebs-csi-driver"
    }
    name      = "ebs-csi-controller"
    namespace = var.namespace
  }
  spec {
    replicas = 2

    selector {
      match_labels = {
        "app" : "ebs-csi-controller"
        "app.kubernetes.io/name" : "aws-ebs-csi-driver"
      }
    }

    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_unavailable = 1
      }
    }

    template {
      metadata {
        labels = {
          "app" : "ebs-csi-controller"
          "app.kubernetes.io/name" : "aws-ebs-csi-driver"
        }
      }

      spec {
        affinity {
          node_affinity {
            preferred_during_scheduling_ignored_during_execution {
              preference {
                match_expressions {
                  key      = "eks.amazonaws.com/compute-type"
                  operator = "NotIn"
                  values   = ["fargate"]
                }
              }
              weight = 1
            }
          }
          pod_anti_affinity {
            preferred_during_scheduling_ignored_during_execution {
              pod_affinity_term {
                label_selector {
                  match_expressions {
                    key      = "app"
                    operator = "In"
                    values   = ["ebs-csi-controller"]
                  }
                }
                topology_key = "kubernetes.io/hostname"
              }
              weight = 100
            }
          }
        }

        container {
          args = [
            "--endpoint=$(CSI_ENDPOINT)",
            "--logging-format=text",
            "--v=2"
          ]

          env {
            name  = "CSI_ENDPOINT"
            value = "unix:///var/lib/csi/sockets/pluginproxy/csi.sock"
          }

          env {
            name = "CSI_NODE_NAME"
            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }

          env {
            name = "AWS_EC2_ENDPOINT"
            value_from {
              config_map_key_ref {
                key      = "endpoint"
                name     = "aws-meta"
                optional = true
              }
            }
          }

          image             = "public.ecr.aws/ebs-csi-driver/aws-ebs-csi-driver:v1.17.0"
          image_pull_policy = "IfNotPresent"
          liveness_probe {
            failure_threshold = 5
            http_get {
              path = "/healthz"
              port = "healthz"
            }
            initial_delay_seconds = 10
            period_seconds        = 10
            timeout_seconds       = 3
          }

          name = "ebs-plugin"

          port {
            container_port = 9808
            name           = "healthz"
            protocol       = "TCP"
          }

          readiness_probe {
            failure_threshold = 5
            http_get {
              path = "/healthz"
              port = "healthz"
            }
            initial_delay_seconds = 10
            period_seconds        = 10
            timeout_seconds       = 3
          }

          resources {
            limits = {
              cpu    = "100m"
              memory = "256Mi"
            }
            requests = {
              cpu    = "10m"
              memory = "40Mi"
            }
          }

          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
          }

          volume_mount {
            mount_path = "/var/lib/csi/sockets/pluginproxy/"
            name       = "socket-dir"
          }
        }

        container {
          args = [
            "--csi-address=$(ADDRESS)",
            "--v=2",
            "--feature-gates=Topology=true",
            "--extra-create-metadata",
            "--leader-election=true",
            "--default-fstype=ext4"
          ]

          env {
            name  = "ADDRESS"
            value = "/var/lib/csi/sockets/pluginproxy/csi.sock"
          }

          image             = "public.ecr.aws/eks-distro/kubernetes-csi/external-provisioner:v3.4.0-eks-1-26-latest"
          image_pull_policy = "IfNotPresent"
          name              = "csi-provisioner"
          resources {
            limits = {
              cpu    = "100m"
              memory = "256Mi"
            }
            requests = {
              cpu    = "10m"
              memory = "40Mi"
            }
          }
          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
          }

          volume_mount {
            mount_path = "/var/lib/csi/sockets/pluginproxy/"
            name       = "socket-dir"
          }
        }

        container {
          args = [
            "--csi-address=$(ADDRESS)",
            "--v=2",
            "--leader-election=true"
          ]
          env {
            name  = "ADDRESS"
            value = "/var/lib/csi/sockets/pluginproxy/csi.sock"
          }

          image             = "public.ecr.aws/eks-distro/kubernetes-csi/external-attacher:v4.2.0-eks-1-26-latest"
          image_pull_policy = "IfNotPresent"
          name              = "csi-attacher"
          resources {
            limits = {
              cpu    = "100m"
              memory = "256Mi"
            }
            requests = {
              cpu    = "10m"
              memory = "40Mi"
            }
          }
          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
          }
          volume_mount {
            mount_path = "/var/lib/csi/sockets/pluginproxy/"
            name       = "socket-dir"
          }
        }
        container {
          args = [
            "--csi-address=$(ADDRESS)",
            "--leader-election=true"
          ]

          env {
            name  = "ADDRESS"
            value = "/var/lib/csi/sockets/pluginproxy/csi.sock"
          }

          image             = "public.ecr.aws/eks-distro/kubernetes-csi/external-snapshotter/csi-snapshotter:v6.2.1-eks-1-26-latest"
          image_pull_policy = "IfNotPresent"
          name              = "csi-snapshotter"
          resources {
            limits = {
              cpu    = "100m"
              memory = "256Mi"
            }
            requests = {
              cpu    = "10m"
              memory = "40Mi"
            }
          }
          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
          }
          volume_mount {
            mount_path = "/var/lib/csi/sockets/pluginproxy/"
            name       = "socket-dir"
          }
        }
        container {
          args = [
            "--csi-address=$(ADDRESS)",
            "--v=2",
            "--handle-volume-inuse-error=false",
          ]
          env {
            name  = "ADDRESS"
            value = "/var/lib/csi/sockets/pluginproxy/csi.sock"
          }

          image             = "public.ecr.aws/eks-distro/kubernetes-csi/external-resizer:v1.7.0-eks-1-26-latest"
          image_pull_policy = "IfNotPresent"
          name              = "csi-resizer"
          resources {
            limits = {
              cpu    = "100m"
              memory = "256Mi"
            }
            requests = {
              cpu    = "10m"
              memory = "40Mi"
            }
          }
          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
          }
          volume_mount {
            mount_path = "/var/lib/csi/sockets/pluginproxy/"
            name       = "socket-dir"
          }
        }
        container {
          args = [
            "--csi-address=/csi/csi.sock"
          ]

          image             = "public.ecr.aws/eks-distro/kubernetes-csi/livenessprobe:v2.9.0-eks-1-26-latest"
          image_pull_policy = "IfNotPresent"
          name              = "liveness-probe"
          resources {
            limits = {
              cpu    = "100m"
              memory = "256Mi"
            }
            requests = {
              cpu    = "10m"
              memory = "40Mi"
            }
          }
          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
          }
          volume_mount {
            mount_path = "/csi"
            name       = "socket-dir"
          }
        }

        node_selector = {
          "kubernetes.io/os" = "linux"
        }
        priority_class_name = "system-cluster-critical"
        security_context {
          fs_group        = 1000
          run_as_group    = 1000
          run_as_non_root = true
          run_as_user     = 1000
        }
        service_account_name = var.controller_service_account_name
        toleration {
          key      = "CriticalAddonsOnly"
          operator = "Exists"
        }
        toleration {
          effect             = "NoExecute"
          operator           = "Exists"
          toleration_seconds = 300
        }
        volume {
          empty_dir {}
          name = "socket-dir"
        }

      }
    }
  }
}
