terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.32.0"
    }
    tls = {
      source = "hashicorp/tls"
      version = "3.4.0"
    }
  }
}

data "aws_eks_cluster_auth" "k8s_auth" {
  name = var.cluster_name

  depends_on = [
    aws_eks_cluster.cluster
  ]
}

provider "aws" {
  region = var.aws_region
  profile = var.aws_profile
}

