terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.93.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = module.eks_cluster.eks_cluster_arn
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = module.eks_cluster.eks_cluster_arn
  }
}