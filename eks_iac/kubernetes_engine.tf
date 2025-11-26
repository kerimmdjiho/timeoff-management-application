resource "google_container_cluster" "timeoff_app_cluster" {
  name                    = "timeoff-app-cluster"
  location                = var.gcp_region
  enable_autopilot        = true
  enable_l4_ilb_subsetting = true
  network                 = data.google_compute_network.default_network.id

  subnetwork              = data.google_compute_subnetwork.default_subnetwork.id
  ip_allocation_policy {
    stack_type                    = "IPV4_IPV6"
    cluster_secondary_range_name  = data.google_compute_subnetwork.default_subnetwork.secondary_ip_range[0].range_name
    services_secondary_range_name = data.google_compute_subnetwork.default_subnetwork.secondary_ip_range[1].range_name
  }
  deletion_protection = false
  depends_on = [
    google_service_networking_connection.private_vpc_connection_gke,
    google_sql_database_instance.timeoff_db_instance_gke,
    google_vpc_access_connector.connector_gke,
    data.google_artifact_registry_repository.existing_timeoff_app_repo
  ]

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
          image = "${var.gcp_region}-docker.pkg.dev/${var.gcp_project_id}/${data.google_artifact_registry_repository.existing_timeoff_app_repo.repository_id}/timeoff-app:latest"
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
            value = "test"
          }
          env {
            name  = "DB_HOST"
            #kad koristim gke sql instance
            #value = google_sql_database_instance.timeoff_db_instance_gke.private_ip_address
            #kad koristim volume  
            value = kubernetes_service.mysql_service.metadata[0].name
          }
          env {
            name  = "DB_USERNAME"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.timeoff_secrets.metadata[0].name
                key = "db_user"
              }
            }
          }
          env {
            name  = "DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.timeoff_secrets.metadata[0].name
                key = "db_password"
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
  depends_on = [ time_sleep.wait_service_cleanup ]
}
resource "time_sleep" "wait_service_cleanup" {
  depends_on = [google_container_cluster.timeoff_app_cluster]

  destroy_duration = "180s"
}
