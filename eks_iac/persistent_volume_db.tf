resource "kubernetes_persistent_volume_claim" "timeoff_db_pvc" {
  metadata {
    name = "timeoff-db-pvc"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    storage_class_name = "standard"
  }
  
}

resource "kubernetes_deployment" "mysql_deployment" {
  metadata {
    name = "mysql-deployment"
  }
  spec {

    replicas = 1
    selector {
      match_labels = {
        app = "mysql"
      }
    }
    template {
      metadata {
        labels = {
          app = "mysql"
        }
      }
      spec {
            security_context {
      fs_group = 999
    }
        container {
          name  = "mysql-container"
          image = "mysql:5.7"
          args = ["--ignore-db-dir=lost+found"]
                    resources {
            requests = {
              cpu    = "500m"
              memory = "1Gi"
            }
          }
          env {
            name  = "MYSQL_DATABASE"
            value = var.db_name
          }
          env {
            name  = "MYSQL_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.timeoff_secrets.metadata[0].name
                key = "db_user"
              }
            }
          }
          env {
            name  = "MYSQL_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.timeoff_secrets.metadata[0].name
                key = "db_password"
              }
            }
          }
          env {
            name  = "MYSQL_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.timeoff_secrets.metadata[0].name
                key = "db_password"
              }
            }
          }
          port {
            container_port = 3306
          }
          volume_mount {
            name       = "mysql-persistent-storage"
            mount_path = "/var/lib/mysql"
          }
        }
        volume {
          name = "mysql-persistent-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.timeoff_db_pvc.metadata[0].name
          }
        }
      }
    }
  }
  #wait_for_rollout = true
}

resource "kubernetes_service" "mysql_service" {
  metadata {
    name = "mysql-service"
  }
  spec {
    selector = {
      app = "mysql"
    }
    port {
      port        = 3306
      target_port = 3306
    }
    type = "ClusterIP"
  }
}