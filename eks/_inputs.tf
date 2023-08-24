variable "cluster_size" {
  type    = number
  default = 2
}
variable "instance_type" {
  type    = string
  default = "t3.medium"
}
variable "aws_profile" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "cluster_name" {
  type = string

  validation {
    condition     = can(regex("^[a-zA-Z][\\w]+$", var.cluster_name))
    error_message = "Only alphanumeric values and underscores are allowed starting with letter."
  }
}

variable "tags" {
  type = map(string)
}

variable "subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "new_node_group" {
  type     = string
  default = ""
}

variable "old_node_group" {
  type     = string
  default = ""
}

variable "cluster_version" {
  type    = string
} 