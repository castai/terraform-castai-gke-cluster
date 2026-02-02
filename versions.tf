terraform {
  required_version = ">= 0.13"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 2.49"
    }
    castai = {
      source  = "castai/castai"
      version = ">= 8.13"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 3.0.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}

