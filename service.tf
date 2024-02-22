##################################################################
# Services
##################################################################

resource "kubernetes_service" "i_web" {
  metadata {
    name      = "${var.namespace}-web"
    namespace = var.namespace
    labels    = local.common_labels
  }
  spec {
    selector = {
      target = local.common_labels.target
      app    = "web"
    }

    port {
      name        = "web"
      port        = 80
      target_port = 3000
    }

    type = "ClusterIP"
  }
}
resource "kubernetes_service" "i_database" {
  metadata {
    name      = "${var.namespace}-database"
    namespace = var.namespace
    labels    = local.common_labels
  }
  spec {
    selector = {
      target = local.common_labels.target
      app    = "database"
    }

    port {
      name        = "database"
      port        = local.database_port
      target_port = local.database_port
    }

    cluster_ip = "None"
    type = "ClusterIP"
  }
}
