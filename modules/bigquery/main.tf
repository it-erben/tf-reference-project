resource "google_bigquery_dataset" "results" {
  project                    = var.project_id
  dataset_id                 = var.dataset_id
  location                   = var.location
  labels                     = var.labels
  delete_contents_on_destroy = false
}

resource "google_bigquery_table" "results" {
  project             = var.project_id
  dataset_id          = google_bigquery_dataset.results.dataset_id
  table_id            = var.table_id
  schema              = var.schema
  labels              = var.labels
  deletion_protection = !var.allow_data_deletion
}
