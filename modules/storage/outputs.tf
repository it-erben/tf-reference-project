output "bucket_name" {
  description = "Name des angelegten Buckets."
  value       = google_storage_bucket.results.name
}
output "id" {
  description = "Ressourcen-ID des Buckets."
  value       = google_storage_bucket.results.id
}
