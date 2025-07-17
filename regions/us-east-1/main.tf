##Creating VPC for EKS Cluster.
module "vpc_network" {
  source   = "../../modules/vpc"
  vpc_cidr = "10.0.0.0/16"
  public   = var.public
  private  = var.private
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