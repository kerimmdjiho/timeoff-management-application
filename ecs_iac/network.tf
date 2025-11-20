resource "google_compute_global_address" "private_ip_alloc" {
  project       = var.gcp_project_id
  name          = "timeoff-sql-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = "projects/${var.gcp_project_id}/global/networks/default"

}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = "projects/${var.gcp_project_id}/global/networks/default"
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]
  depends_on              = [google_project_service.apis["servicenetworking.googleapis.com"]]

}

resource "google_vpc_access_connector" "connector" {
  project       = var.gcp_project_id
  name          = "timeoff-vpc-connector"
  region        = var.gcp_region
  network       = "projects/${var.gcp_project_id}/global/networks/default"
  ip_cidr_range = "10.8.0.0/28"

  depends_on = [google_project_service.apis["vpcaccess.googleapis.com"]]

}
