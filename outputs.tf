output "load_balancer_ip" {
  description = "Feste IPv4-Adresse fuer den A-Record beim eigenen DNS-Anbieter."
  value       = module.https_frontend.ip_address
}

output "load_balancer_url" {
  description = "Oeffentliche HTTPS-Adresse; Zertifikatsstatus separat pruefen."
  value       = module.https_frontend.url
}

output "dns_record" {
  description = "Beim autoritativen DNS-Anbieter anzulegender Eintrag."
  value = {
    name  = var.lb_domain
    type  = "A"
    value = module.https_frontend.ip_address
  }
}

output "oauth_javascript_origin" {
  description = "Autorisierte JavaScript-Origin des OAuth-Web-Clients, ohne Pfad."
  value       = module.https_frontend.url
}

output "certificate_name" {
  description = "Name fuer die Kontrolle der Zertifikatsausstellung."
  value       = module.https_frontend.certificate_name
}

output "cloud_run_service_name" {
  description = "Cloud-Run-Service fuer Diagnose und Log-Abfragen."
  value       = module.cloud_run.service_name
}

output "bucket_name" {
  description = "Privater Ergebnis-Bucket."
  value       = module.storage.bucket_name
}

output "bigquery_table" {
  description = "Vollstaendige Referenz der Ergebnistabelle."
  value       = module.bigquery.table_reference
}

output "session_secret_version" {
  description = "Verwendete Secret-Versionsnummer, niemals der Geheimwert."
  value       = google_secret_manager_secret_version.session.version
}
