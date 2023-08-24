variable "cluster_name" {
  type = string
}

variable "namespace" {
  type = string
}

variable "app_name" {
  type = string
}

variable "app_port" {
  type = string
}

variable "route53_zone_id" {
  type = string
}

variable "hosts" {
  type = list(string)
}

variable "service_annotations" {
  type = map(string)
}

variable "service_ports" {
  type = map(object({
    port     = number
    protocol = string
  }))
}
