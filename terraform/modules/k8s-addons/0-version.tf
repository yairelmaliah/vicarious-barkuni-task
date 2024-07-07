terraform {
  required_version = ">= 1.9.0"
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = "2.14.0"
    }
  }
}
