variable "cluster_name" {
  type        = string
  description = "The name of the cluster."
}

variable "account_id" {
  type        = string
  description = "AWS account id."
}

variable "oidc_provider" {
  type = string
}

# have defaults

variable "settings" {
  default     = {}
  description = "Additional settings which will be passed to the Helm chart values."
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Variable indicating whether deployment is enabled."
}

variable "helm_chart_name" {
  type        = string
  default     = "aws-for-fluent-bit"
  description = "Install Fluent Bit to send logs from containers to CloudWatch Logs"
}

variable "helm_chart_release_name" {
  type        = string
  default     = "aws-for-fluent-bit"
  description = "Fluent Bit Helm release name."
}

variable "helm_chart_repo" {
  type        = string
  default     = "https://aws.github.io/eks-charts"
  description = "Fluent Bit Helm repository name."
}

variable "helm_chart_version" {
  type        = string
  default     = "0.1.27"
  description = "Fluent Bit Helm chart version."
}

variable "create_namespace" {
  type        = bool
  default     = true
  description = "Whether to create Kubernetes namespace with name defined by `namespace`."
}

variable "namespace" {
  type        = string
  default     = "aws-cloudwatch-logs"
  description = "Kubernetes namespace to deploy Fluent Bit Helm chart."
}

variable "service_account_name" {
  type        = string
  default     = "aws-for-fluent-bit"
  description = "Fluent Bit service account name."
}

variable "mod_dependency" {
  default     = null
  description = "Dependence variable binds all AWS resources allocated by this module, dependent modules reference this variable."
}

