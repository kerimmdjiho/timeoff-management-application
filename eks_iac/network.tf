resource "google_compute_global_address" "private_ip_alloc_gke" {
  project       = var.gcp_project_id
  name          = "timeoff-sql-private-ip-gke"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = "projects/${var.gcp_project_id}/global/networks/default"

}

resource "google_service_networking_connection" "private_vpc_connection_gke" {
  network                 = "projects/${var.gcp_project_id}/global/networks/default"
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc_gke.name]
  update_on_creation_fail = true
  depends_on              = [google_project_service.apis["servicenetworking.googleapis.com"]]

}

resource "google_vpc_access_connector" "connector_gke" {
  project       = var.gcp_project_id
  name          = "timeoff-vpc-connector-gke"
  region        = var.gcp_region
  network       = "projects/${var.gcp_project_id}/global/networks/default"
  ip_cidr_range = "10.6.0.0/28"

  depends_on = [google_project_service.apis["vpcaccess.googleapis.com"]]

}
