##################################################################
# Provider Configurations
##################################################################

provider "cloudflare" {
  email     = var.cloudflare_email
  api_token = var.cloudflare_api_token
}

provider "kubernetes" {
  load_config_file = "false"
  insecure         = "true"

  host     = var.kube_host
  username = var.kube_username
  password = var.kube_password
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
      name = local.prefix
    }

    labels = local.common_labels

    name = local.prefix
  }
}

##################################################################
# ConfigMaps
##################################################################

resource "kubernetes_config_map" "i_web" {
  depends_on = [kubernetes_namespace.i]
  metadata {
    name      = "${local.prefix}-web-config"
    namespace = local.namespace
    labels    = local.common_labels
  }

  data = {
    DB_TYPE     = "postgres"
    DB_HOST     = "127.0.0.1"
    DB_PORT     = "5432"
    DB_NAME     = local.prefix
    DB_USER     = local.prefix
    DB_PASSWORD = var.database_password
  }
}

resource "kubernetes_config_map" "i_db" {
  depends_on = [kubernetes_namespace.i]
  metadata {
    name      = "${local.prefix}-database-config"
    namespace = local.namespace
    labels    = local.common_labels
  }

  data = {
    POSTGRES_DB       = local.prefix
    POSTGRES_USER     = local.prefix
    PGDATA            = "/var/lib/postgresql/data/pgdata"
    POSTGRES_PASSWORD = var.database_password
  }
}

##################################################################
# Persisted Volume Claims
##################################################################

resource "kubernetes_persistent_volume_claim" "i" {
  metadata {
    name      = "${local.prefix}-pgdata-pv-claim"
    namespace = local.namespace
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
    name      = "${local.prefix}-web"
    namespace = local.namespace
    labels    = local.common_labels
  }
  spec {
    selector = {
      app = "${kubernetes_deployment.i.metadata.0.labels.app}"
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
    name      = "${local.prefix}-web"
    namespace = local.namespace
    labels    = local.common_labels
    annotations = {
      "kubernetes.io/ingress.class"                   = "traefik"
      "ingress.kubernetes.io/allowed-hosts"           = "dnd.boop.ninja,wiki.boop.ninja"
      "ingress.kubernetes.io/custom-response-headers" = "Access-Control-Allow-Origin:*"
      "ingress.kubernetes.io/custom-request-headers"  = "Origin:https://wiki.boop.ninja"
    }
  }

  spec {
    rule {
      host = var.dns_hostname
      http {
        path {
          backend {
            service_name = "${local.prefix}-web"
            service_port = "web"
          }
          path = "/*"
        }
      }
    }

    tls {
      secret_name = "wikijs-web-tls-cert-9kc6db6t7d"
    }
  }
}

