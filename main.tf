terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.8.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  #Using credentials file
  shared_credentials_file = "credentials"
  profile = "default"
  }

