locals {
  pvc_name             = kubernetes_persistent_volume_claim.i.metadata.0.name
  database_volume_name = "${var.namespace}-database-persistent-storage"
  common_labels = {
    target = var.namespace
  }
  database_host = format("%s.%s.svc.cluster.local", kubernetes_service.i_database.metadata[0].name, var.namespace)
  database_port = 3306
}
