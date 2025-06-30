resource "aws_iam_role" "cluster" {
  name = var.cluster_iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        },
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_eks_cluster" "eks-terraform" {
  name     = var.cluster_name
  version  = var.kubernetes_version
  role_arn = aws_iam_role.cluster.arn
  access_config {
    authentication_mode = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

#Adding Nodes

#IAM Role EKS Worker Node
resource "aws_iam_role" "node-role" {
  name = "eks-node-iam-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node-role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node-role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node-role.name
}
resource "aws_eks_node_group" "eks-ng-1" {
  cluster_name    = aws_eks_cluster.eks-terraform.name
  node_group_name = "eks-ng-1"
  node_role_arn   = aws_iam_role.node-role.arn
  subnet_ids      = var.node_subnet_ids
  instance_types  = ["t3a.xlarge"]

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_eks_cluster.eks-terraform
  ]
}

#Adding Add-Ons
resource "aws_eks_addon" "core-dns" {
  depends_on = [ aws_eks_node_group.eks-ng-1 ]
  cluster_name                = aws_eks_cluster.eks-terraform.name
  addon_name                  = "coredns"
  addon_version               = var.coredns-version
  resolve_conflicts_on_update = "PRESERVE"
}
resource "aws_eks_addon" "kube-proxy" {
  depends_on = [ aws_eks_node_group.eks-ng-1 ]
  cluster_name                = aws_eks_cluster.eks-terraform.name
  addon_name                  = "kube-proxy"
  addon_version               = var.kube-proxy-version
  resolve_conflicts_on_update = "PRESERVE"
}
resource "aws_eks_addon" "vpc-cni" {
  depends_on = [ aws_eks_node_group.eks-ng-1 ]
  cluster_name                = aws_eks_cluster.eks-terraform.name
  addon_name                  = "vpc-cni"
  addon_version               = var.vpc-cni-version
  resolve_conflicts_on_update = "PRESERVE"
}
# Grabbing EKS Cluster Name
data "aws_eks_cluster" "default" {
  name = aws_eks_cluster.eks-terraform.name
}

data "tls_certificate" "default" {
  url = data.aws_eks_cluster.default.identity[0].oidc[0].issuer
}
#Creating OIDC Provider
resource "aws_iam_openid_connect_provider" "default" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.default.certificates[0].sha1_fingerprint]
  url             = data.aws_eks_cluster.default.identity[0].oidc[0].issuer
}