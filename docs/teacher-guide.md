# Lehrerhandbuch

## Was du brauchst
- **Einen Linux-Rechner** als Host für das Lab (ein altes Notebook oder ein kleiner VPS): Docker Engine und Docker Compose v2.
- Für 4 Boxen: als praktische Schätzung mindestens **2 vCPU und 4 GB RAM** (jede Box ist in der `compose.yaml` auf 512 MB und 0,5 CPU begrenzt). Das sind Richtwerte, miss den tatsächlichen Verbrauch mit `docker stats`.
- Für jeden Freund: ein SSH-Programm (`ssh` gibt es unter Linux, macOS und Windows 10+), und **ab Session 6** Docker auf seinem eigenen Rechner.

## Starten
```bash
git clone https://github.com/ah-alkhalaf/Docker-lernen.git && cd Docker-lernen
cp .env.example .env       # optional: feste Passwörter oder SSH-Schlüssel
make up
make passwords             # die zufällig erzeugten Passwörter
```
Freund Nummer N meldet sich an mit: `ssh -p 220N student@HOST-ADRESSE` (der erste 2201, der zweite 2202, ...).

## Einen fünften Freund hinzufügen
Kopiere den Block `box-4` in der `compose.yaml` und nenne ihn `box-5`. Ändere dann **vier Dinge**: den Namen, den Hostnamen, den Port (`2205`) und den Volume-Namen (und trage ihn unten im Abschnitt `volumes:` ein), dazu die `BOX5_*`-Variablen in `.env`. Danach `docker compose up -d`.

## Zugriff aus dem Internet
**Öffne die SSH-Ports der Boxen nicht mit Passwörtern ins offene Internet.** Bessere Alternativen: ein privates Netz (WireGuard oder Tailscale), oder die Sessions vor Ort im lokalen Netz. Du kannst in `.env` auch `BIND_ADDR=127.0.0.1` setzen, damit nur der Rechner selbst zugreift.

## Sicherheit: Was geschützt ist und was nicht
- Die Boxen sind **gewöhnliche Docker-Container**, und `root` darin ist nicht so stark isoliert wie in einer VM. Wir haben das abgemildert mit `cap_drop: ALL` und nur den nötigsten Capabilities, mit Ressourcengrenzen pro Box, ohne `--privileged` und ohne `docker.sock`.
- Der Benutzer `student` hat volles `sudo` (nötig, um Benutzer und Rechte zu lernen). Deshalb ist dieses Lab **für Freunde, denen du vertraust**, und nicht für Fremde.
- `no-new-privileges` ist bewusst nicht gesetzt, weil es `sudo` kaputtmacht.
- Für stärkere Isolation (und um systemd und Docker in der Box zu üben) siehe [`sysbox.md`](sysbox.md).

## Vorgeschlagener Zeitplan
| Woche | Session | Ort |
|---|---|---|
| 1 | [01 Linux-Grundlagen](../sessions/01-linux-basics.md) | Box |
| 2 | [02 Text und Pipes](../sessions/02-text-and-pipes.md) | Box |
| 3 | [03 Benutzer und Rechte](../sessions/03-users-and-permissions.md) | Box |
| 4 | [04 Prozesse und cron](../sessions/04-processes-and-cron.md) | Box |
| 5 | [05 Netzwerke und Skripte](../sessions/05-networking-and-scripts.md) | Zwei Boxen |
| 6 | [06 Docker und Compose](../sessions/06-docker-and-compose-basics.md) | Rechner des Freundes |
| 7 | [07 Stack, Git und CI](../sessions/07-full-stack-git-ci.md) | Rechner des Freundes |
| 8 | [08 Break/Fix](../sessions/08-break-fix.md) | Rechner des Freundes |

Für echte Anfänger: nicht mehr als **eine Session pro Woche**, und wiederhole Session 2 ruhig, denn die Pipes entscheiden darüber, wer dranbleibt.

## Wartung der Boxen
| Aufgabe | Befehl |
|---|---|
| Eine Box zurücksetzen (löscht ihren Fortschritt) | `docker compose rm -sf box-1 && docker volume rm docker-lernen-lab_home-box-1 && docker compose up -d box-1` |
| Image nach Änderungen an `Dockerfile` oder `lab/` aktualisieren | `docker compose up -d --build` (alte Boxen behalten ihre Dateien, weil das Home in einem Volume liegt) |
| Aufgaben einer bestehenden Box ändern | Lösche darin `~/.lab-initialized` und starte sie neu (erzeugt neue Aufgaben) |
| Alles stoppen und den Fortschritt behalten | `make down` |

## Fehlersuche
- **Warnung `REMOTE HOST IDENTIFICATION HAS CHANGED`** nach dem Neubau einer Box: Die SSH-Hostschlüssel werden neu erzeugt. Beim Freund: `ssh-keygen -R "[HOST]:2201"`.
- **`Operation not permitted` in der Box:** Es fehlt eine Capability wegen `cap_drop: ALL`. Lies die Meldung und ergänze die passende Capability unter `cap_add` in der `compose.yaml`.
- **`chmod` meldet Erfolg, aber das setgid-Bit fehlt** (Session 3): Dem root im Container fehlt `CAP_FSETID`, und dann verwirft der Kernel S_ISGID, wenn der Aufrufer nicht in der Gruppe der Datei ist. Lösung im Unterricht: `sudo -u deploy chmod 2775 /srv/startup`. Das ist ein gutes Beispiel dafür, dass ein Exit-Code von 0 nicht dasselbe ist wie ein geprüftes Ergebnis.
- **Die Box startet nicht:** `docker compose logs box-1`, und suche die letzte Zeile vor dem Abbruch.
- **Passwort vergessen:** `make passwords`, oder in `.env` setzen und dann `docker compose up -d --force-recreate box-1`.
- **Port 2201 belegt:** Ändere den Port in der `compose.yaml`.

## Was wurde tatsächlich getestet?
Siehe den Abschnitt "Was getestet ist" in der [`README.md`](../README.md).
