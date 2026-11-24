terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_key_pair" "k8s_key" {
  key_name   = "k8s-key"
  public_key = file("~/.ssh/id_rsa.pub")
}
