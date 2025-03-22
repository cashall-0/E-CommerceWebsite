# Variables
variable "region" {
  description = "AWS region to deploy resources"
  default     = "eu-west-2"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  default     = "my-eks-cluster"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "ecr_image_uri" {
  description = "URI of the image in ECR"
  type        = string
  default = "" #add URI of Image in ECR
}

variable "kubernetes_version" {
  description = "Kubernetes version to use for the EKS cluster"
  default     = "1.29"
}