# Funktionstest, Betrieb und Aufräumen

## Funktionstest nach der Bereitstellung

Prüfe zuerst, dass das Zertifikat `ACTIVE` ist. Anschließend:

```sh
export APP_URL="$(terraform output -raw load_balancer_url)"
curl --head "${APP_URL/https:/http:}"
curl --fail --silent --show-error "$APP_URL/healthz"
```

Die HTTP-Anfrage muss auf HTTPS umgeleitet werden. `/healthz` meldet die Erreichbarkeit der Anwendung; der Endpunkt prüft weder Gemini noch die Datenspeicher.

Öffne die HTTPS-Adresse im Browser und führe die tatsächlichen Funktionen aus:

1. Ohne Anmeldung ist nur die Anmeldeseite nutzbar.
2. Melde dich mit Google an und erzeuge eine kurze Gemini-Antwort.
3. Speichere das Ergebnis im Storage-Tab und kontrolliere die Objektliste.
4. Wechsle zum BigQuery-Tab, erzeuge und speichere eine Antwort und kontrolliere die Tabellenliste.
5. Melde dich ab und prüfe, dass die App erneut eine Anmeldung verlangt.

Prüfe außerdem den gesperrten direkten Internetzugang:

```sh
export RUN_URI="$(gcloud run services describe "$(terraform output -raw cloud_run_service_name)" \
  --region=europe-west1 --project="$TRAINING_PROJECT_ID" --format='value(status.url)')"
curl -i "$RUN_URI/healthz"
```

Führe diese Gegenprobe aus einem öffentlichen Netz aus, beispielsweise vom eigenen Rechner. Sie darf keine erfolgreiche Health-Antwort liefern. Interne Quellen werden durch die gewählte Ingress-Einstellung gesondert behandelt. Bei einer abweichenden Region passe die Diagnosebefehle an.

Nach dem Funktionstest:

```sh
terraform plan
```

Ohne Konfigurationsänderung soll der Plan keine Änderungen vorsehen. Insbesondere darf das Session-Secret nicht bei jedem Durchlauf rotiert werden. Das lässt sich verbindlich erst nach einem echten Apply prüfen.

## Diagnose

```sh
gcloud run services logs read "$(terraform output -raw cloud_run_service_name)" \
  --region=europe-west1 --project="$TRAINING_PROJECT_ID" --limit=30
```

| Fehlerbild                          | Ansatz                                                                       |
|-------------------------------------|------------------------------------------------------------------------------|
| Container startet nicht             | Startprotokoll, Image, Port 8080 und Zugriff auf die konkrete Secret-Version |
| Google-Anmeldung scheitert          | JavaScript-Origin, eigene Client-ID und Browserkonsole                       |
| Gemini scheitert                    | Vertex-API, Laufzeitrolle, Modellverfügbarkeit, Endpunkt und Quota           |
| Storage-Liste oder Upload scheitert | Tatsächlicher Bucketname und die beiden Bucket-Rollen                        |
| BigQuery-Speicherung scheitert      | Tabellenreferenz, Schema und Tabellenrolle                                   |
| BigQuery-Liste scheitert            | Zusätzlich projektweite `bigquery.jobUser`-Rolle und Abfragegrenze           |
| HTTPS scheitert                     | Zuerst DNS und Zertifikatsstatus prüfen                                      |

Die Anwendung begrenzt einzelne BigQuery-Listenabfragen bereits. Cloud-Run-Instanzlimits setzen jedoch keine feste Grenze für Gemini-, Abfrage- und Speicherkosten. Prüfe vor der Schulung die aktuellen [Cloud-Run-](https://cloud.google.com/run/pricing), [Load-Balancer-](https://cloud.google.com/vpc/network-pricing#lb), [Vertex-AI-](https://cloud.google.com/vertex-ai/generative-ai/pricing), [BigQuery-](https://cloud.google.com/bigquery/pricing) und [Storage-Preise](https://cloud.google.com/storage/pricing). Der Load Balancer und die feste IP bleiben auch bei null laufenden Cloud-Run-Instanzen angelegt. Budgetbenachrichtigungen sind Hinweise und keine garantierte Ausgabensperre.

## Session-Secret bewusst rotieren

Erhöhe `session_secret_rotation` in deiner `terraform.tfvars`, beispielsweise von 1 auf 2, und prüfe anschließend den Plan:

```sh
terraform plan -out=rotation.tfplan
terraform show rotation.tfplan
terraform apply rotation.tfplan
terraform output session_secret_version
```

Terraform erzeugt eine neue Secret-Version vor dem Entfernen der bisherigen. Cloud Run erhält die neue Versionsnummer und eine neue Revision. Während des Wechsels können unterschiedliche Sitzungsschlüssel aktiv sein; bestehende Sitzungen müssen neu angemeldet werden. Verwende einen steigenden Zähler und drehe ihn nicht nach dem Apply zurück.

Der Geheimwert steht weder in der tfvars-Datei noch im State oder Plan. Er wird bei Bedarf neu erzeugt und dauerhaft in Secret Manager gespeichert. Eine unveränderte Konfiguration aktualisiert ihn nicht.

## Übungsressourcen abbauen

Standardmäßig schützt `allow_data_deletion = false` die BigQuery-Tabelle. Ein gefüllter Ergebnis-Bucket wird nicht automatisch geleert. Für den vollständigen Abbau einschließlich Ergebnisdaten sind zwei bewusste Schritte nötig.

**Die folgenden Befehle erlauben und löschen die Übungsdaten dieser Installation.** Prüfe Projekt, Backend und Plan vor jedem Apply.

```sh
terraform plan -var='allow_data_deletion=true' -out=unlock.tfplan
terraform show unlock.tfplan
terraform apply unlock.tfplan
terraform plan -destroy -var='allow_data_deletion=true' -out=destroy.tfplan
terraform show destroy.tfplan
terraform apply destroy.tfplan
```

Das erste Apply aktualisiert die gespeicherten Schutzflags. Ein alleiniger `destroy`-Aufruf mit einer geänderten Variable ersetzt diesen Schritt nicht. Das Dataset wird nur entfernt, wenn es leer ist; zusätzlich manuell angelegte Tabellen werden nicht automatisch mitgelöscht. Die Projekt-APIs bleiben aktiviert.

Entferne anschließend den eigenen DNS-Eintrag und bereinige den OAuth-Client beziehungsweise dessen JavaScript-Origin. Terraform verwaltet diese extern vorbereiteten Einstellungen nicht.

## State-Bucket zuletzt entfernen

Vergewissere dich, dass der Stack vollständig abgebaut ist und dieser Bucket ausschließlich für diese Übung verwendet wurde. Prüfe seinen Inhalt einschließlich älterer Versionen:

```sh
gcloud storage ls --all-versions "gs://${TRAINING_PROJECT_ID}-tfstate/**"
```

Falls du nach Prüfung auch die State-Historie endgültig aufräumen möchtest:

```sh
gcloud storage rm --recursive "gs://${TRAINING_PROJECT_ID}-tfstate"
```

Dieser separate Befehl entfernt den Bucket mitsamt seinen Objektversionen. Er gehört nie vor den Terraform-Abbau. Falls du einen anderen Bucketnamen gewählt hast, verwende diesen. Ein konfiguriertes Soft-Delete-Fenster für Buckets oder Objekte kann Daten weiterhin vorhalten und Kosten verursachen; prüfe die Einstellungen von Ergebnis- und State-Bucket in der Storage-Konsole. Das GCP-Projekt und die Domain bleiben bestehen.
