#Creating VPC
module "vpc_network" {
  source   = "../modules/vpc"
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

#Creating EKS Cluster
module "eks_cluster" {
  source             = "../modules/eks"
  cluster_name       = "eks-with-terraform"
  kubernetes_version = "1.32"
  subnet_ids         = module.vpc_network.all_subnet_ids
  coredns-version    = "v1.11.4-eksbuild.2"
  kube-proxy-version = "v1.32.0-eksbuild.2"
  vpc-cni-version    = "v1.19.2-eksbuild.5"
  node_subnet_ids    = module.vpc_network.private_subnets
  vpc_id             = module.vpc_network.vpc_id
}