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
    DB_TYPE   = "postgres"
    DB_HOST   = local.database_host
    DB_PORT   = "5432"
    DB_NAME   = var.database_name
    DB_USER   = var.database_user
    HA_ACTIVE = "true"
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
    PGDATABASE = var.database_name
    PGUSER     = var.database_user
    PGPASSWORD = var.database_password

    POSTGRES_DB       = var.database_name
    POSTGRES_USER     = var.database_user
    POSTGRES_PASSWORD = var.database_password

    PGDATA = "/var/lib/postgresql/data/pgdata"
  }
}

# Create a config map with a shell script that creates the database if not exist and the user if not exist
resource "kubernetes_config_map" "i_db_init" {
  depends_on = [kubernetes_namespace.i]
  metadata {
    name      = "${var.namespace}-database-init"
    namespace = var.namespace
    labels    = local.common_labels
  }

  data = {
    init.sh = file("${path.module}/scripts/init.sh")
  }
}
