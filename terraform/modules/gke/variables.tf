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
variable "pods_range_name" {
  type    = string
  
}
variable "services_range_name" {
  type    = string
  
}
variable "vpc_connection_ready" {
  type    = any

}