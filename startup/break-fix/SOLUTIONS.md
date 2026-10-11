# Die Lösungen (für den Lehrer, oder nach dem eigenen Versuch!)

Jede Lösung beginnt mit dem **Symptom**, dann der **Diagnose**, dann **Ursache** und **Behebung**.

## 01: Falscher Hostname
- **Diagnose:** `docker compose --project-directory . -f break-fix/01-wrong-hostname.yaml logs app` zeigt eine Zeile wie `health check failed: could not translate host name "database" to address`.
- **Ursache:** `DATABASE_URL` zeigt auf den Host `database`, der Dienst heißt aber `db`. Die Dienstnamen sind die DNS-Namen im Compose-Netzwerk. Die Verbindung zur Datenbank scheitert → `/health` liefert 503 → `app` wird nicht healthy → `caddy` startet nicht, weil es auf `service_healthy` wartet.
- **Behebung:** Ändere `@database:5432` zu `@db:5432`.

## 02: Healthcheck auf dem falschen Port
- **Diagnose:** Die Logs sind in Ordnung, das Problem liegt also im **Healthcheck selbst**: `docker inspect --format '{{json .State.Health.Log}}' startup-app-1` zeigt `Connection refused` auf Port 5000.
- **Ursache:** Die Anwendung lauscht auf **8000** (siehe `CMD` in `app/Dockerfile`), der `healthcheck` prüft aber `localhost:5000`.
- **Behebung:** `http://localhost:8000/health`.
- **Die Lektion:** Ein falscher Healthcheck tötet einen gesunden Dienst. Auch ein Healthcheck ist Code und gehört getestet.

## 03: Bad Gateway (502)
- **Diagnose:** `docker compose ... logs caddy` zeigt `dial tcp ...: connect: connection refused` mit dem Ziel `app:5000`.
- **Ursache:** `break-fix/Caddyfile.03` leitet an `app:5000` weiter, der richtige Port ist 8000.
- **Behebung:** `reverse_proxy app:8000`, dann `docker compose ... restart caddy`.
- **Die Lektion:** "Alles grün" heißt nicht, dass alles stimmt. Healthchecks decken nicht jeden Pfad ab.

## 04: Port-Kollision
- **Diagnose:** Die Meldung nennt den Port 8080 ausdrücklich. Such danach: `grep -n 8080 break-fix/04-port-clash.yaml`.
- **Ursache:** `caddy` und `uptime-kuma` veröffentlichen beide auf dem Host-Port 8080 (`${HTTP_PORT:-8080}`).
- **Behebung:** Gib Uptime Kuma `"3001:3001"`.
- **Die Lektion:** Ein Host-Port wird nur einmal vergeben, ein Container-Port darf dagegen in verschiedenen Containern derselbe sein.

## 05: Die Passwort-Falle (von Hand)
- **Diagnose:** `docker compose logs db` zeigt fehlgeschlagene Anmeldungen, und `logs app` zeigt `password authentication failed for user "startup"`.
- **Ursache:** Das Postgres-Image liest `POSTGRES_PASSWORD` **nur ein einziges Mal**, beim ersten Initialisieren des Datenverzeichnisses. Danach liegt es gespeichert im Volume, und eine Änderung in `.env` ändert daran nichts.
- **Behebung (ohne Datenverlust):** Trage den alten Wert wieder in `.env` ein. Oder ändere das Passwort in der Datenbank selbst und passe `.env` daran an:
  `docker compose exec db psql -U startup -c "ALTER USER startup PASSWORD 'das_neue';"`
- **Behebung (mit Datenverlust):** `docker compose down -v`, dann `up -d`. Nur benutzen, wenn die Daten wertlos sind!
- **Die Lektion:** Es gibt Einstellungen, die ein Image nur bei der ersten Initialisierung liest und danach im Volume ablegt.

---
> Hinweis zur Ehrlichkeit: Die Szenarien 01-04 entstehen durch zwei geänderte Zeilen in der heilen Datei, und wir haben geprüft, dass ihre Änderungen angewendet und die YAML-Dateien gültig sind. Die **genauen Symptome** (der exakte Wortlaut der Meldungen) hängen aber von deiner Docker-Version ab, wundere dich also nicht über eine leicht abweichende Formulierung.
