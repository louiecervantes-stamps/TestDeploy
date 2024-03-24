terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  cloud {
    organization = "louie-test"

    workspaces {
      name = "TestDeploy"
    }
  }
}


provider "aws" {
  region = "us-west-1"
}