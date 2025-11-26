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

data "google_compute_subnetwork" "default_subnetwork" {
  project = var.gcp_project_id
  name    = "default"
  region  = var.gcp_region
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.timeoff_app_cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.timeoff_app_cluster.master_auth[0].cluster_ca_certificate)

  ignore_annotations = [
    "^autopilot\\.gke\\.io\\/.*",
    "^cloud\\.google\\.com\\/.*"
  ]
}

terraform {
  backend "gcs" {
    bucket = "timeoff-gke-rstate"
  }
}
