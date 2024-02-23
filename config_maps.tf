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
    DB_TYPE   = "mysql"
    DB_HOST   = local.database_host
    DB_PORT   = local.database_port
    DB_NAME   = var.database_name
    DB_USER   = "wiki"
    HA_ACTIVE = "true"
    DB_SSL    = "true"
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

