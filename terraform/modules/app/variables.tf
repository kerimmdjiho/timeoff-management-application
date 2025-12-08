variable "gcp_project_id" {
  type = string
}

variable "gcp_region" {
  type    = string
  default = "europe-west1"
}

variable "db_name" {
  type    = string
}

variable "db_user" {
  type    = string

}


variable "existing_artifact_registry_id" {
  type    = string

}

variable "db_host_ip" {
  type    = string

}

variable "env" {
  type    = string

}