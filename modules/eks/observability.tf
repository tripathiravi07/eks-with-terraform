resource "aws_iam_role" "observability_irsa" {
  name = "observability_irsa-irsa-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid    = ""
      Effect = "Allow",
      Principal = {
        Federated = aws_iam_openid_connect_provider.default.arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
            "${aws_iam_openid_connect_provider.default.url}:sub" = "system:serviceaccount:amazon-cloudwatch:cloudwatch-agent"
            "${aws_iam_openid_connect_provider.default.url}:aud" = "sts.amazonaws.com"
          }
      }
    }]
  })
}

# Attach the AWS managed CloudWatch Observability policy
resource "aws_iam_role_policy_attachment" "observability_attach" {
  role       = aws_iam_role.observability_irsa.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Install the EKS Addon
resource "aws_eks_addon" "observability_addon" {
  cluster_name      = aws_eks_cluster.eks-terraform.name
  addon_name        = "amazon-cloudwatch-observability"
  service_account_role_arn = aws_iam_role.observability_irsa.arn
  resolve_conflicts = "OVERWRITE"

  depends_on = [
    aws_eks_addon.core-dns,
    aws_eks_addon.kube-proxy,
    aws_eks_addon.vpc-cni
  ]
}