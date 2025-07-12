# Grabbing EKS Cluster Name

# Fetching EKS cluster and OIDC issuer

data "aws_eks_cluster" "karpenter" {
  name = aws_eks_cluster.eks-terraform.name
}

data "tls_certificate" "karpenter_oidc" {
  url = data.aws_eks_cluster.karpenter.identity[0].oidc[0].issuer
}

# Creating Interruption Queue for EKS
resource "aws_sqs_queue" "karpenter_interruption_queue" {
  name                        = "${var.cluster_name}"
  sqs_managed_sse_enabled     = true

  tags = {
    "karpenter.sh/discovery" = var.cluster_name
  }
}

# Spot Service Linked Role
# resource "aws_iam_service_linked_role" "spot" {
#   aws_service_name = "spot.amazonaws.com"
#   depends_on       = [aws_iam_openid_connect_provider.default]
# }

# Karpenter Controller IAM Role

resource "aws_iam_role" "karpenter-controller-irsa-role" {
  name = "karpenter-controller-irsa-role"
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
            "${aws_iam_openid_connect_provider.default.url}:sub" = "system:serviceaccount:kube-system:karpenter"
            "${aws_iam_openid_connect_provider.default.url}:aud" = "sts.amazonaws.com"
          }
      }
    }]
  })
}

resource "aws_iam_policy" "karpenter_controller_policy" {
  name        = "KarpenterControllerIAMPolicyEKSTerraform"
  description = "Policy for Karpenter Controller"
  policy = file("${path.module}/karpenter_controller_policy.json") # Sav your policy JSON here
}

#Attach Policy to Role
resource "aws_iam_role_policy_attachment" "attach_karpenter_controller" {
  role       = aws_iam_role.karpenter-controller-irsa-role.name
  policy_arn = aws_iam_policy.karpenter_controller_policy.arn
}

resource "kubernetes_service_account" "karpenter_controller_sa" {
  metadata {
    name      = "karpenter"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.karpenter-controller-irsa-role.arn
    }
  }
}
# Karpenter Node IAM Role and Instance Profile
resource "aws_iam_role" "karpenter_node" {
  name = "KarpenterNodeRole-${var.cluster_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

locals {
  node_policies = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  ]
}

resource "aws_iam_role_policy_attachment" "node_policy" {
  for_each   = toset(local.node_policies)
  role       = aws_iam_role.karpenter_node.name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "karpenter_node_instance_profile" {
  name = "KarpenterNodeInstanceProfile-${var.cluster_name}"
  role = aws_iam_role.karpenter_node.name
}

# Helm chart deployment of Karpenter (OCI Chart)
resource "helm_release" "karpenter" {
  name             = "karpenter"
  repository       = "oci://public.ecr.aws/karpenter"
  chart            = "karpenter"
  version          = var.karpenter_version
  namespace        = "kube-system"

  set {
    name  = "settings.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "settings.interruptionQueue"
    value = var.cluster_name
  }
 set {
  name  = "controller.env[0].name"
  value = "AWS_REGION"
}

 set {
  name  = "controller.env[0].value"
  value = var.aws_region
}
  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "karpenter"
  }
}
#   set {
#     name  = "cluster.endpoint"
#     value = data.aws_eks_cluster.karpenter.endpoint
#   }

#   set {
#     name  = "aws.defaultInstanceProfile"
#     value = aws_iam_instance_profile.karpenter_node_instance_profile.name
#   }

#   set {
#     name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = aws_iam_role.karpenter_controller.arn
#   }


# Read Cluster SG
data "aws_eks_cluster" "cluster-sg" {
  name = var.cluster_name
  depends_on = [ aws_eks_cluster.eks-terraform ]
}

#Karpenter SG
resource "aws_security_group" "karpenter_sg" {
  name        = "karpenter-sg"
  description = "Security group for Karpenter-managed nodes"
  vpc_id      = var.vpc_id

  # Allow all traffic within the VPC
  ingress {
    description      = "Allow internal VPC traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    security_groups = [ data.aws_eks_cluster.cluster-sg.vpc_config[0].cluster_security_group_id]
  }

  # Allow outbound to the internet (e.g., for pulling images, AWS APIs)
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                        = "karpenter-sg"
    "karpenter.sh/discovery"   = aws_eks_cluster.eks-terraform.name
  }
}

# Need to add access entry for Karpenter Node IAM Role