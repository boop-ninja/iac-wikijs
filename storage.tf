resource "kubernetes_persistent_volume_claim" "meilisearch_module" {
  metadata {
    name      = "meilisearch-module"
    namespace = var.namespace
  }

  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = "longhorn"
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}