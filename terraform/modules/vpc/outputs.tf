output "network_id" {
  value = google_compute_network.vpc_network.id
}
output "pods_range_name" {
  value = google_compute_subnetwork.subnet.secondary_ip_range[0].range_name
}
output "services_range_name" {
  value = google_compute_subnetwork.subnet.secondary_ip_range[1].range_name
}
output "vpc_connection_ready" {
  value = google_service_networking_connection.private_vpc_connection.id
}
output "connector_name" {
  value       = google_vpc_access_connector.connector.name
}
