resource "kubernetes_daemonset" "cloudwatch" {
  metadata {
    name      = "cloudwatch-agent"
    namespace = var.namespace
  }

  spec {
    selector {
      match_labels = {
        "name" = "cloudwatch-agent"
      }
    }

    template {

      metadata {
        labels = {
          "name" = "cloudwatch-agent"
        }
      }

      spec {
        service_account_name             = var.service_account_name
        termination_grace_period_seconds = 60

        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        container {
          image = "public.ecr.aws/cloudwatch-agent/cloudwatch-agent:1.247358.0b252413"
          name  = "cloudwatch-agent"

          port {
            container_port = 8125
            protocol       = "UDP"
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          env {
            name = "HOST_IP"
            value_from {
              field_ref { field_path = "status.hostIP" }
            }
          }

          env {
            name = "HOST_NAME"
            value_from {
              field_ref { field_path = "spec.nodeName" }
            }
          }

          env {
            name = "K8S_NAMESPACE"
            value_from {
              field_ref { field_path = "metadata.namespace" }
            }
          }

          env {
            name  = "CI_VERSION"
            value = "k8s/1.3.13"
          }

          volume_mount {
            name       = "cwagentconfig"
            mount_path = "/etc/cwagentconfig"
          }

          volume_mount {
            name       = "rootfs"
            mount_path = "/rootfs"
            read_only  = true
          }

          volume_mount {
            name       = "dockersock"
            mount_path = "/var/run/docker.sock"
            read_only  = true
          }

          volume_mount {
            name       = "varlibdocker"
            mount_path = "/var/lib/docker"
            read_only  = true
          }

          volume_mount {
            name       = "containerdsock"
            mount_path = "/run/containerd/containerd.sock"
            read_only  = true
          }

          volume_mount {
            name       = "sys"
            mount_path = "/sys"
            read_only  = true
          }

          volume_mount {
            name       = "devdisk"
            mount_path = "/dev/disk"
            read_only  = true
          }
        }

        volume {
          name = "cwagentconfig"
          config_map {
            name = "cwagentconfig"
          }
        }

        volume {
          name = "rootfs"
          host_path {
            path = "/"
          }
        }

        volume {
          name = "dockersock"
          host_path {
            path = "/var/run/docker.sock"
          }
        }

        volume {
          name = "varlibdocker"
          host_path {
            path = "/var/lib/docker"
          }
        }

        volume {
          name = "containerdsock"
          host_path {
            path = "/run/containerd/containerd.sock"
          }
        }

        volume {
          name = "sys"
          host_path {
            path = "/sys"
          }
        }

        volume {
          name = "devdisk"
          host_path {
            path = "/dev/disk/"
          }
        }

      }
    }
  }
}
