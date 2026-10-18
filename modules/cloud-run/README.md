# Modul cloud-run

Legt genau einen Cloud-Run-Service für die Demo an. Es verwendet einen bereits definierten Runtime-Service-Account; dessen Berechtigungen verwaltet das Root-Modul.

| Eingabe                                | Bedeutung                                                           |
|----------------------------------------|---------------------------------------------------------------------|
| `project_id`, `region`, `service_name` | Projekt, Standort und Name                                          |
| `container_image`                      | Bereitzustellendes Image                                            |
| `service_account_email`                | Bestehende Laufzeitidentität                                        |
| `env_vars`                             | Normale Werte als `map(string)`                                     |
| `secret_env_vars`                      | Referenzen als `map(object({ secret = string, version = string }))` |
| `max_instances`                        | Obergrenze, standardmäßig 2                                         |
| `labels`                               | Gemeinsame Ressourcenlabels                                         |

Die Outputs `service_name`, `uri` und `id` referenzieren den tatsächlich definierten Service. `uri` ist durch die Ingress-Regel nicht direkt aus dem Internet nutzbar. Externe Anfragen kommen über den Load Balancer; den Benutzerlogin übernimmt die App.

Der Container verwendet Port 8080, 1 CPU, 512 MiB und vier gleichzeitige Requests. Er skaliert auf null zurück. Diese Werte könnte man ebenfalls konfigurierbare machen.
