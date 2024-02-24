resource "kubernetes_deployment" "i" {
  depends_on = [
    kubernetes_namespace.i,
    kubernetes_config_map.i_web,
    kubernetes_config_map.i_db
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
        labels = merge(local.common_labels, {
          app = "web"
        })
      }

      spec {
        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map.i_web.metadata.0.name
          }
        }

        # mount tls secret
        volume {
          name = "tls"
          secret {
            secret_name = kubernetes_secret.i_web.metadata.0.name
          }
        }

        # Mount "kubernetes_secret" "i_db"
        volume {
          name = "db_pass"
          secret {
            secret_name = kubernetes_secret.i_db.metadata.0.name
          }
        }

        container {
          name              = "${var.namespace}-web"
          image             = var.docker_images.application
          image_pull_policy = "Always"

          env {
            name  = "CONFIG_FILE"
            value = "/app/config.yaml"
          }

          env {
            name  = "HA_ACTIVE"
            value = "1"
          }

          env {
            name  = "DB_PASS_FILE"
            value = "/app/db_pass"
          }

          volume_mount {
            mount_path = "/app/db_pass"
            name       = "db_pass"
            sub_path = "DB_PASSWORD"
          }

          volume_mount {
            name       = "config"
            mount_path = "/app/config.yaml"
            sub_path   = "config.yaml"
          }

          volume_mount {
            name       = "tls"
            mount_path = "/app/tls"
          }

          #          env_from {
          #            config_map_ref {
          #              name = kubernetes_config_map.i_web.metadata.0.name
          #            }
          #          }

          #          env_from {
          #            secret_ref {
          #              name = kubernetes_secret.i_web.metadata.0.name
          #            }
          #          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "1024Mi"
            }
            requests = {
              cpu    = "0.05"
              memory = "256Mi"
            }
          }
          port {
            name           = "web"
            container_port = 3000
          }
        }

      }
    }
  }
}

