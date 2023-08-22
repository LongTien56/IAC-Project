output "eks_cluster_autoscaler_arn" {
  value = aws_iam_role.eks_cluster_autoscaler.arn
}


output "eks_cluster_endpoint" {
  value = aws_eks_cluster.staging.endpoint
}


output "eks_ca_certificate" {
  value = aws_eks_cluster.staging.certificate_authority[0].data
}

output "eks_cluster_name" {
  value = aws_eks_cluster.staging.name
}

output "eks_iam_oidc_provider" {
  value = aws_iam_openid_connect_provider.eks.arn
}

output "eks_cluster_id" {
  value = aws_eks_cluster.staging.id
}