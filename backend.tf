# Using a single workspace:
terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "boop-ninja"

    workspaces {
      name = "infra-kube-wikijs"
    }
  }
}