terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "cloud.training.devops"
    key            = "cloud/training/week-2/aws/s3"
    region         = "us-east-1"
    dynamodb_table = "Terraform-state-lock"

  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}