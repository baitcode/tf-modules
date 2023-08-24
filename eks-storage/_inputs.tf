variable "namespace" {
  type = string
}

variable "controller_service_account_name" {
  type    = string
  default = "ebs-csi-controller-sa"
}

variable "driver_service_account_name" {
  type    = string
  default = "aws-ebs-csi-driver"
}

variable "account_id" {
  type = string
}

variable "oidc_provider" {
  type = string
}
