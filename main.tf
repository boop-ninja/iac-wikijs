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
    MYSQL_PASSWORD = var.database_password
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
    DB_PASSWORD = var.database_password
  }
}

resource "random_password" "p" {
  length = 36
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



##################################################################
# Persisted Volume Claims
##################################################################

resource "kubernetes_persistent_volume_claim" "i" {
  metadata {
    name      = "${var.namespace}-database-pv-claim"
    namespace = var.namespace
    labels    = local.common_labels
  }
  spec {
    storage_class_name = "longhorn"
    access_modes       = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "20Gi"
      }
    }
  }
}





