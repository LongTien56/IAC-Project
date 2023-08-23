provider "helm" {
  kubernetes {
    host                   = module.eks.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.eks_ca_certificate)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.eks_cluster_name]
      command     = "aws"
    }
  }
}

resource "helm_release" "nginx_ingress" {
    name      = "nginx-ingress"
    repository = "oci://ghcr.io/nginxinc/charts/"
    chart     = "nginx-ingress"
    namespace = "kube-system"

    values = [file("nginx-controller-value.yaml")]
}


#load balancer controller
module "aws_load_balancer_controller_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.3.1"

  role_name = "aws-load-balancer-controller"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.eks_iam_oidc_provider
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}


resource "helm_release" "aws_load_balancer_controller" {
  name = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.6.0"

  set {
    name  = "replicaCount"
    value = 1
  }

  set {
    name  = "clusterName"
    value = module.eks.eks_cluster_id
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.aws_load_balancer_controller_irsa_role.iam_role_arn
  }
}

#allow add tag
resource "aws_iam_policy" "elb_add_tags_policy" {
  name        = "ELBAddTagsPolicy"
  description = "Policy to allow adding tags to ELB resources"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "elasticloadbalancing:AddTags",
        Effect   = "Allow",
        Resource = "*",
        Sid      = "patch"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "elb_add_tags_attachment" {
  policy_arn = aws_iam_policy.elb_add_tags_policy.arn
  role       = module.aws_load_balancer_controller_irsa_role.iam_role_name
}


#fluxCD
resource "helm_release" "flux2" {
    name      = "flux2"
    repository = "https://fluxcd-community.github.io/helm-charts"
    chart     = "flux2"
    namespace = "kube-system"
}
