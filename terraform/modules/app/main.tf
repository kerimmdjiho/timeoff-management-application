
data "google_secret_manager_secret_version" "db_pass_secret_version" {
  secret  = "${var.env}-db-password"
  project = var.gcp_project_id
}


resource "kubernetes_secret" "timeoff_secrets" {
  metadata {
    name = "timeoff-secrets"
  }

  type = "Opaque"

  data = {
    db_user        = var.db_user
    db_password    = data.google_secret_manager_secret_version.db_pass_secret_version.secret_data
    gcp_project_id = var.gcp_project_id
  }
  #depends_on = [ google_container_cluster.timeoff_app_cluster ]
}

resource "kubernetes_deployment_v1" "timeoff_app_deployment" {
  metadata {
    name = "timeoff-app-deployment"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "timeoff-app"
      }
    }
    template {
      metadata {
        labels = {
          app = "timeoff-app"
        }
      }
      spec {
        container {
          name  = "timeoff-app-container"
          image = "${var.gcp_region}-docker.pkg.dev/${var.gcp_project_id}/${var.existing_artifact_registry_id}/timeoff-app:latest"
          port {
            container_port = 3000
          }

          security_context {
            allow_privilege_escalation = false
            privileged                 = false
            read_only_root_filesystem  = false

            capabilities {
              add  = []
              drop = ["NET_RAW"]
            }
          }
          env {
            name  = "NODE_ENV"
            value = var.env
          }
          env {
            name = "DB_HOST"
            #kad koristim gke sql instance
            #value = google_sql_database_instance.timeoff_db_instance_gke.private_ip_address
            #kad koristim volume  
            value = var.db_host_ip
          }
          env {
            name = "DB_USERNAME"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.timeoff_secrets.metadata[0].name
                key  = "db_user"
              }
            }
          }
          env {
            name = "DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.timeoff_secrets.metadata[0].name
                key  = "db_password"
              }
            }
          }
          env {
            name  = "DB_NAME"
            value = var.db_name
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 3000
            }
            #bilo 5, povecala zbog nedostupnosti s browsera
            initial_delay_seconds = 15
            timeout_seconds       = 5
            failure_threshold     = 3
            period_seconds        = 10

          }
        }
        security_context {
          #run_as_non_root = true
          seccomp_profile {
            type = "RuntimeDefault"
          }
        }
        toleration {
          effect   = "NoSchedule"
          key      = "kubernetes.io/arch"
          operator = "Equal"
          value    = "amd64"

        }
      }
    }
  }
}

resource "kubernetes_service_v1" "timeoff_app_service" {
  metadata {
    name = "timeoff-app-service"

  }
  spec {
    selector = {
      app = "timeoff-app"
    }
    ip_family_policy = "RequireDualStack"
    port {
      port        = 3000
      target_port = 3000
    }
    type = "LoadBalancer"
  }
#depends_on = [ google_container_cluster.timeoff_app_cluster ]
}





