terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    castai = {
      source  = "castai/castai"
      version = ">= 0.26.3"
    }
  }
  required_version = ">= 0.13"
}