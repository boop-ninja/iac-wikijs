locals {
  pvc_name = kubernetes_persistent_volume_claim.i.metadata.0.name
  common_labels = {
    app = var.namespace
  }
}