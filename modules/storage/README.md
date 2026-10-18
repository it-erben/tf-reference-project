# Modul storage

Legt einen privaten Ergebnis-Bucket an. Uniform Bucket-Level Access steuert die Zugriffe über IAM; Public Access Prevention ist aktiviert.

| Eingabe                                 | Bedeutung                                                        |
|-----------------------------------------|------------------------------------------------------------------|
| `project_id`, `location`, `bucket_name` | Projekt, Standort und global eindeutiger Name                    |
| `labels`                                | Gemeinsame Ressourcenlabels                                      |
| `allow_data_deletion`                   | Standardmäßig `false`; erlaubt beim Abbau das Leeren des Buckets |

Die Outputs heißen `bucket_name` und `id`.
