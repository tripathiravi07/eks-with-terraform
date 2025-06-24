output "eks_cluster_arn" {
    value = aws_eks_cluster.eks-terraform.arn
}

# Outputs
output "karpenter_iam_role" {
  value = aws_iam_role.karpenter-controller-irsa-role
}

output "karpenter_node_instance_profile_name" {
  value = aws_iam_instance_profile.karpenter_node_instance_profile.name
}

output "eks_cluster_ep" {
    value = aws_eks_cluster.eks-terraform.endpoint
}

output "eks_cluster_ca" {
    value = aws_eks_cluster.eks-terraform.certificate_authority[0].data
}

output "eks_cluster_name" {
    value = aws_eks_cluster.eks-terraform.name
}