#Creating VPC
module "vpc_network" {
  source   = "../modules/vpc"
  vpc_cidr = "10.0.0.0/16"
}
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
  source = "../modules/eks"
  cluster_name = "eks-with-terraform"
  kubernetes_version = "1.32"
  subnet_ids =  module.vpc_network.all_subnet_ids
}