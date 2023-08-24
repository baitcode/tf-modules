output "cluster_oidc_issuer_url" {
  value = local.cluster_oidc_issuer_url
}

output "cluster_oidc_arn" {
  value = aws_iam_openid_connect_provider.cluster_oidc.arn
}

output "cluster_node_role_name" {
  value = aws_iam_role.cluster_node_role.name
}

output "kubernetes_host" {
  value = aws_eks_cluster.cluster.endpoint
}

output "kubernetes_cluster_ca_certificate" {
  value = base64decode(aws_eks_cluster.cluster.certificate_authority[0].data)
}

output "kubernetes_token" {
  value = data.aws_eks_cluster_auth.k8s_auth.token
}
