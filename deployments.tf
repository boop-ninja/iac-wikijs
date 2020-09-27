resource "kubernetes_deployment" "i" {
  depends_on = [
    kubernetes_namespace.i, 
    kubernetes_config_map.i_web, 
    kubernetes_config_map.i_db,
    kubernetes_persistent_volume_claim.i
  ]

  metadata {
    name      = local.prefix
    labels    = local.common_labels
    namespace = local.namespace
  }

  spec {
    selector {
      match_labels = local.common_labels
    }

    template {
      metadata {
        namespace = local.namespace
        labels    = local.common_labels
      }

      spec {
        container {
          name              = "${local.prefix}-web"
          image             = "requarks/wiki:2.5"
          image_pull_policy = "Always"
          env_from {
            config_map_ref {
              name = kubernetes_config_map.i_web.metadata.0.name
            }
          }
          resources {
            limits {
              cpu    = "0.5"
              memory = "512Mi"
            }
          }
          port {
            name           = "web"
            container_port = 3000
          }
        }
        container {
          name  = "${local.prefix}-database"
          image = "postgres:13"

          env_from {
            config_map_ref {
              name = kubernetes_config_map.i_db.metadata.0.name
            }

          }

          resources {
            limits {
              cpu    = "0.5"
              memory = "512Mi"
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
          name = "${local.prefix}-pgdata-persistent-storage"
          persistent_volume_claim {
            claim_name = local.pvc_name
          }
        }
      }
    }
  }
}