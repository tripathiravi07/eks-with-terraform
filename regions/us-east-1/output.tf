#OutPut From VPC Module which is consumed by EKS Cluster Resources
output "vpc_module_id" {
  value = module.vpc_network.vpc_id
}

output "vpc_public_subnets" {
  value = module.vpc_network.public_subnets
}

output "vpc_private_subnets" {
  value = module.vpc_network.private_subnets
}

output "all_subnets" {
  value = module.vpc_network.all_subnet_ids
}

output "eks_arn" {
  value = module.eks_cluster.eks_cluster_arn
}

output "eks-cluster-ep" {
  value = module.eks_cluster.eks_cluster_ep
}

output "eks-cluster-ca" {
  value = module.eks_cluster.eks_cluster_ca
}

output "eks-cluster-name" {
  value = module.eks_cluster.eks_cluster_name
}