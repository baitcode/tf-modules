variable "aws_profile" {
  type    = string
}

variable "aws_region" {
  type    = string
}

variable "cluster_name" {
  type    = string

  validation {
    condition = can(regex("^[a-zA-Z][\\w]+$", var.cluster_name))
    error_message = "Only alphanumeric values and underscores are allowed starting with letter."
  }
}

variable "tags" {
  type    = map(string)
}

variable "vpc_name" {
  type    = string
}

variable "vpc_network_bits" {
  type    = number
  default = 16
}

variable "network_prefix" {
  type    = string
  default = "10.0.0.0"
}