variable "cluster_name" {
  description = "Name of the EKS Cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for EKS"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for EKS worker nodes"
  type        = list(string)
}

variable "cluster_iam_role_name" {
  description = "Name of the IAM role used by EKS"
  type        = string
  default     = "eks-cluster-role"
}

variable "coredns_v" {
  type = string
}

variable "kube_proxy_v" {
  type = string
}

variable "vpc_cni_v" {
  type = string
}

variable "node_subnet_ids" {
  description = "List of subnet IDs for EKS worker nodes"
  type        = list(string)
}

variable "vpc_id" {
  type = string
}

variable "karpenter_version" {

  type = string
  default = "1.5.1"
  
}

variable "aws_region" {
  type = string
  default = "us-east-1"
}