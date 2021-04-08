##################################################################
# Provider Configurations
##################################################################

provider "cloudflare" {
  email     = var.cloudflare_email
  api_token = var.cloudflare_api_token
}

provider "kubernetes" {
  load_config_file = false

  host     = var.kube_host
  client_certificate = base64decode(var.kube_crt)
  client_key = base64decode(var.kube_key)
  insecure = true
}

##################################################################
# Domain Name
##################################################################


data "cloudflare_zones" "i" {
  filter {
    name   = var.dns_zone
    status = "active"
    paused = false
  }
}

resource "cloudflare_record" "i" {
  zone_id = lookup(data.cloudflare_zones.i.zones[0], "id")
  name    = replace(var.dns_hostname, ".${var.dns_zone}", "")
  value   = var.dns_zone
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

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
# ConfigMaps
##################################################################

resource "kubernetes_config_map" "i_web" {
  depends_on = [kubernetes_namespace.i]
  metadata {
    name      = "${var.namespace}-web-config"
    namespace = var.namespace
    labels    = local.common_labels
  }

  data = {
    DB_TYPE     = "postgres"
    DB_HOST     = "127.0.0.1"
    DB_PORT     = "5432"
    DB_NAME     = var.namespace
    DB_USER     = var.namespace
    DB_PASSWORD = var.database_password
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
    access_modes = ["ReadWriteOnce"]
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
      app = kubernetes_deployment.i.metadata.0.labels.app
    }

    port {
      name        = "web"
      port        = 80
      target_port = 3000
    }

    type = "ClusterIP"
  }
}

##################################################################
# Ingress
##################################################################


resource "kubernetes_ingress" "i" {
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
            service_name = "${var.namespace}-web"
            service_port = "web"
          }
          path = "/"
        }
      }
    }

    tls {
      secret_name = "wikijs-web-tls-cert-9kc6db6t7d"
    }
  }
}

