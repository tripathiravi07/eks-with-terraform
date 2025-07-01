##Creating VPC for EKS Cluster
module "vpc_network" {
  source   = "../../modules/vpc"
  vpc_cidr = "10.0.0.0/16"
  public   = var.public
  private  = var.private
}

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

#Creating the EKS Cluster 
module "eks_cluster" {
  source             = "../../modules/eks"
  cluster_name       = "eks-with-terraform"
  kubernetes_version = var.eks_version
  subnet_ids         = module.vpc_network.all_subnet_ids
  coredns-version    = var.coredns_v
  kube-proxy-version = var.kube_proxy_v
  vpc-cni-version    = var.vpc_cni_v
  node_subnet_ids    = module.vpc_network.private_subnets
  vpc_id             = module.vpc_network.vpc_id
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