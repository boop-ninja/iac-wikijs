resource "kubernetes_job" "init_db" {
  metadata {
    name = "init-db"
    labels = {
      app = "database"
    }
  }

  spec {
    template {
      metadata {
        labels = {
          app = "database"
        }
      }

      spec {
        container {
          name  = "init-db"
          image = var.docker_images.database
          command = [
            "sh",
            "-c",
            "psql -h ${local.database_host} -U postgres -c 'CREATE DATABASE IF NOT EXISTS ${var.database_name};' && psql -h localhost -U postgres -c \"CREATE USER IF NOT EXISTS ${var.database_user} WITH PASSWORD '${var.database_password}';\" && psql -h localhost -U postgres -c 'GRANT ALL PRIVILEGES ON DATABASE ${var.database_name} TO ${var.database_user};'"
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
        restart_policy = "Never"
      }
    }
    backoff_limit = 4
  }
}
