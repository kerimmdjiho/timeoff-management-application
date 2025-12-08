output "endpoint" {
  value = google_container_cluster.timeoff_app_cluster.endpoint
  
}
output "cluster_ca_certificate" {
  value = google_container_cluster.timeoff_app_cluster.master_auth[0].cluster_ca_certificate
}