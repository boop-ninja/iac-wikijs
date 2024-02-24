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
    "config.yaml" = yamlencode({
      ha     = true
      port   = local.web_port
      bindIP = "0.0.0.0"
      offline = false
      logLevel = "info"
      logFormat = "default"
      bodyParserLimit = "10mb"
      db = {
        type = "mysql"
        port = "3306"
        user = "wiki"
        db   = "wiki"
        host = local.database_host
        port = local.database_port
      }
    })
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
    MYSQL_DATABASE = var.database_name
    MYSQL_USER     = var.database_user
  }
}

