# Session 5: Netzwerke und bash-Skripte

**Dauer:** 2 Stunden · **Ort:** Zwei Boxen (box-1 und box-2) · **Voraussetzung:** Session 1-4

## Ziel
Der Freund versteht, wie zwei Rechner miteinander sprechen und wo die Verbindung scheitert, und automatisiert die Prüfung dann mit einem Skript. Das ist die Grundlage, um später Docker-Netzwerke zu verstehen.

## Die Idee in zwei Minuten
Für eine Verbindung brauchst du: eine **IP-Adresse** (wer?), einen **Port** (welcher Dienst?) und einen **Namen**, der über **DNS** zur IP wird. Ein Dienst, der auf `127.0.0.1` lauscht, ist nur auf seinem eigenen Rechner sichtbar, einer auf `0.0.0.0` für alle.

## Spickzettel

| Befehl | Was er tut |
|---|---|
| `ip a` / `ip r` | Adressen der Schnittstellen / Routing-Tabelle |
| `ss -tlnp` | Offene, lauschende Ports und wer dort lauscht |
| `ping -c 3 ziel` | Antwortet der Rechner? |
| `curl -v http://ziel:port` | Eine Seite abrufen und die Details sehen (`-I` nur Header) |
| `dig name` / `getent hosts name` | Namen in eine IP auflösen |
| `nc -zv ziel port` | Ist der Port offen? |
| `cat /etc/hosts /etc/resolv.conf` | Namensdateien und DNS-Server |

## Erst ausführen, dann verstehen
1. **Wer bin ich im Netz?** `ip a` (suche `eth0`), `hostname`, `cat /etc/resolv.conf`.
2. **Öffne einen Dienst** auf box-1:
   ```bash
   cd ~ && echo "hello from box-1" > index.html
   python3 -m http.server 8080 &
   ss -tlnp | grep 8080          # beachte: 0.0.0.0:8080
   curl http://localhost:8080
   ```
3. **Von box-2 aus** (ein anderer Rechner!): `curl http://box-1:8080`. Der Name `box-1` funktioniert, weil Docker für alle Boxen im Netzwerk DNS bereitstellt.
4. **Versuch zum Lauschen:** Stoppe den Dienst (`kill %1`) und starte ihn eingeschränkt neu: `python3 -m http.server 8080 --bind 127.0.0.1 &`.
   Teste von box-1 (geht) und von box-2 (geht nicht). Warum? Dieselbe Idee begegnet dir später bei Docker-Ports wieder.
5. **DNS kaputt machen:** `curl http://no-such-host.invalid`, und vergleiche mit der Meldung von `curl http://box-1:9999`. Zwei verschiedene Meldungen für zwei verschiedene Probleme: "Ich kenne den Namen nicht" gegen "Der Name ist bekannt, aber dort lauscht niemand".

## Aufgabe: Ein Healthcheck-Skript
Schreibe `~/healthcheck.sh`, das eine **URL** als erstes Argument nimmt, bei Erfolg `OK <url>` ausgibt und mit Code 0 endet, und bei Misserfolg `FAIL <url>` ausgibt und mit Code 1 endet.
```bash
#!/usr/bin/env bash
url="${1:?usage: healthcheck.sh URL}"
if curl -fsS -o /dev/null --max-time 3 "$url"; then
  echo "OK $url"
else
  echo "FAIL $url"
  exit 1
fi
```
Kopiere es nicht, bevor du versucht hast, es selbst zu schreiben. Danach `chmod +x ~/healthcheck.sh`.
Teste es: `./healthcheck.sh http://box-1:8080 ; echo "exit code: $?"`

## Prüfen
```bash
lab-check 5
```

## Fragen zur Diskussion
- Was ist der Unterschied zwischen `curl: (6) Could not resolve host` und `curl: (7) Failed to connect`?
- Warum ist der **Exit-Code** in der Automatisierung so wichtig? (Genau ihn lesen CI und Docker-Healthchecks.)
- Wo würdest du dieses Skript in deinem Projekt einsetzen? (Die Idee dahinter nutzt du gleich in den Healthchecks von Docker Compose.)

## Hinweise für den Lehrer
- Teile die Freunde in Paare: einer bietet den Dienst an, der andere verbindet sich.
- Häufiger Fehler: `chmod +x` vergessen, oder Leerzeichen um das `=` in bash.
