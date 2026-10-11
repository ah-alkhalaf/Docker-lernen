# Session 7: Der komplette Stack, Git, CI/CD und Monitoring

**Dauer:** 2,5 Stunden · **Ort:** Dein Rechner (Docker) · **Voraussetzung:** Session 6

## Ziel
Der Freund betreibt einen realistischen Stack (Reverse Proxy + Anwendung + Datenbank) mit getrennten Netzwerken und Healthchecks, bringt ihn mit **Continuous Integration** nach Git und überwacht ihn.

## Teil 1: Vergleiche deine Lösung mit der fertigen (20 Minuten)
Öffne [`startup/compose.yaml`](../startup/compose.yaml) und vergleiche sie mit dem, was du in Session 6 geschrieben hast. Was kommt dazu?
- `healthcheck` für `db` und `app` und `depends_on: condition: service_healthy`, also **warte, bis der Dienst bereit ist, nicht nur bis er gestartet ist**.
- Zwei Netzwerke: `frontend` und `backend`. Die Datenbank liegt nur in `backend`.
- Variablen in `.env` statt des Passworts in der Datei.
- `caddy` als Reverse Proxy vor der Anwendung, und als Einziges auf dem Host veröffentlicht.

## Teil 2: Starte ihn (30 Minuten)
```bash
cd startup
cp .env.example .env          # ändere POSTGRES_PASSWORD
docker compose up -d --build
docker compose ps             # warte auf healthy
./verify.sh                   # automatische Prüfung
# öffne http://localhost:8080
```
**Versuche, um zu verstehen, was passiert ist:**
```bash
docker compose exec caddy ping -c 1 app     # geht: dasselbe Netzwerk frontend
docker compose exec caddy ping -c 1 db      # geht nicht! die Datenbank ist von caddy isoliert
docker compose stop db
docker compose ps                            # app wird nach kurzer Zeit unhealthy
docker compose start db
```
**Backup und Wiederherstellung:**
```bash
docker compose exec -T db pg_dump -U startup startup > backup.sql
docker compose exec -T db psql -U startup startup -c "DROP TABLE visits;"
docker compose exec -T db psql -U startup startup < backup.sql
```
(`backup.sql` enthält deine Daten, lege sie also nicht in Git.)

## Teil 3: Git (30 Minuten)
1. Kopiere den Ordner `startup/` in einen neuen Ordner mit dem Namen deiner Firma und lege dort ein Repository an: `git init && git add . && git commit -m "first commit"`.
2. Lege auf GitHub ein Repository an und pushe dorthin (`git remote add origin ... && git push -u origin main`).
3. Stell sicher, dass `.env` **nicht** hochgeladen wird (die `.gitignore` verhindert das). Passwörter gehören nie in Git.
4. Lege einen Branch für ein neues Feature an: `git switch -c feature/new-page`, ändere `app.py` und führe es über einen Pull Request zusammen.

## Teil 4: Continuous Integration (30 Minuten)
CI heißt: Jeder `push` führt deine Tests automatisch aus. Lege `.github/workflows/ci.yml` in deinem Repository an:
```yaml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: { python-version: "3.12" }
      - run: pip install -r app/requirements-dev.txt
      - run: pytest -q
        working-directory: app
      - run: cp .env.example .env && docker compose build
```
Mach absichtlich einen Test kaputt (ändere `"memory"` in `tests/test_app.py`), pushe, und sieh dir das rote ❌ auf GitHub an. Repariere ihn dann und sieh das ✅.
Das größere Beispiel findest du in [`.github/workflows/ci.yml`](../.github/workflows/ci.yml) in diesem Repository.

## Teil 5: Deployment (CD) und Monitoring (20 Minuten)
- **CD** bedeutet, dass Code, der die CI bestanden hat, automatisch auf den Server kommt. Die einfachste Form: ein Skript `deploy.sh` auf dem Server, das Folgendes tut:
  ```bash
  git pull && docker compose up -d --build && ./verify.sh
  ```
  **Schreib es selbst** mit den Fertigkeiten aus Session 5 (Exit-Codes, `set -e`). Diskutiert dann: Wie wird es nach einem `push` automatisch ausgelöst? (Webhook, GitHub Actions über SSH, oder Werkzeuge wie ArgoCD.) Heute bauen wir das noch nicht.
- **Monitoring:**
  ```bash
  docker compose --profile monitoring up -d
  # öffne http://localhost:3001 und lege ein Konto an
  # füge einen Monitor vom Typ HTTP hinzu auf:  http://caddy/health
  docker compose stop app     # sieh dir die Benachrichtigung an!
  ```

## Fragen zur Diskussion
- Was ist der Unterschied zwischen `restart: unless-stopped` und `healthcheck`? (Das Erste startet den Container neu, wenn er stirbt, das Zweite erkennt, dass er "lebt, aber nicht arbeitet".)
- Warum veröffentlichen wir den Port der Datenbank nicht auf dem Host?
- Was hindert dich daran, kaputten Code in die Produktion zu pushen? (CI, Code-Review und getrennte Umgebungen.)

## Hinweise für den Lehrer
- Die längste Session: Git und CI lassen sich in eine eigene Session auslagern.
- Uptime Kuma verlangt beim ersten Öffnen ein Konto, das ist normal.
- Für Freunde ohne GitHub-Konto: Lege das Konto vor der Session an.
