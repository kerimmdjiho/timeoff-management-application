variable "gcp_project_id" {
  type = string
}

variable "gcp_region" {
  type    = string
  default = "europe-west1"
}
variable "env" {
  type    = string  
}
variable "subnet_cidr" {
  type    = string
  default = "10.0.0.0/20"
  }
variable "pods_cidr" {
  type    = string
  default = "10.4.0.0/14" 
}
variable "services_cidr" {
  type    = string
  default = "10.1.0.0/20" 
}
variable "db_name" {
  type    = string
  default = "timeoff_db"
}
variable "db_user" {
  type    = string
  default = "timeoff_user"
}
variable "data" {
  type      = string
  sensitive = true
}
variable "existing_artifact_registry_id" {
  type    = string
  default = "timeoff-app"
}
variable "app_image_tag" {
  type    = string
  default = "latest"
}
variable "vpc_connector_name" {
  type    = string
} 