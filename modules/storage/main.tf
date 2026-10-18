resource "google_storage_bucket" "results" {
  project                     = var.project_id
  name                        = var.bucket_name
  location                    = var.location
  labels                      = var.labels
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = var.allow_data_deletion
}
