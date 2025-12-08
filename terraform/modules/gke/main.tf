resource "google_container_cluster" "timeoff_app_cluster" {
  name                     = "${var.env}-app-cluster" #"timeoff-app-cluster"
  location                 = var.gcp_region
  project                  = var.gcp_project_id
  enable_autopilot         = true
  enable_l4_ilb_subsetting = true
  network                  = "${var.env}-vpc" #"timeoff-vpc-network"

  subnetwork = "${var.env}-subnet" #"timeoff-subnet"
  ip_allocation_policy {
    stack_type                    = "IPV4_IPV6"
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }
  deletion_protection = false
  depends_on = [
    var.vpc_connection_ready
  ]

}

