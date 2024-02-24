##################################################################
# Secrets
##################################################################

resource "random_password" "a" {
  length           = 36
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
    DB_PASSWORD = random_password.a.result
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
  length           = 36
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
    rootPassword = random_password.p.result
  }
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "cert" {
  private_key_pem = tls_private_key.key.private_key_pem
  subject {
    common_name  = "boop.ninja"
    organization = "Boop Ninja"
  }
  validity_period_hours = 8760 #  1 year
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "kubernetes_secret" "i_db_tls" {
  metadata {
    name      = "tls-secret"
    namespace = var.namespace
  }
  type = "kubernetes.io/tls"
  data = {
    "tls.crt" = tls_self_signed_cert.cert.cert_pem
    "tls.key" = tls_private_key.key.private_key_pem
  }
}
