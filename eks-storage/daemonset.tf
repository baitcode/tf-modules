resource "kubernetes_daemonset" "ebs_csi_node" {
  metadata {
    name      = "ebs-csi-node"
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/name" : "aws-ebs-csi-driver"
    }
  }
  spec {
    selector {
      match_labels = {
        "app.kubernetes.io/name" : "aws-ebs-csi-driver"
        "app" : "ebs-csi-node"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" : "aws-ebs-csi-driver"
          "app" : "ebs-csi-node"
        }
        annotations = {
          "fluentbit.io/exclude" = "true"
        }
      }

      spec {
        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "eks.amazonaws.com/compute-type"
                  operator = "NotIn"
                  values   = ["fargate"]
                }
              }
            }
          }
        }
        container {
          name              = "ebs-plugin"
          image             = "public.ecr.aws/ebs-csi-driver/aws-ebs-csi-driver:v1.17.0"
          image_pull_policy = "IfNotPresent"
          args              = ["node", "--endpoint=$(CSI_ENDPOINT)", "--logging-format=text", "--v=2"]

          env {
            name  = "CSI_ENDPOINT"
            value = "unix:/csi/csi.sock"
          }

          env {
            name = "CSI_NODE_NAME"
            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }

          liveness_probe {
            http_get {
              path = "/healthz"
              port = "healthz"
            }
            initial_delay_seconds = 10
            period_seconds        = 10
            timeout_seconds       = 3
            failure_threshold     = 5
          }

          port {
            name           = "healthz"
            container_port = 9808
            protocol       = "TCP"
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
            privileged                = true
            read_only_root_filesystem = true
          }
          volume_mount {
            mount_path        = "/var/lib/kubelet"
            mount_propagation = "Bidirectional"
            name              = "kubelet-dir"
          }
          volume_mount {
            mount_path = "/csi"
            name       = "plugin-dir"
          }
          volume_mount {
            mount_path = "/dev"
            name       = "device-dir"
          }
        }
        container {
          name = "node-driver-registrar"
          args = [
            "--csi-address=$(ADDRESS)",
            "--kubelet-registration-path=$(DRIVER_REG_SOCK_PATH)",
            "--v=2"
          ]
          env {
            name  = "ADDRESS"
            value = "/csi/csi.sock"
          }
          env {
            name  = "DRIVER_REG_SOCK_PATH"
            value = "/var/lib/kubelet/plugins/ebs.csi.aws.com/csi.sock"
          }

          image             = "public.ecr.aws/eks-distro/kubernetes-csi/node-driver-registrar:v2.7.0-eks-1-26-latest"
          image_pull_policy = "IfNotPresent"
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
            read_only_root_filesystem  = true
            allow_privilege_escalation = false
          }
          volume_mount {
            mount_path = "/csi"
            name       = "plugin-dir"
          }
          volume_mount {
            mount_path = "/registration"
            name       = "registration-dir"
          }
          # TODO: research uncomment
          #   "Failed to create registration probe file" err="mkdir /var/lib/kubelet: read-only file system" registrationProbePath="/var/lib/kubelet/plugins/ebs.csi.aws.com/registration"
          # volume_mount {
          #   mount_path        = "/var/lib/kubelet"
          #   mount_propagation = "Bidirectional"
          #   name              = "kubelet-dir"
          # }
        }
        container {
          args = [
            "--csi-address=/csi/csi.sock",
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
            read_only_root_filesystem  = true
            allow_privilege_escalation = false
          }
          volume_mount {
            mount_path = "/csi"
            name       = "plugin-dir"
          }
        }

        node_selector = {
          "kubernetes.io/os" = "linux"
        }
        priority_class_name = "system-node-critical"

        security_context {
          fs_group        = 0
          run_as_group    = 0
          run_as_user     = 0
          run_as_non_root = false
        }

        service_account_name = var.driver_service_account_name

        toleration {
          operator = "Exists"
        }

        volume {
          host_path {
            path = "/var/lib/kubelet"
            type = "Directory"
          }
          name = "kubelet-dir"
        }
        volume {
          host_path {
            path = "/var/lib/kubelet/plugins/ebs.csi.aws.com/"
            type = "DirectoryOrCreate"
          }
          name = "plugin-dir"
        }
        volume {
          host_path {
            path = "/var/lib/kubelet/plugins_registry/"
            type = "Directory"
          }
          name = "registration-dir"
        }
        volume {
          host_path {
            path = "/dev"
            type = "Directory"
          }

          name = "device-dir"
        }

      }
    }
    strategy {
      rolling_update {
        max_unavailable = "10%"
      }
      type = "RollingUpdate"
    }
  }

  depends_on = [
    kubernetes_service_account.eks_ebs_driver_account,
  ]
}

