provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}
resource "google_project_service" "apis" {
  for_each = toset([
    "run.googleapis.com",
    "sqladmin.googleapis.com",
    "iam.googleapis.com",
    "artifactregistry.googleapis.com",
    "vpcaccess.googleapis.com",
    "servicenetworking.googleapis.com",
    "secretmanager.googleapis.com"
  ])
  project            = var.gcp_project_id
  service            = each.key
  disable_on_destroy = false

}
data "google_artifact_registry_repository" "existing_timeoff_app_repo" {
  location      = var.gcp_region
  repository_id = var.existing_artifact_registry_id
}

data "google_compute_network" "default_network" {
  project = var.gcp_project_id
  name    = "default"
}

terraform {
  backend "gcs" {
    bucket = "timeoff-app-remote-state"
  }
}
