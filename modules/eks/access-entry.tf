resource "aws_eks_access_entry" "eks-terraform" {
  cluster_name      = aws_eks_cluster.eks-terraform.name
  principal_arn     = aws_iam_role.example.arn
  kubernetes_groups = ["group-1", "group-2"]
  type              = "STANDARD"
}