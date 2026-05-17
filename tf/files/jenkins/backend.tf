terraform {
  backend "s3" {
    bucket         = "three-tier-app-saurabh"
    region         = "ap-south-1"
    key            = "jenkins-tfstate/terraform.tfstate"
    dynamodb_table = "your-lock-table"
    encrypt        = true
  }
  required_version = ">=0.13.0"
  required_providers {
    aws = {
      version = ">= 2.7.0"
      source  = "hashicorp/aws"
    }
  }
}
