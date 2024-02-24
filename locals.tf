locals {
  common_labels = {
    target = var.namespace
  }
  database_host = format("%s.%s.svc.cluster.local", "wikijs-innodb-cluster-instances", var.namespace)
  database_port = 3306
  web_port = 3000
}
