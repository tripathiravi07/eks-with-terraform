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