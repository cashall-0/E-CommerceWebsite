output "eks_cluster_name" {
  description = "The endpoint for your EKS Kubernetes API server"
  value = data.aws_eks_cluster.eks_name.name
}


output "eks_cluster_endpoint" {
  description = "The endpoint for your EKS Kubernetes API server"
  value = data.aws_eks_cluster.eks_name.endpoint
}