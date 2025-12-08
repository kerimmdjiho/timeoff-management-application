variable "gcp_project_id" {
  type    = string
}

variable "gcp_region" {
  type    = string
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
  default = "10.8.0.0/20"
}