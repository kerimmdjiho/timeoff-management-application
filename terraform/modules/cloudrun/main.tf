
data "google_secret_manager_secret_version" "db_pass_secret_version" {
  secret  = "${var.env}-db-password"
  project = var.gcp_project_id
}

resource "google_cloud_run_v2_service" "timeoff_app_service" {
  name     = "timeoff-app"
  location = var.gcp_region

  template {
    vpc_access {
      connector = "projects/${var.gcp_project_id}/locations/${var.gcp_region}/connectors/${var.vpc_connector_name}"
      egress    = "ALL_TRAFFIC"
    }

    containers {
      image = "${var.gcp_region}-docker.pkg.dev/${var.gcp_project_id}/${var.existing_artifact_registry_id}/timeoff-app:latest"
      ports {
        container_port = 3000
      }
      env {
        name  = "NODE_ENV"
        value = var.env
      }
      env {

        name  = "DB_HOST"
        value = var.db_host
      }
      env {
        name = "DB_USERNAME"
        value= var.db_user
      }
      env {
        name  = "DB_NAME"
        value = var.db_name
      }
      env {
        name = "DB_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = data.google_secret_manager_secret_version.db_pass_secret_version.secret
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


}

#za javni pristup 
resource "google_cloud_run_v2_service_iam_member" "allow_unauthenticated" {
  location   = google_cloud_run_v2_service.timeoff_app_service.location
  name       = google_cloud_run_v2_service.timeoff_app_service.name
  role       = "roles/run.invoker"
  member     = "allUsers"
  depends_on = [google_cloud_run_v2_service.timeoff_app_service]
}


