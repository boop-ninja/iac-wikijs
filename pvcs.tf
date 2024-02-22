##################################################################
# Persisted Volume Claims
##################################################################

resource "kubernetes_persistent_volume_claim" "i" {
  metadata {
    name      = "${var.namespace}-database-pv-claim"
    namespace = var.namespace
    labels    = local.common_labels
  }
  spec {
    storage_class_name = "longhorn"
    access_modes       = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "20Gi"
      }
    }
  }
}

