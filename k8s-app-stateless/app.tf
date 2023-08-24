resource "kubernetes_service_account" "app" {
  metadata {
    name      = var.app_name
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" : aws_iam_role.app-role.arn
    }
  }
  automount_service_account_token = false
}

resource "kubernetes_deployment" "app" {
  metadata {
    name      = var.app_name
    namespace = var.namespace
    labels = merge(var.tags, {
      application = var.app_name
    })
    annotations = {
      "fluentbit.io/exclude" = !var.enable_logs
    }
  }

  spec {
    replicas = var.app_replicas

    selector {
      match_labels = {
        application = var.app_name
      }
    }

    template {
      metadata {
        labels = {
          application = var.app_name
        }

        annotations = {
          "fluentbit.io/exclude" = !var.enable_logs
        }
      }


      spec {
        service_account_name            = var.app_name
        automount_service_account_token = false


        dynamic "volume" {
          for_each = var.volumes

          content {
            name = volume.value.name
            config_map {
              name = volume.value.config
            }
          }
        }

        container {
          image_pull_policy = "Always"

          resources {
            requests = var.resources["requests"]
            limits = var.resources["limits"]
          }

          name  = "application"
          image = var.container_image
          
          command = var.container_command

          dynamic "env" {
            for_each = var.env

            content {
              name  = env.key
              value = env.value
            }
          }
          
          dynamic "volume_mount" {
            for_each = var.volume_mounts

            content {
              name       = volume_mount.value.name
              sub_path   = volume_mount.value.sub_path
              mount_path = volume_mount.value.mount_path
            }
          }

        }
      }
    }
  }
}
