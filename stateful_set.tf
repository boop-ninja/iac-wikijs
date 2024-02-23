resource "kubernetes_manifest" "wikijs_innodbcluster" {
  manifest = {
    apiVersion = "mysql.oracle.com/v2"
    kind       = "InnoDBCluster"
    metadata = {
      name      = "wikijs-innodbcluster"
      namespace = "wikijs"
    }
    spec = {
      instances        = 2
      secretName       = kubernetes_secret.i_db_root.metadata.0.name
      version          = "8.0.36"
      tlsUseSelfSigned = true
      mycnf            = <<-EOT
        [mysqld]
        max_connections =  200
        EOT
      service = {
        type = "ClusterIP"
      }
    }
  }
}
