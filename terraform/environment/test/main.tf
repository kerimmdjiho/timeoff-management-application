resource "google_project_service" "apis" {
  for_each = toset([
    "run.googleapis.com",
    "sqladmin.googleapis.com",
    "iam.googleapis.com",
    "artifactregistry.googleapis.com",
    "vpcaccess.googleapis.com",
    "servicenetworking.googleapis.com",
    "secretmanager.googleapis.com",
    "container.googleapis.com"
  ])
  project            = var.gcp_project_id
  service            = each.key
  disable_on_destroy = false
}


module "vpc" {
  source         = "../../modules/vpc"
  gcp_project_id = var.gcp_project_id
  gcp_region     = var.gcp_region
  env            = var.env
  subnet_cidr    = var.subnet_cidr
  pods_cidr      = var.pods_cidr
  services_cidr  = var.services_cidr
  depends_on     = [google_project_service.apis]
}


module "gke" {
  source               = "../../modules/gke"
  gcp_project_id       = var.gcp_project_id
  gcp_region           = var.gcp_region
  env                  = var.env
  vpc_connection_ready = module.vpc.vpc_connection_ready
  pods_range_name      = module.vpc.pods_range_name
  services_range_name  = module.vpc.services_range_name
  depends_on           = [module.cloudsql]
}

module "app" {
  source                        = "../../modules/app"
  gcp_project_id                = var.gcp_project_id
  gcp_region                    = var.gcp_region
  existing_artifact_registry_id = var.existing_artifact_registry_id
  env                           = var.env
  db_name                       = var.db_name
  db_user                       = var.db_user
  db_host_ip                    = module.cloudsql.db_instance_ip
  depends_on                    = [module.gke, module.cloudsql]

}


module "cloudsql" {
  source               = "../../modules/cloudsql"
  gcp_project_id       = var.gcp_project_id
  gcp_region           = var.gcp_region
  db_name              = var.db_name
  db_user              = var.db_user
  data                 = var.data
  network_id           = module.vpc.network_id
  vpc_connection_ready = module.vpc.vpc_connection_ready
  env                  = var.env
  depends_on           = [module.vpc]
}

module "cloudrun" {
  source                        = "../../modules/cloudrun"
  gcp_project_id                = var.gcp_project_id
  gcp_region                    = var.gcp_region
  db_name                       = var.db_name
  db_user                       = var.db_user
  db_host                       = module.cloudsql.db_instance_ip
  env                           = var.env
  existing_artifact_registry_id = var.existing_artifact_registry_id
  vpc_connector_name            = module.vpc.connector_name
  depends_on                    = [module.cloudsql]
}


