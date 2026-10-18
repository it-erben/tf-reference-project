variable "project_id" {
  description = "Projekt des Cloud-Run-Service."
  type        = string
}
variable "region" {
  description = "Region des Cloud-Run-Service."
  type        = string
}
variable "service_name" {
  description = "Name des Cloud-Run-Service."
  type        = string
}
variable "container_image" {
  description = "Bereitzustellendes Container-Image."
  type        = string
}
variable "service_account_email" {
  description = "Laufzeit-Service-Account; IAM-Zuweisungen erfolgen im aufrufenden Root."
  type        = string
}
variable "env_vars" {
  description = "Normale Umgebungsvariablen, ohne Geheimwerte."
  type        = map(string)
  default     = {}
  nullable    = false
}
variable "secret_env_vars" {
  description = "Secret-Referenzen als Umgebungsvariablen; ausschliesslich feste Versionsnummern."
  type        = map(object({ secret = string, version = string }))
  default     = {}
  nullable    = false
  validation {
    condition     = length(setintersection(toset(keys(var.env_vars)), toset(keys(var.secret_env_vars)))) == 0
    error_message = "Eine Umgebungsvariable darf nicht zugleich Klarwert und Secret-Referenz sein."
  }
  validation {
    condition     = alltrue([for ref in values(var.secret_env_vars) : can(regex("^[1-9][0-9]*$", ref.version))])
    error_message = "Secret-Referenzen brauchen eine positive Versionsnummer; latest ist nicht erlaubt."
  }
}
variable "max_instances" {
  description = "Maximale Instanzzahl"
  type        = number
  default     = 2
}
variable "labels" {
  description = "Gemeinsame Ressourcenlabels."
  type        = map(string)
  default     = {}
}
