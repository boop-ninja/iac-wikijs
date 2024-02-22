##################################################################
# Namespace
##################################################################

resource "kubernetes_namespace" "i" {
  metadata {
    annotations = {
      name = var.namespace
    }

    labels = local.common_labels

    name = var.namespace
  }
}

##################################################################
# Secrets
##################################################################

resource "kubernetes_secret" "i_db" {
  depends_on = [kubernetes_namespace.i]
  metadata {
    name      = "${var.namespace}-database-secret"
    namespace = var.namespace
    labels    = local.common_labels
  }
  data = {
    POSTGRES_PASSWORD = base64encode(var.database_password)
  }
}

resource "kubernetes_secret" "i_web" {
  depends_on = [kubernetes_namespace.i]
  metadata {
    name      = "${var.namespace}-database-secret"
    namespace = var.namespace
    labels    = local.common_labels
  }
  data = {
    DB_PASSWORD = base64encode(var.database_password)
  }
}

##################################################################
# ConfigMaps
##################################################################

resource "kubernetes_config_map" "i_web" {
  depends_on = [kubernetes_namespace.i, kubernetes_service.i_database]
  metadata {
    name      = "${var.namespace}-web-config"
    namespace = var.namespace
    labels    = local.common_labels
  }

  data = {
    DB_TYPE     = "postgres"
    DB_HOST     = format("%s.%s.svc.cluster.local", kubernetes_service.i_database.metadata[0].name, var.namespace)
    DB_PORT     = "5432"
    DB_NAME     = var.namespace
    DB_USER     = var.namespace
    DB_PASSWORD = var.database_password
    HA_ACTIVE   = "true"

  }
}

resource "kubernetes_config_map" "i_db" {
  depends_on = [kubernetes_namespace.i]
  metadata {
    name      = "${var.namespace}-database-config"
    namespace = var.namespace
    labels    = local.common_labels
  }

  data = {
    POSTGRES_DB       = var.namespace
    POSTGRES_USER     = var.namespace
    PGDATA            = "/var/lib/postgresql/data/pgdata"
    POSTGRES_PASSWORD = var.database_password
  }
}

##################################################################
# Persisted Volume Claims
##################################################################

resource "kubernetes_persistent_volume_claim" "i" {
  metadata {
    name      = "${var.namespace}-pgdata-pv-claim"
    namespace = var.namespace
    labels    = local.common_labels
  }
  spec {
    storage_class_name = "longhorn"
    access_modes       = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "20G"
      }
    }
  }
}


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
      target = try(kubernetes_deployment.i.metadata.0.labels["target"], var.namespace)
      app = "web"
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
      target = try(kubernetes_deployment.i.metadata.0.labels["target"], var.namespace)
      app = "database"
    }

    port {
      name        = "web"
      port        = 5432
      target_port = 5432
    }

    type = "ClusterIP"
  }
}

##################################################################
# Ingress
##################################################################


resource "kubernetes_ingress_v1" "i" {
  metadata {
    name      = "${var.namespace}-web"
    namespace = var.namespace
    labels    = local.common_labels
    annotations = {
      "kubernetes.io/ingress.class"                   = "traefik"
      "ingress.kubernetes.io/allowed-hosts"           = var.dns_hostname
      "ingress.kubernetes.io/custom-response-headers" = "Access-Control-Allow-Origin:*"
      "ingress.kubernetes.io/custom-request-headers"  = "Origin:https://${var.dns_hostname}"
    }
  }

  spec {
    rule {
      host = var.dns_hostname
      http {
        path {
          backend {
            service {
              name = "${var.namespace}-web"
              port {
                name = "web"
              }
            }
          }
          path = "/"
        }
      }
    }

    tls {
      secret_name = "wikijs-web-tls-cert"
    }
  }
}

