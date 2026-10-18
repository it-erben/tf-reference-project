# Modul bigquery

Legt ein Dataset und genau eine Ergebnistabelle an. Die Tabelle erhält ein vom Aufrufer übergebenes JSON-Schema.

| Eingabe                  | Bedeutung                                                   |
|--------------------------|-------------------------------------------------------------|
| `project_id`, `location` | Projekt und Dataset-Standort                                |
| `dataset_id`, `table_id` | Einzelne IDs, ohne Projektpräfix                            |
| `schema`                 | BigQuery-Schema als JSON-String                             |
| `labels`                 | Gemeinsame Ressourcenlabels                                 |
| `allow_data_deletion`    | Standardmäßig `false`; schaltet den Tabellenlöschschutz aus |

Outputs sind `dataset_id`, `table_id` und `table_reference` im Format `Projekt.Dataset.Tabelle`.

Tabellenrechte und die projektweite `bigquery.jobUser`-Rolle werden im Root zugewiesen. Voraussetzung ist die aktivierte BigQuery-API.

Vor dem Abbau mit Übungsdaten muss `allow_data_deletion = true` zunächst angewendet werden. Das Dataset löscht zusätzliche, manuell angelegte Tabellen nicht automatisch mit; die Anleitung beschreibt den [bewussten Abbau](../../docs/operations.md).
