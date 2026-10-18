variable "project_id" {
  description = "Vorhandenes GCP-Projekt mit aktivierter Abrechnung."
  type        = string
}

variable "name_prefix" {
  description = "Kurzer Namenspräfix fuer die Ressourcen dieser Installation."
  type        = string
  default     = "gemini-demo"
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,18}[a-z0-9]$", var.name_prefix))
    error_message = "name_prefix muss 2 bis 20 kleine Buchstaben, Ziffern oder Bindestriche enthalten und mit einem Buchstaben beginnen."
  }
}

variable "region" {
  description = "Gemeinsamer Standort von Cloud Run, Ergebnis-Bucket und BigQuery."
  type        = string
  default     = "europe-west1"
}

variable "bucket_name" {
  description = "Optionaler global eindeutiger Bucketname; sonst aus Projekt und Präfix abgeleitet."
  type        = string
  default     = null
  validation {
    condition = var.bucket_name == null ? true : (
      length(var.bucket_name) >= 3 && length(var.bucket_name) <= 63 &&
      can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.bucket_name))
    )
    error_message = "bucket_name muss 3 bis 63 kleine Buchstaben, Ziffern oder Bindestriche enthalten; Anfang und Ende müssen alphanumerisch sein."
  }
}

variable "dataset_id" {
  description = "ID des BigQuery-Datasets mit den Ergebnissen."
  type        = string
  default     = "gemini_results"
  validation {
    condition     = length(var.dataset_id) <= 1024 && can(regex("^[A-Za-z0-9_]+$", var.dataset_id))
    error_message = "dataset_id darf nur Buchstaben, Ziffern und Unterstriche enthalten."
  }
}

variable "table_id" {
  description = "ID der Ergebnistabelle im Dataset."
  type        = string
  default     = "answers"
  validation {
    condition     = length(var.table_id) <= 1024 && can(regex("^[A-Za-z0-9_]+$", var.table_id))
    error_message = "table_id darf nur Buchstaben, Ziffern und Unterstriche enthalten."
  }
}

variable "lb_domain" {
  description = "Eigener öffentlicher DNS-Hostname, ohne Schema oder Pfad."
  type        = string
  validation {
    condition = (
      length(var.lb_domain) <= 253 &&
      can(regex("^([a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?\\.)+[a-z]{2,63}$", var.lb_domain))
    )
    error_message = "lb_domain muss ein kleingeschriebener DNS-Hostname ohne https://, Pfad oder abschließenden Punkt sein."
  }
}

variable "google_oauth_client_id" {
  description = "Web-Client-ID aus Google Auth Platform."
  type        = string
  validation {
    condition     = endswith(var.google_oauth_client_id, ".apps.googleusercontent.com")
    error_message = "Die Client-ID muss auf .apps.googleusercontent.com enden."
  }
}

variable "container_image" {
  description = "Container-Image mit explizitem sha-Commit-Tag oder SHA256-Digest."
  type        = string
  default     = "ghcr.io/it-erben/cloud-run-gemini-demo:sha-62bbde19c148f53d438540655171d73bcaf9c9d5"
  validation {
    condition     = can(regex("(@sha256:[a-f0-9]{64}|:sha-[a-f0-9]{40})$", var.container_image))
    error_message = "container_image muss mit @sha256:<64 Hexzeichen> oder :sha-<40 Hexzeichen> enden."
  }
}

variable "gemini_location" {
  description = "Gemini-Endpunkt"
  type        = string
  default     = "global"
}

variable "gemini_model" {
  description = "Gemini-Modell"
  type        = string
  default     = "gemini-3.1-flash-lite"
}

variable "session_secret_rotation" {
  description = "Nur für eine bewusste Rotation des Secrets erhöhen"
  type        = number
  default     = 1
  validation {
    condition     = var.session_secret_rotation >= 1 && floor(var.session_secret_rotation) == var.session_secret_rotation
    error_message = "session_secret_rotation muss eine positive ganze Zahl sein."
  }
}

variable "max_instances" {
  description = "Maximale Cloud-Run-Instanzen"
  type        = number
  default     = 2
  validation {
    condition     = var.max_instances >= 1 && floor(var.max_instances) == var.max_instances
    error_message = "max_instances muss eine positive ganze Zahl sein."
  }
}

variable "allow_data_deletion" {
  description = "Erlaubt die Löschung der angelegten Ressourcen"
  type        = bool
  default     = false
}
