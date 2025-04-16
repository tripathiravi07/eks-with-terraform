module "vpc_network" {
  source   = "../modules/vpc"
  vpc_cidr = "10.0.0.0/16"
}
output "vpc_module_id" {
  value = "VPC Id for EKS Cluster is: ${module.vpc_network.vpc_id}"
}