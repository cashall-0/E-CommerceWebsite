terraform {
  required_version = ">= 1.3.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.83"
    }
  }
}
terraform {
  backend "s3" {
    bucket         = "terraform-cba-s3-bucket2"
    key            = "eks-cluster/terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
  }
}