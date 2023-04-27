terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.20.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.4.0"
    }
  }
}