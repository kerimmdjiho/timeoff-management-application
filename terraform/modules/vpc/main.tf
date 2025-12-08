resource "google_compute_network" "vpc_network" {
  name                    = "${var.env}-vpc"
  auto_create_subnetworks = false
  project = var.gcp_project_id
  
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.env}-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.gcp_region
  network       = google_compute_network.vpc_network.id
  project       = var.gcp_project_id

  stack_type       = "IPV4_IPV6"
  ipv6_access_type = "EXTERNAL"
   
  secondary_ip_range {
    range_name    = "pods-range"
    ip_cidr_range = var.pods_cidr
  }

  secondary_ip_range {
    range_name    = "services-range"
    ip_cidr_range = var.services_cidr
  }
}

#ovo je za cloud run  
resource "google_compute_global_address" "private_ip_alloc" {
  project       = var.gcp_project_id
  name          = "${var.env}-private-ip-alloc"  #"timeoff-sql-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc_network.id  #"projects/${var.gcp_project_id}/global/networks/${var.network_name}"

}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]
  update_on_creation_fail = true
  #depends_on              = [google_project_service.apis["servicenetworking.googleapis.com"]]

}

resource "google_vpc_access_connector" "connector" {
  project       = var.gcp_project_id
  name          = "${var.env}-connector"
  region        = var.gcp_region
  network       = google_compute_network.vpc_network.id
  ip_cidr_range = "10.8.0.0/28"
  min_instances = 2
  max_instances = 3

  #depends_on = [google_project_service.apis["vpcaccess.googleapis.com"]]

}
