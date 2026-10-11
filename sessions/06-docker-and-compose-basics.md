# Session 6: Docker und die erste Compose-Datei

**Dauer:** 2 Stunden · **Ort:** Dein eigener Rechner (oder ein Server mit Docker), nicht die Lab-Box · **Voraussetzung:** Session 1-5

> Du brauchst Docker auf deinem Rechner: unter Linux direkt, oder Docker Desktop (Windows/macOS), oder WSL2. `docker run --rm hello-world` muss vor Beginn der Session durchlaufen.

## Ziel
Der Freund versteht den Unterschied zwischen **Image** und **Container**, baut ein Image für eine Anwendung und schreibt seine erste `compose.yaml` selbst.

## Die Idee in zwei Minuten
- **Image**: eine Vorlage, nur lesbar (System + Programm + Konfiguration).
- **Container**: eine laufende Instanz des Images, von anderen isoliert und leicht wegzuwerfen.
- **Compose**: eine Datei, die **mehrere** Container mit ihren Netzwerken und Volumes beschreibt, sodass ein Befehl alles startet.
- Erinnerung an Session 5: Container in Compose erreichen sich über die **Dienstnamen** (so wie box-2 die box-1 erreicht hat).

## Spickzettel

| Befehl | Was er tut |
|---|---|
| `docker run -d --name web -p 8081:80 nginx:alpine` | Container starten (Port `Host:Container`) |
| `docker ps` / `docker ps -a` | Laufende Container / alle |
| `docker logs -f web` | Logs des Containers |
| `docker exec -it web sh` | In einen laufenden Container hineingehen |
| `docker stop web && docker rm web` | Stoppen und löschen |
| `docker build -t name .` | Image aus einem Dockerfile bauen |
| `docker compose up -d` | Alle Dienste starten (`--build` baut neu) |
| `docker compose ps` / `logs -f` / `down` | Status / Logs / Stoppen |

## Erst ausführen, dann verstehen
1. **Der erste Container:**
   ```bash
   docker run -d --name web -p 8081:80 nginx:alpine
   curl http://localhost:8081
   docker logs web
   docker exec -it web sh      # ls /usr/share/nginx/html, dann exit
   docker stop web && docker rm web
   ```
2. **Bau das Image der Anwendung** (aus dem Repo dieses Projekts):
   ```bash
   cd startup/app
   cat Dockerfile                    # lies es Zeile für Zeile
   docker build -t startup-app .
   docker run --rm -p 8000:8000 startup-app
   curl http://localhost:8000/health     # {"db":"memory","status":"ok"}
   ```
   Warum läuft die Anwendung ohne Datenbank? (Suche nach `DATABASE_URL` in `app.py`.)

## Aufgabe: Schreibe Compose selbst
Lege ein neues Verzeichnis `my-stack/` neben `startup/` an und schreibe darin eine `compose.yaml`, die startet:
- einen Dienst `db` aus dem Image `postgres:16-alpine` mit einem Passwort deiner Wahl und einem **benannten Volume**, damit die Daten nicht verloren gehen.
- einen Dienst `app`, gebaut aus `../startup/app`, veröffentlicht auf Port 8000, mit der Umgebungsvariable
  `DATABASE_URL=postgresql://postgres:dein_passwort@db:5432/postgres`.

Gerüst zum Start:
```yaml
services:
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_PASSWORD: ???
    volumes:
      - ???
  app:
    build: ???
    ports: ["8000:8000"]
    environment:
      DATABASE_URL: ???
volumes:
  ???:
```
Dann:
```bash
docker compose up -d --build
curl http://localhost:8000/health        # {"db":"up",...}
curl http://localhost:8000/api/visits    # wiederhole es: der Zähler steigt
docker compose down                      # ohne -v
docker compose up -d
curl http://localhost:8000/api/visits    # ist der Zähler noch da? warum?
```
Der erste Versuch kann scheitern, weil die Anwendung startet, bevor die Datenbank bereit ist. Das ist ein echtes Problem, und seine Lösung ist das Thema von Session 7.

## Fragen zur Diskussion
- Was passiert mit den Daten bei `docker compose down` gegenüber `docker compose down -v`?
- Warum schreiben wir `@db:5432` und nicht `@localhost:5432` in `DATABASE_URL`?
- Was ist der Unterschied zwischen `ports: "8000:8000"` und `expose`?

## Hinweise für den Lehrer
- Gib ihnen nicht die fertige Lösung. Session 7 beginnt mit dem Vergleich ihrer Lösungen mit [`startup/compose.yaml`](../startup/compose.yaml).
- Häufiger Fehler: YAML-Einrückung (zwei Leerzeichen, kein Tab) und `localhost` statt des Dienstnamens.
- Unter Windows mit WSL2: Die Befehle laufen in der WSL-Distribution, nicht nur in PowerShell.
