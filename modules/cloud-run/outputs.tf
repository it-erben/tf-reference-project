output "service_name" {
  description = "Tatsaechlicher Servicename fuer die Serverless NEG."
  value       = google_cloud_run_v2_service.app.name
}
output "uri" {
  description = "Cloud-Run-URI; durch Ingress nicht direkt oeffentlich zugaenglich."
  value       = google_cloud_run_v2_service.app.uri
}
output "id" {
  description = "Ressourcen-ID des Service."
  value       = google_cloud_run_v2_service.app.id
}
