##################################################################
# Kubernetes Authentication
##################################################################

variable "kube_host" {
}

variable "kube_crt" {
  default = ""
}

variable "kube_key" {
  default = ""
}

provider "kubernetes" {
  experiments {
    manifest_resource = true
  }

  host               = var.kube_host
  client_certificate = base64decode(var.kube_crt)
  client_key         = base64decode(var.kube_key)
  insecure           = true
}
