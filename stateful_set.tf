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
      version          = "8.3.0"
      tlsUseSelfSigned = true
      datadirVolumeClaimTemplate = {
        accessModes = ["ReadWriteOnce"]
        resources = {
          requests = {
            storage = "20Gi"
          }
        }
      }
      mycnf = <<-EOT
        bind-address = 0.0.0.0

        [mysqld]
        max_connections =  200
        default_authentication_plugin = caching_sha2_password
        EOT
      service = {
        type = "ClusterIP"
      }
    }
  }
}
