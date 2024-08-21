locals {
  meilisearch_module_path = "/wiki/server/modules/search/meilisearch"
}

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

        # Mount "kubernetes_secret" "i_db"
        volume {
          name = "db-pass"
          secret {
            secret_name = kubernetes_secret.i_db.metadata.0.name
          }
        }

        volume {
          name = "meilisearch-module"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.meilisearch_module.metadata.0.name
          }
        }

        init_container {
          name  = "${var.namespace}-init"
          image = "mbround18/wikijs-meilisearch-module:latest"

          command = ["sh", "-c"]
          args = [
            "cp -r /modules/meilisearch/* ${local.meilisearch_module_path};",
            "chown -R 1000:1000 ${local.meilisearch_module_path};"
          ]

          volume_mount {
            name       = "meilisearch-module"
            mount_path = local.meilisearch_module_path
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
            name       = "db-pass"
            sub_path   = "DB_PASSWORD"
          }

          volume_mount {
            name       = "config"
            mount_path = "/app/config.yaml"
            sub_path   = "config.yaml"
          }

          volume_mount {
            name       = "meilisearch-module"
            mount_path = local.meilisearch_module_path
          }

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
            container_port = local.web_port
          }
        }

      }
    }
  }
}

