locals {
  prefix    = "wikijs"
  pvc_name  = kubernetes_persistent_volume_claim.i.metadata.0.name
  namespace = kubernetes_namespace.i.metadata.0.name
  common_labels = {
    app = local.prefix
  }
}