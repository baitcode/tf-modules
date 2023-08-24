variable "cluster_name" {
  type = string
}

variable "namespace" {
  type = string
}

variable "app_name" {
  type = string
}

variable "app_replicas" {
  type    = number
  default = 1
}

variable "additional_policy_statements" {
  type = list(object({
    Effect   = string
    Action   = list(string)
    Resource = string
  }))
  default = null
}

variable "env" {
  type    = map(string)
  default = {}
}

variable "container_image" {
  type = string
}

variable "container_command" {
  type    = list(string)
  default = null
}

variable "enable_logs" {
  type    = bool
  default = false
}

variable "tags" {
  type = map(string)
}

variable "volumes" {
  type = list(object({
    name   = string
    config = string
  }))
  default = []
}

variable "volume_mounts" {
  type = list(object({
    name       = string
    mount_path = string
    sub_path   = string
  }))
  default = []
}

variable "resources" {
  type = map(map(string))
  default = {
    requests = {
      memory = "64Mi"
      cpu    = "100m"
    }
    limits = {
      memory = "128Mi"
      cpu    = "500m"
    }
  }
}