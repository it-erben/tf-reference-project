variable "project_id" {
  description = "Projekt des HTTPS-Frontends."
  type        = string
}
variable "region" {
  description = "Region der Serverless NEG, identisch zum Cloud-Run-Service."
  type        = string
}
variable "name_prefix" {
  description = "Namenspraefix fuer Load-Balancer-Ressourcen."
  type        = string
}
variable "domain" {
  description = "Oeffentlicher DNS-Hostname fuer das verwaltete Zertifikat."
  type        = string
}
variable "service_name" {
  description = "Name des bereits definierten Cloud-Run-Service."
  type        = string
}
