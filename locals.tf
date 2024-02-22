locals {
  pvc_name = kubernetes_persistent_volume_claim.i.metadata.0.name
  common_labels = {
    target = var.namespace
  }
}
