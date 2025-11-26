output "service_url" {
  description = "link"
  value       = kubernetes_service_v1.timeoff_app_service.status[0].load_balancer[0].ingress[0].ip
}
