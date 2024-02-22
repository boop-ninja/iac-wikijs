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
