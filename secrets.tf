ephemeral "random_password" "session" {
  length  = 64
  special = false
}

resource "google_secret_manager_secret" "session" {
  project             = var.project_id
  secret_id           = "${var.name_prefix}-session"
  labels              = local.labels
  deletion_protection = false
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
  depends_on = [google_project_service.required["secretmanager.googleapis.com"]]
}

resource "google_secret_manager_secret_version" "session" {
  secret                 = google_secret_manager_secret.session.id
  secret_data_wo         = ephemeral.random_password.session.result
  secret_data_wo_version = var.session_secret_rotation
  lifecycle {
    create_before_destroy = true
  }
}
