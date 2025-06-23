output "eks_cluster_arn" {
    value = aws_eks_cluster.eks-terraform.arn
}

# Outputs
output "karpenter_iam_role" {
  value = aws_iam_role.karpenter-controller-irsa-role.arn
}

output "karpenter_node_instance_profile_name" {
  value = aws_iam_instance_profile.karpenter_node_instance_profile.name
}