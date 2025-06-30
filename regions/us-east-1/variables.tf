variable "public" {
  description = "Map of public subnet availability zones"
  type        = map(string)
}

variable "private" {
  description = "Map of private subnet availability zones"
  type        = map(string)
}

variable "eks_version" {
  description = "Kubernetes cluster version"
  type        = string
}

variable "coredns_v" {
  description = "CoreDNS Version"
  type        = string
}

variable "vpc_cni_v" {
  description = "CNI Version"
  type        = string
}

variable "kube_proxy_v" {
  description = "Kube-Proxy Version"
  type        = string
}
