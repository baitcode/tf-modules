terraform {  
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "4.32.0"
        }
        helm = {
            source = "hashicorp/helm"
            version = "2.7.0"
        }
        kubernetes = {
            source  = "hashicorp/kubernetes"
            version = ">= 2.13.1"
        }
    }
}
