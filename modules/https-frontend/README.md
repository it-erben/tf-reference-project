# Modul https-frontend

Stellt genau einen Cloud-Run-Service über einen globalen externen Application Load Balancer bereit. Dazu gehören eine feste IPv4-Adresse, eine Serverless NEG in der Cloud-Run-Region, das HTTPS-Frontend und ein Google-verwaltetes Zertifikat. Ein separates HTTP-Frontend leitet auf HTTPS weiter und erhält Pfad und Query.

| Eingabe        | Bedeutung                                 |
|----------------|-------------------------------------------|
| `project_id`   | Projekt mit aktivierter Compute-API       |
| `region`       | Dieselbe Region wie der Cloud-Run-Service |
| `name_prefix`  | Kurzer Präfix für die Ressourcen          |
| `domain`       | DNS-Hostname des Zertifikats              |
| `service_name` | Cloud-Run-Servicename aus dessen Output   |

Outputs sind `ip_address`, `url` und `certificate_name`.

Die Domain muss beim DNS-Anbieter auf die ausgegebene IP zeigen. Das Modul verwaltet weder externe DNS-Einträge noch OAuth-Clients.
