# IRSA for ALB LBC
resource "aws_iam_role" "aws-lbc-irsa-role" {
  name = "aws-lbc-irsa-role"
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
            "${aws_iam_openid_connect_provider.default.url}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
            "${aws_iam_openid_connect_provider.default.url}:aud" = "sts.amazonaws.com"
          }
      }
    }]
  })
}

#LBC Policy
resource "aws_iam_policy" "aws_lb_controller" {
  name        = "AWSLoadBalancerControllerIAMPolicyEKSTerraform"
  description = "Policy for AWS Load Balancer Controller"
  policy = file("${path.module}/aws_lb_controller_policy.json") # Save your policy JSON here
}
#Attach Policy to Role
resource "aws_iam_role_policy_attachment" "attach_lb_controller" {
  role       = aws_iam_role.aws-lbc-irsa-role.name
  policy_arn = aws_iam_policy.aws_lb_controller.arn
}

resource "kubernetes_service_account" "aws_lb_controller_sa" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.aws-lbc-irsa-role.arn
    }
  }
}
#Installing Helm Chart
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = aws_eks_cluster.eks-terraform.name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name = "region"
    value = "us-east-1"
  }

  set {
    name = "vpcId"
    value = var.vpc_id
  }

  depends_on = [
     kubernetes_service_account.aws_lb_controller_sa
   ]
}