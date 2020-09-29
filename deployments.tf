resource "kubernetes_deployment" "i" {
  depends_on = [
    kubernetes_namespace.i,
    kubernetes_config_map.i_web,
    kubernetes_config_map.i_db,
    kubernetes_persistent_volume_claim.i
  ]

  metadata {
    name      = var.namespace
    labels    = local.common_labels
    namespace = var.namespace
  }

  spec {
    selector {
      match_labels = local.common_labels
    }

    template {
      metadata {
        namespace = var.namespace
        labels    = local.common_labels
      }

      spec {
        container {
          name              = "${var.namespace}-web"
          image             = var.docker_images.application
          image_pull_policy = "Always"
          env_from {
            config_map_ref {
              name = kubernetes_config_map.i_web.metadata.0.name
            }
          }
          resources {
            limits {
              cpu    = "0.1"
              memory = "256Mi"
            }
            requests {
              cpu    = "0.05"
              memory = "256Mi"
            }
          }
          port {
            name           = "web"
            container_port = 3000
          }
        }
        container {
          name  = "${var.namespace}-database"
          image = var.docker_images.database

          env_from {
            config_map_ref {
              name = kubernetes_config_map.i_db.metadata.0.name
            }

          }

          resources {
            limits {
              cpu    = "0.05"
              memory = "128Mi"
            }
          }

          port {
            name           = "postgres"
            container_port = 5432
          }

          volume_mount {
            name       = "wikijs-pgdata-persistent-storage"
            mount_path = "/var/lib/postgresql/data/pgdata"
          }
        }
        volume {
          name = "${var.namespace}-pgdata-persistent-storage"
          persistent_volume_claim {
            claim_name = local.pvc_name
          }
        }
      }
    }
  }
}