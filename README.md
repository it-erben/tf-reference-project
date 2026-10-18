# Referenzprojekt

Übungsstack für Teilnehmer mit Terraform-Grundlagen.

Die Anwendung meldet Nutzer über Google an, erzeugt Gemini-Antworten und speichert Ergebnisse wahlweise in einem privaten Cloud-Storage-Bucket oder einer BigQuery-Tabelle. Eine feste IP und ein HTTPS-Load-Balancer stellen den öffentlichen Zugang bereit.

## Aufbau

| Baustein                                           | Zuständigkeit                                                       |
|----------------------------------------------------|---------------------------------------------------------------------|
| Root-Modul                                         | APIs, Runtime-Service-Account, IAM, Session-Secret und Wiring       |
| [cloud-run](modules/cloud-run/README.md)           | Container, Secret-Referenzen, Ingress und Skalierung                |
| [https-frontend](modules/https-frontend/README.md) | Feste IP, Load Balancer, Zertifikat und HTTP-Weiterleitung          |
| [storage](modules/storage/README.md)               | Privater Ergebnis-Bucket                                            |
| [bigquery](modules/bigquery/README.md)             | Dataset und Ergebnistabelle                                         |

## Lokale Tests

```sh
make check
```

Dies führt Backend-freie Initialisierung, Formatprüfung, Validierung, TFLint und neun Terraform-Tests aus. Die Google-API wird in den Tests gemockt. Die Einzelbefehle stehen im [Setup](docs/setup.md).
