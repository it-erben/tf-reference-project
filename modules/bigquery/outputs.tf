output "dataset_id" {
  description = "ID des angelegten Datasets."
  value       = google_bigquery_dataset.results.dataset_id
}
output "table_id" {
  description = "ID der angelegten Tabelle."
  value       = google_bigquery_table.results.table_id
}
output "table_reference" {
  description = "Vollständige Referenz im Format Projekt.Dataset.Tabelle."
  value       = "${var.project_id}.${google_bigquery_dataset.results.dataset_id}.${google_bigquery_table.results.table_id}"
}
