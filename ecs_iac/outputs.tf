output "cloud_run_url" {
  description = "link"
  value       = google_cloud_run_v2_service.timeoff_app_service.uri
}

