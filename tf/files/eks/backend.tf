terraform {
  required_version = ">=0.13.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.49.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30.0"
    }
  }
  backend "s3" {
    bucket         = "three-tier-app-saurabh"
    region         = "ap-south-1"
    key            = "eks-tfstate/terraform.tfstate"
    dynamodb_table = "your-lock-table"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws-region
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority)
  token                  = data.aws_eks_cluster_auth.eks.token
}
