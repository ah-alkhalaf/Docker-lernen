# Break/Fix-Szenarien

Vier kaputte Systeme, in jedem steckt genau ein eingebauter Fehler. Deine Aufgabe: **diagnostizieren und reparieren**, bis `./verify.sh` durchläuft (aus dem Verzeichnis `startup/`).

```bash
cd startup
cp .env.example .env
break-fix/run.sh up 01      # Szenario starten
break-fix/run.sh down 01    # stoppen, bevor du zum nächsten gehst
```

> Öffne [`SOLUTIONS.md`](SOLUTIONS.md) nicht, bevor du es ernsthaft versucht hast. Repariere, indem du die **Szenario-Datei** änderst (oder `Caddyfile.03`), nicht die originale `compose.yaml`.

| # | Datei | Symptom |
|---|---|---|
| 01 | `01-wrong-hostname.yaml` | `up -d` endet mit der Meldung, dass der Container `app` **unhealthy** ist, und auf `localhost:8080` läuft nichts. |
| 02 | `02-wrong-healthcheck.yaml` | Dasselbe Bild: `app` ist unhealthy. Aber die Logs von `app` sagen, dass gunicorn einwandfrei läuft! |
| 03 | `03-bad-gateway.yaml` | Alle Container sind `healthy`, aber der Browser zeigt **502 Bad Gateway**. |
| 04 | `04-port-clash.yaml` | `up -d` schlägt fehl mit einer Meldung über einen belegten Port (port is already allocated). |

## Szenario 05: Die Passwort-Falle (von Hand)
Dieser Fehler passiert auch Profis. Führe die Schritte der Reihe nach aus:
1. Starte den heilen Stack: `docker compose up -d --build` und prüfe, dass `./verify.sh` durchläuft.
2. Ändere `POSTGRES_PASSWORD` in `.env` auf einen neuen Wert.
3. `docker compose down`, dann `docker compose up -d` (ohne `-v`).
4. Warum ist `app` jetzt unhealthy, obwohl die Konfiguration "richtig" ist? Wie reparierst du das, ohne Daten zu verlieren?

## Allgemeine Tipps
```bash
docker compose ps
docker compose logs --tail 30 app
docker inspect --format '{{json .State.Health.Log}}' startup-app-1
docker compose exec app sh
```
