# Docker-lernen 🐳

Ein praktisches Lab, um **Linux, Netzwerke, Docker Compose und DevOps-Methodik** an Freunde ohne Vorkenntnisse zu vermitteln, entlang eines Projekts, das von Session zu Session wächst: ein **fiktives Start-up**.

Jeder Freund bekommt seinen eigenen "Linux-Server" (einen Container, in den er sich per SSH einloggt) und lernt dort die Grundlagen anhand von Aufgaben, die ein Skript automatisch prüft. Danach überträgt er das Gelernte auf einen echten Stack (Caddy + Anwendung + PostgreSQL) mit Docker Compose, Git, CI, Healthchecks und Monitoring, und zum Abschluss steht eine Session, in der er **kaputte Systeme repariert**.

## Schnellstart (für den Lehrer)

```bash
git clone https://github.com/ah-alkhalaf/Docker-lernen.git && cd Docker-lernen
make up            # baut und startet 4 Boxen
make passwords     # die erzeugten Passwörter
```
Danach meldet sich der Freund an: `ssh -p 2201 student@HOST-ADRESSE`, und nach jeder Aufgabe zeigt ihm `lab-check N`, ob sie geklappt hat.
Alle Details im [Lehrerhandbuch](docs/teacher-guide.md).

## Die Sessions

| # | Thema | Automatische Prüfung |
|---|---|---|
| 1 | [Linux-Grundlagen: SSH, Navigation, Dateien](sessions/01-linux-basics.md) | `lab-check 1` |
| 2 | [Text und Pipes: grep, awk, find](sessions/02-text-and-pipes.md) | `lab-check 2` |
| 3 | [Benutzer, Gruppen und Rechte](sessions/03-users-and-permissions.md) | `lab-check 3` |
| 4 | [Prozesse, Signale und cron](sessions/04-processes-and-cron.md) | `lab-check 4` |
| 5 | [Netzwerke und bash-Skripte](sessions/05-networking-and-scripts.md) | `lab-check 5` |
| 6 | [Docker und die erste Compose-Datei](sessions/06-docker-and-compose-basics.md) | manuell |
| 7 | [Kompletter Stack, Git, CI/CD und Monitoring](sessions/07-full-stack-git-ci.md) | `startup/verify.sh` |
| 8 | [Repariere das kaputte System](sessions/08-break-fix.md) | `startup/verify.sh` |

Die Sessions 1-5 laufen in den Lab-Boxen. Die Sessions 6-8 laufen auf dem Rechner des Freundes (Docker nötig).

## Aufbau des Repositories

```
Docker-lernen/
├── Dockerfile              Image der Lab-Box (Ubuntu 24.04 + sshd + Werkzeuge)
├── compose.yaml            4 Boxen im Netzwerk labnet
├── .env.example            Passwörter und SSH-Schlüssel (optional)
├── Makefile                up / down / passwords / reset / test
├── lab/                    Skripte der Box: Aufgaben und lab-check
├── sessions/               Die acht Sessions (auf Deutsch)
├── startup/                Das "Start-up": Flask-Anwendung + Compose + Caddy
│   ├── app/                  Anwendung, Tests und Dockerfile
│   ├── compose.yaml          Der komplette Stack
│   ├── verify.sh             Automatische Prüfung des Stacks
│   └── break-fix/            Fehlerszenarien und ihre Lösungen
├── docs/                   Lehrerhandbuch und Sysbox-Notiz
└── .github/workflows/      CI
```

## Sicherheit in Kürze
Die Lab-Boxen sind gewöhnliche Container, und der Benutzer darin hat `sudo`. Deshalb: **nur für Freunde, denen du vertraust, und niemals offen im Internet**. Die Details und stärkere Isolationsoptionen stehen im [Lehrerhandbuch](docs/teacher-guide.md).

## Was getestet ist und was nicht

Das Repository ist in einer Umgebung **ohne Docker** entstanden, daher:

**Tatsächlich getestet:**
- Die Prüfskripte `lab-check` 1, 2, 3 und 5 mit richtigen und falschen Lösungen, und das Erzeugen der Aufgabendateien.
- Die Flask-Anwendung: 4 erfolgreiche Unit-Tests und der Start mit gunicorn (derselbe Befehl wie im Container).
- Die Gültigkeit aller YAML-Dateien (Compose und Break/Fix-Szenarien), dass jede Szenario-Änderung angewendet ist, und ein sauberes `shellcheck` über alle Skripte.

**Noch nicht getestet (zeigt sich beim ersten Lauf):**
- **Bauen und Starten des Lab-Images**, vor allem die Liste `cap_add` (eventuell fehlt eine Capability).
- `lab-check 4` (Prozesse und cron) in der echten Box.
- Der komplette Lauf von `startup/compose.yaml` und die Break/Fix-Szenarien (die Symptomtexte können je nach Docker-Version abweichen).
- **CI auf GitHub**: Dort wird das Image gebaut, gestartet und `sudo useradd` ausprobiert. Das ist ein nützlicher Selbsttest beim ersten `push`; schlägt er fehl, zeigt das Log die fehlende Capability.

## Lizenz
Noch nicht festgelegt. Wähle eine passende Lizenz (zum Beispiel MIT) und füge eine Datei `LICENSE` hinzu, bevor du das Repository öffentlich teilst.
