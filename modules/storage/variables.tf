variable "project_id" {
  description = "Projekt für den Ergebnis-Bucket."
  type        = string
}
variable "location" {
  description = "Standort des Buckets."
  type        = string
}
variable "bucket_name" {
  description = "Global eindeutiger Bucketname."
  type        = string
}
variable "labels" {
  description = "Gemeinsame Ressourcenlabels."
  type        = map(string)
  default     = {}
}
variable "allow_data_deletion" {
  description = "Erlaubt beim Abbau das Leeren des Buckets."
  type        = bool
  default     = false
}
