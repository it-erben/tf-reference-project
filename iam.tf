resource "google_service_account" "runtime" {
  project      = var.project_id
  account_id   = "${var.name_prefix}-run"
  display_name = "Cloud Run runtime for ${var.name_prefix}"
  depends_on   = [google_project_service.required["iam.googleapis.com"]]
}

resource "google_project_iam_member" "runtime" {
  for_each = toset(["roles/aiplatform.user", "roles/bigquery.jobUser"])
  project  = var.project_id
  role     = each.value
  member   = google_service_account.runtime.member
  depends_on = [
    google_project_service.required["aiplatform.googleapis.com"],
    google_project_service.required["bigquery.googleapis.com"],
  ]
}

resource "google_storage_bucket_iam_member" "runtime" {
  for_each = toset(["roles/storage.objectCreator", "roles/storage.objectViewer"])
  bucket   = module.storage.bucket_name
  role     = each.value
  member   = google_service_account.runtime.member
}

resource "google_bigquery_table_iam_member" "runtime" {
  project    = var.project_id
  dataset_id = module.bigquery.dataset_id
  table_id   = module.bigquery.table_id
  role       = "roles/bigquery.dataEditor"
  member     = google_service_account.runtime.member
}

resource "google_secret_manager_secret_iam_member" "runtime" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.session.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = google_service_account.runtime.member
}
