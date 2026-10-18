locals {
  bucket_name = coalesce(var.bucket_name, "${var.project_id}-${var.name_prefix}-results")
  labels = {
    application = var.name_prefix
    managed_by  = "terraform"
    purpose     = "training"
  }
}

module "storage" {
  source              = "./modules/storage"
  project_id          = var.project_id
  location            = var.region
  bucket_name         = local.bucket_name
  labels              = local.labels
  allow_data_deletion = var.allow_data_deletion
  depends_on          = [google_project_service.required["storage.googleapis.com"]]
}

module "bigquery" {
  source              = "./modules/bigquery"
  project_id          = var.project_id
  location            = var.region
  dataset_id          = var.dataset_id
  table_id            = var.table_id
  schema              = file("${path.module}/schemas/results.json")
  labels              = local.labels
  allow_data_deletion = var.allow_data_deletion
  depends_on          = [google_project_service.required["bigquery.googleapis.com"]]
}

module "cloud_run" {
  source                = "./modules/cloud-run"
  project_id            = var.project_id
  region                = var.region
  service_name          = var.name_prefix
  container_image       = var.container_image
  service_account_email = google_service_account.runtime.email
  max_instances         = var.max_instances
  labels                = local.labels
  env_vars = {
    GOOGLE_CLOUD_PROJECT   = var.project_id
    GOOGLE_CLOUD_LOCATION  = var.gemini_location
    GEMINI_MODEL           = var.gemini_model
    GOOGLE_OAUTH_CLIENT_ID = var.google_oauth_client_id
    BUCKET_NAME            = module.storage.bucket_name
    BQ_DATASET             = module.bigquery.dataset_id
    BQ_TABLE               = module.bigquery.table_id
  }
  secret_env_vars = {
    SESSION_SECRET = {
      secret  = google_secret_manager_secret.session.secret_id
      version = google_secret_manager_secret_version.session.version
    }
  }
  depends_on = [
    google_project_service.required["run.googleapis.com"],
    google_project_iam_member.runtime,
    google_storage_bucket_iam_member.runtime,
    google_bigquery_table_iam_member.runtime,
    google_secret_manager_secret_iam_member.runtime,
  ]
}

module "https_frontend" {
  source       = "./modules/https-frontend"
  project_id   = var.project_id
  region       = var.region
  name_prefix  = var.name_prefix
  domain       = var.lb_domain
  service_name = module.cloud_run.service_name
  depends_on   = [google_project_service.required["compute.googleapis.com"]]
}
