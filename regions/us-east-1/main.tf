##Creating VPC for EKS Cluster/
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
  kubernetes_version = var.version
  subnet_ids         = module.vpc_network.all_subnet_ids
  coredns-version    = "v1.12.1-eksbuild.2"
  kube-proxy-version = "v1.33.0-eksbuild.2"
  vpc-cni-version    = "v1.19.6-eksbuild.1"
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