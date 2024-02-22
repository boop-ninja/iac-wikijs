# Database Deployment
resource "kubernetes_stateful_set" "d" {
  metadata {
    name = "${var.namespace}-database"
    labels = merge(local.common_labels, {
      app    = "database"
      engine = "mysql"
    })
    namespace = var.namespace
  }

  spec {
    selector {
      match_labels = local.common_labels
    }

    template {
      metadata {
        labels = merge(local.common_labels, {
          app = "database"
        })
      }

      spec {
        container {

          name  = "${var.namespace}-database"
          image = var.docker_images.database

          env_from {
            config_map_ref {
              name = kubernetes_config_map.i_db.metadata.0.name
            }
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.i_db.metadata.0.name
            }
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "256Mi"
            }
          }

          port {
            name           = "database"
            container_port = 3307
          }

          volume_mount {
            name       = local.database_volume_name
            mount_path = "/var/lib/mysql"
            sub_path   = "data"
            read_only  = false
          }
        }

        volume {
          name = local.database_volume_name

          persistent_volume_claim {
            claim_name = local.pvc_name
          }
        }
      }
    }
    service_name = ""
  }
}
