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

