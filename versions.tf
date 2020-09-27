terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "1.13.2"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "2.11.0"
    }
  }
}