resource "google_secret_manager_secret" "db_pass_secret" {
  secret_id = "db-password-timeoff" 
  project   = var.gcp_project_id

  replication {
    auto {} 
  }

  depends_on = [google_project_service.apis["secretmanager"]]
}

resource "google_secret_manager_secret_version" "db_pass_secret_version" {
  secret      = google_secret_manager_secret.db_pass_secret.id
  secret_data = var.db_password

  depends_on = [google_project_service.apis["secretmanager"]]
}

resource "google_secret_manager_secret" "db_username_secret" {
  secret_id = "db-username-timeoff"
    project   = var.gcp_project_id
  replication{
    auto {}
  }
  depends_on = [google_project_service.apis["secretmanager"]]
}

  resource "google_secret_manager_secret_version" "db_username_secret_version" {
    secret      = google_secret_manager_secret.db_username_secret.id
    secret_data = var.db_user
    depends_on = [google_project_service.apis["secretmanager"]]
  }