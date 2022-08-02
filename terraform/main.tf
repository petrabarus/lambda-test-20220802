terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  //https://registry.terraform.io/providers/hashicorp/aws/latest/docs
  profile = var.aws_profile
}
