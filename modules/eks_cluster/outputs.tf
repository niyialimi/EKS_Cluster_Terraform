output "cluster_name" {
  description = "EKS Cluster Name"
  value       = aws_eks_cluster.eks_cluster.name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.eks_cluster.endpoint
}

output "eks_cluster_sg" {
  description = "ID of the cluster after creation"
  value       = aws_security_group.eks_cluster.id
}