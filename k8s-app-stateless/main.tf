terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.32.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.13.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.3.2"
    }
  }
}

data "aws_eks_cluster" "current" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "k8s_auth" {
  name = var.cluster_name
}
