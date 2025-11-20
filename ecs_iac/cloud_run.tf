resource "google_cloud_run_v2_service" "timeoff_app_service" {
  name     = "timeoff-app"
  location = var.gcp_region

  template {
    vpc_access {
      connector = "projects/${var.gcp_project_id}/locations/${var.gcp_region}/connectors/${google_vpc_access_connector.connector.name}"
      egress    = "ALL_TRAFFIC"
    }

    containers {
      image = "${var.gcp_region}-docker.pkg.dev/${var.gcp_project_id}/${data.google_artifact_registry_repository.existing_timeoff_app_repo.repository_id}/timeoff-app:latest"
      ports {
        container_port = 3000
      }
      env {
        name  = "NODE_ENV"
        value = "test"
      }
      env {

        name  = "DB_HOST"
        value = google_sql_database_instance.timeoff_db_instance.private_ip_address
      }
      env {
        name = "DB_USERNAME"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.db_username_secret.secret_id
            version = "latest"
          }
        }
      }
      env {
        name  = "DB_NAME"
        value = var.db_name
      }
      env {
        name = "DB_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.db_pass_secret.secret_id
            version = "latest"
          }
        }
      }
    }

    scaling {
      min_instance_count = 0
      max_instance_count = 1
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  depends_on = [
    data.google_artifact_registry_repository.existing_timeoff_app_repo,
    google_sql_database_instance.timeoff_db_instance,
    google_vpc_access_connector.connector,
    google_secret_manager_secret_version.db_pass_secret_version,
    google_secret_manager_secret_version.db_username_secret_version
  ]
}

#za javni pristup 
resource "google_cloud_run_v2_service_iam_member" "allow_unauthenticated" {
  location   = google_cloud_run_v2_service.timeoff_app_service.location
  name       = google_cloud_run_v2_service.timeoff_app_service.name
  role       = "roles/run.invoker"
  member     = "allUsers"
  depends_on = [google_cloud_run_v2_service.timeoff_app_service]
}


