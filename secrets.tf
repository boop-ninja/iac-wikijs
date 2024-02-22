##################################################################
# Secrets
##################################################################

resource "random_password" "a" {
  length = 36
  override_special = "-_.,"
}

resource "kubernetes_secret" "i_db" {
  depends_on = [kubernetes_namespace.i]
  metadata {
    name      = "${var.namespace}-database-secret"
    namespace = var.namespace
    labels    = local.common_labels
  }
  data = {
    MYSQL_PASSWORD = random_password.a.result
  }
}

resource "kubernetes_secret" "i_web" {
  depends_on = [kubernetes_namespace.i]
  metadata {
    name      = "${var.namespace}-web-secret"
    namespace = var.namespace
    labels    = local.common_labels
  }
  data = {
    DB_PASSWORD = random_password.a.result
  }
}

resource "random_password" "p" {
  length = 36
  override_special = "-_.,"
}

resource "kubernetes_secret" "i_db_root" {
  depends_on = [kubernetes_namespace.i]
  metadata {
    name      = "${var.namespace}-secret"
    namespace = var.namespace
    labels    = local.common_labels
  }
  data = {
    MYSQL_ROOT_PASSWORD = random_password.p.result
  }
}

