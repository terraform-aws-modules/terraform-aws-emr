terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.83"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.17"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.7"
    }
  }
}
