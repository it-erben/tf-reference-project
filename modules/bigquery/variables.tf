variable "project_id" {
  description = "Projekt für Dataset und Tabelle."
  type        = string
}
variable "location" {
  description = "Standort des Datasets."
  type        = string
}
variable "dataset_id" {
  description = "ID des Datasets."
  type        = string
}
variable "table_id" {
  description = "ID der Ergebnistabelle."
  type        = string
}
variable "schema" {
  description = "BigQuery-Tabellenschema als JSON."
  type        = string
}
variable "labels" {
  description = "Gemeinsame Ressourcenlabels."
  type        = map(string)
  default     = {}
}
variable "allow_data_deletion" {
  description = "Deaktiviert den Löschschutz der verwalteten Tabelle."
  type        = bool
  default     = false
}
