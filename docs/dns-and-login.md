# Eigene Domain, HTTPS und Google-Anmeldung

## DNS beim vorhandenen Anbieter einrichten

Verwende beispielsweise `gemini.meine-domain.de` als `lb_domain`. Du benötigst
Zugriff auf die DNS-Zone; ein Domainkauf oder ein Wechsel zu Cloud DNS ist nicht
erforderlich.

Nach dem Apply:

```sh
terraform output dns_record
terraform output -raw load_balancer_ip
```

Lege beim DNS-Anbieter einen A-Record für den gewählten Hostnamen an. Als Wert
dient exakt die ausgegebene IPv4-Adresse. Manche Oberflächen erwarten nur
`gemini` und ergänzen `meine-domain.de` automatisch; andere erwarten den
vollständigen Namen. Bei der Domainwurzel wird häufig `@` verwendet.
Kontrolliere den angezeigten vollständigen Namen.

Für diesen IPv4-Aufbau ist kein AAAA-Record nötig. Entferne für genau diesen
Hostnamen widersprüchliche A-, AAAA- oder CNAME-Einträge. Andere Dienste der
Domain bleiben unberührt. Falls der Anbieter einen HTTP-Proxy oder CDN-Modus
anbietet, verwende für die Übung die reine DNS-Auflösung, bei Cloudflare
beispielsweise „DNS only“.

Ein Nameserver-Wechsel ist nur nötig, wenn du die DNS-Verwaltung bewusst zu
einem anderen Anbieter umziehst. Für den beschriebenen A-Record brauchst du ihn
nicht.

```sh
export APP_HOST="$(terraform output -raw oauth_javascript_origin)"
APP_HOST="${APP_HOST#https://}"
dig +short "$APP_HOST" A
dig +short "$APP_HOST" AAAA
```

Die A-Response muss jetzt die Load-Balancer-IP liefern; eine abweichende
AAAA-Antwort ist hier ein Fehler. Bei Zweifeln ermittle beim Anbieter den
autoritativen Nameserver und frage ihn direkt ab:

```sh
dig @ns1.dein-dns-anbieter.de "$APP_HOST" A +noall +answer
```

## Zertifikat prüfen

Terraform legt das verwaltete Zertifikat an und bindet es an den HTTPS-Proxy.
Google stellt es aus, sobald Domain und Load Balancer korrekt sichtbar sind.

```sh
gcloud compute ssl-certificates describe "$(terraform output -raw certificate_name)" \
  --global --project="$TRAINING_PROJECT_ID" \
  --format='yaml(managed.status,managed.domainStatus)'
```

Warte auf `ACTIVE` für Zertifikat und Domain. DNS-Änderungen werden abhängig von
TTL und Caches sichtbar; Google nennt für die weltweite Verteilung im
Ausnahmefall bis zu 72 Stunden. Nach der Verteilung kann die
Zertifikatsausstellung nochmals bis zu 60 Minuten benötigen. Wiederholtes
Terraform-Apply beschleunigt diese Prüfung nicht.

| Status oder Symptom                | Zuerst prüfen                                                               |
|------------------------------------|-----------------------------------------------------------------------------|
| `PROVISIONING`                     | DNS-Auflösung und Zeit seit der Änderung                                    |
| `FAILED_NOT_VISIBLE`               | A/AAAA-Ziele, aktive Forwarding Rule auf Port 443 und vorgeschaltete Proxys |
| `FAILED_CAA_FORBIDDEN`             | Ob bestehende CAA-Regeln Googles verwendete Zertifizierungsstellen zulassen |
| Browser meldet falsches Zertifikat | Hostname, DNS-Ziel und Zertifikatsstatus                                    |

Lösche CAA-Regeln nicht pauschal. Prüfe
die [Google-Anleitung zu verwalteten Zertifikaten](https://docs.cloud.google.com/load-balancing/docs/ssl-certificates/google-managed-certs)
und passe nur die erforderliche Freigabe an.

## Google Auth Platform

Öffne Google Auth Platform im Teilnehmerprojekt. Richte die für das Projekt
erforderlichen Angaben zu Branding, Audience und Kontaktadresse ein und erstelle
einen OAuth-Client vom Typ „Webanwendung“.

Unter „Autorisierte JavaScript-Quellen“ trägst du die öffentliche HTTPS-Origin
ohne Pfad ein:

```text
https://gemini.meine-domain.de
```

Du kannst sie auch über `terraform output -raw oauth_javascript_origin` lesen.
Die Client-ID mit der Endung `.apps.googleusercontent.com` gehört in
`google_oauth_client_id`.

Die App verwendet Google Identity Services mit Popup und ID-Token-Prüfung. Sie
benötigt weder ein OAuth-Client-Secret noch eine OAuth-Redirect-URI.
`/auth/callback` ist ein interner POST-Endpunkt, an den der Browser das ID-Token
sendet. Trage ihn nicht als erforderliche OAuth-Redirect-URI ein.

Der Session-Geheimwert wird unabhängig davon durch Terraform in Secret Manager
erzeugt. Verwechsle ihn nicht mit OAuth-Zugangsdaten.

Die App besitzt keine eigene Benutzerfreigabeliste. Eine erfolgreiche
Google-Anmeldung erlaubt die App-Nutzung; alle angemeldeten Nutzer teilen diese
Ergebnisdaten. Eine auf Teilnehmer beschränkte Autorisierung wird hier nicht
ergänzt. Verwende die Installation als zeitlich begrenzte Übung mit passenden
Daten.

Details zum tatsächlich verwendeten Verfahren stehen
im [festgelegten Anwendungscode](https://github.com/it-erben/cloud-run-gemini-demo/tree/62bbde19c148f53d438540655171d73bcaf9c9d5#google-anmeldung).
