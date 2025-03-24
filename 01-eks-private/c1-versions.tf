# Terraform Settings Block
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      #version = ">= 4.65"
      version = "~> 5.91"
    }
  }
  backend "s3" {
    bucket = "terraform-eks-private"
    key    = "dev/eks-cluster/terraform.tfstate"
    region = "ap-northeast-2"

    # For State Locking
    dynamodb_table = "terraform-lock-dev-eks-private"    
  }
}

# Terraform Provider Block
provider "aws" {
  region = var.aws_region
}
