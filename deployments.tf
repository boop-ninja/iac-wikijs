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
        labels = merge(local.common_labels, {
          app = "web"
        })
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

          env_from {
            secret_ref {
              name = kubernetes_secret.i_web.metadata.0.name
            }
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
            container_port = 3000
          }
        }

      }
    }
  }
}

# Database Deployment
resource "kubernetes_stateful_set" "d" {
  metadata {
    name      = "${var.namespace}-database"
    labels    = local.common_labels
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
        # Add Init Container to create the path /var/lib/postgresql/data/pgdata if not exist and change the owner to 999
        init_container {
          name  = "init-chown-data"
          image = "busybox"
          command = [
            "sh",
            "-c",
            "mkdir -p /var/lib/postgresql/data/pgdata && chown -R 999:999 /var/lib/postgresql/data/pgdata"
          ]
          volume_mount {
            name       = "wikijs-pgdata-persistent-storage"
            mount_path = "/var/lib/postgresql/data"
          }
        }

        # I need another init container to create the database and user
        init_container {
          name  = "init-db"
          image = var.docker_images.database
          command = [
            "sh",
            "-c",
            "psql -h localhost -U postgres -c 'CREATE DATABASE IF NOT EXISTS ${var.database_name};' && psql -h localhost -U postgres -c \"CREATE USER IF NOT EXISTS ${var.database_user} WITH PASSWORD '${var.database_password}';\" && psql -h localhost -U postgres -c 'GRANT ALL PRIVILEGES ON DATABASE ${var.database_name} TO ${var.database_user};'"
          ]
          env {
            name = "PGPASSWORD"
            value = var.database_password
          }
          volume_mount {
            name       = "wikijs-pgdata-persistent-storage"
            mount_path = "/var/lib/postgresql/data"
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
            name           = "postgres"
            container_port = 5432
          }

          volume_mount {
            name       = "wikijs-pgdata-persistent-storage"
            mount_path = "/var/lib/postgresql/data"
            sub_path   = "pgdata"
            read_only = false
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
    service_name = ""
  }
}
