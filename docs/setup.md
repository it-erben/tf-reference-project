# Cloud Shell und Projekt vorbereiten

## Voraussetzungen

Du brauchst ein vorhandenes GCP-Projekt mit aktiver Abrechnung und ausreichenden
Verwaltungsrechten für die Übung. Dazu zählen APIs aktivieren, Service Accounts
und deren IAM-Zuweisungen verwalten sowie Cloud Run, Compute-Load-Balancing,
Storage, BigQuery und Secret Manager anlegen. In einem persönlichen
Übungsprojekt kann das Projektinhaberkonto diese Aufgaben übernehmen. Der
spätere Laufzeit-Service-Account erhält nur die in `iam.tf` aufgeführten Rollen.

Du brauchst außerdem Zugriff auf die DNS-Einträge deiner Domain oder einer
Subdomain. Organisationseinstellungen können öffentliche Dienste oder einzelne
APIs einschränken; solche Vorgaben müssen vor der Übung mit dem
Projektverantwortlichen geklärt sein.

Öffne Cloud Shell und prüfe Konto und Projekt:

```sh
gcloud auth list
export TRAINING_PROJECT_ID="deine-projekt-id"
gcloud config set project "$TRAINING_PROJECT_ID"
terraform version
```

Cloud Shell stellt die Google-Anmeldung bereit. Es wird keine
Service-Account-Schlüsseldatei benötigt. Prüfe, dass du tatsächlich im eigenen
Übungsprojekt arbeitest.

Terraform muss mindestens Version 1.11 und kleiner als 2 sein; lokal geprüft
wurde 1.15.7. Falls eine Installation nötig ist, verwende
die [offiziellen Terraform-Pakete](https://developer.hashicorp.com/terraform/install)
beziehungsweise
die [Binärdateien für 1.15.7](https://releases.hashicorp.com/terraform/1.15.7/).

## TFLint installieren

```sh
mkdir -p "$HOME/.local/bin"
mkdir -p /tmp/tflint-0.64.0
cd /tmp/tflint-0.64.0
curl -fSLO https://github.com/terraform-linters/tflint/releases/download/v0.64.0/tflint_linux_amd64.zip
curl -fSLO https://github.com/terraform-linters/tflint/releases/download/v0.64.0/checksums.txt
sha256sum --check --ignore-missing checksums.txt
unzip -o tflint_linux_amd64.zip tflint -d "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"
tflint --version
```

Arbeite danach wieder im entpackten Projektordner. Die PATH-Ergänzung gilt für
diese Shell-Sitzung. Das Google-Regelwerk wird durch `make check` in der in
`.tflint.hcl` festgelegten Version installiert.

## State-Bucket einmalig anlegen

Dieser Bucket liegt außerhalb des Anwendungs-Stacks und wird zuletzt separat
entfernt. Verwende für diese Übung einen eigenen Bucket

```sh
gcloud services enable serviceusage.googleapis.com storage.googleapis.com --project="$TRAINING_PROJECT_ID"
gcloud storage buckets create "gs://${TRAINING_PROJECT_ID}-tfstate" \
  --project="$TRAINING_PROJECT_ID" \
  --location=europe-west1 \
  --uniform-bucket-level-access \
  --public-access-prevention
gcloud storage buckets update "gs://${TRAINING_PROJECT_ID}-tfstate" --versioning
```

Falls der Name bereits belegt ist, wähle einen eigenen global eindeutigen Namen
und verwende ihn in `backend.hcl`. Object Versioning hält frühere State-Stände
vor.

## Eigene Konfiguration

Im Projektordner:

```sh
cp terraform.tfvars.example terraform.tfvars
cp backend.hcl.example backend.hcl
```

Trage in `terraform.tfvars` mindestens Projekt-ID, DNS-Hostname und die eigene
OAuth-Web-Client-ID ein. Die [Google-Anmeldung](dns-and-login.md) beschreibt
deren Einrichtung.

In `backend.hcl` stehen dein State-Bucket und ein neuer, eindeutiger Prefix. Die
Beispieldatei verwendet `terraform/gemini-reference`. 

`terraform.tfvars` und `backend.hcl` sind persönliche Dateien und werden von Git
ausgeschlossen. Die Provider-Lockdatei und die Beispieldateien werden
versioniert.

## Prüfen und deployen

```sh
make check
terraform init -backend-config=backend.hcl
terraform plan -out=deploy.tfplan
terraform show deploy.tfplan
terraform apply deploy.tfplan
terraform output
```

Lies den Plan vor dem Anwenden!
