output "ip_address" {
  description = "Feste IPv4-Adresse fuer den oeffentlichen A-Record."
  value       = google_compute_global_address.app.address
}
output "url" {
  description = "Oeffentliche HTTPS-Adresse."
  value       = "https://${var.domain}"
}
output "certificate_name" {
  description = "Name fuer die Zertifikatsdiagnose."
  value       = google_compute_managed_ssl_certificate.app.name
}
