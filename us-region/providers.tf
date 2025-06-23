terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.93.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.7.1"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# provider "kubernetes" {
#   config_path    = "~/.kube/config"
#   config_context = module.eks_cluster.eks_cluster_arn
# }

# provider "helm" {
#   kubernetes {
#     config_path    = "~/.kube/config"
#     config_context = module.eks_cluster.eks_cluster_arn
#   }
# }

provider "kubernetes" {
  host                   = module.eks_cluster.eks_cluster_ep
  cluster_ca_certificate = base64decode(module.eks_cluster.eks_cluster_ca)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks_cluster.eks_cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks_cluster.eks_cluster_ep
    cluster_ca_certificate = base64decode(module.eks_cluster.eks_cluster_ca)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks_cluster.eks_cluster_name]
    }
    config_context = module.eks_cluster.eks_cluster_arn
  }
}