variable "gcp_project_id" {
  type = string
}

variable "gcp_region" {
  type    = string
  default = "europe-west1"
}

variable "db_name" {
  type    = string
  default = "timeoff_db"
}

variable "db_user" {
  type    = string
  default = "timeoff_user"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "app_image_tag" {
  type    = string
  default = "latest"
}

variable "existing_artifact_registry_id" {
  type    = string
  default = "timeoff-app"
}
