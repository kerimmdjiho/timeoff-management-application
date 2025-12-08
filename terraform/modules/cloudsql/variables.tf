variable "gcp_project_id" {
  type    = string
}

variable "db_user" {
  type    = string

}
variable "data" {
  type      = string
  sensitive = true
}

variable "gcp_region" {
  type    = string

}
variable "db_name" {
  type    = string

}
variable "network_id" {
  type    = string
}
variable "vpc_connection_ready" {
  type    = any
}
variable "env" {
  type    = string
}