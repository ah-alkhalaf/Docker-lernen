# Session 4: Prozesse, Dienste und Zeitsteuerung

**Dauer:** 2 Stunden · **Ort:** Lab-Box · **Voraussetzung:** Session 1-3

## Ziel
Der Freund sieht, was auf dem Server läuft, stoppt, was gestoppt gehört, und plant seine wiederkehrenden Aufgaben. Das sind Grundfertigkeiten jedes Betriebsingenieurs.

## Die Idee in zwei Minuten
Jedes laufende Programm heißt **Prozess** und hat eine **PID**. Beendet wird über ein **Signal**: `TERM` (15) bittet höflich um Beendigung, `KILL` (9) beendet sofort und ohne Aufräumen. **cron** ist ein Dienst, der Befehle zu festgelegten Zeiten ausführt.

## Spickzettel

| Befehl | Was er tut |
|---|---|
| `ps aux` | Alle Prozesse (`ps aux \| grep name` zum Suchen) |
| `top` / `htop` | Live-Ansicht der Prozesse (`q` beendet) |
| `pgrep -af name` | Prozess über den Namen finden und seinen Befehl zeigen |
| `kill PID` / `kill -9 PID` | Höflich beenden / hart beenden |
| `pkill -f name` | Über den Namen beenden |
| `befehl &` / `jobs` / `fg` | Im Hintergrund starten / anzeigen / in den Vordergrund holen |
| `nohup befehl &` | Starten und beim Schließen des Terminals weiterlaufen lassen |
| `crontab -e` / `crontab -l` | Eigene Zeitplanung bearbeiten / anzeigen |

cron-Format: `Minute Stunde Tag Monat Wochentag Befehl`, Beispiel `*/5 * * * * /home/student/backup.sh` = alle 5 Minuten.

## Erst ausführen, dann verstehen
1. `ps aux | head`, dann `htop`. Wer ist PID 1?
2. Probiere den Hintergrund:
   ```bash
   sleep 300 &
   jobs
   ps aux | grep sleep
   kill %1
   ```
3. Der Unterschied zwischen den Signalen: starte `sleep 300 &`, dann `kill -15 PID`, und wiederhole das mit `kill -9 PID`.
4. Überfliege `man 5 crontab`, probiere dann `crontab -e` mit der Zeile `* * * * * date >> ~/cron-test.log` und warte eine Minute.

## Aufgabe
1. **Entlaufener Prozess:** In deiner Box läuft ein Skript namens `bad-job.sh`, das alle 5 Sekunden in `~/challenges/s4/bad-job.log` schreibt. Finde es und stoppe es (und überzeuge dich, dass es wirklich weg ist).
2. **Geplantes Backup:** Schreibe `~/backup.sh`, das den Ordner `~/startup` nach `~/backups/` packt, mit dem Datum im Namen, und mache es ausführbar.
   ```bash
   #!/usr/bin/env bash
   mkdir -p ~/backups
   tar czf ~/backups/startup-$(date +%F-%H%M).tar.gz -C ~ startup
   ```
3. Plane es mit `crontab -e` alle 5 Minuten ein.

## Prüfen
```bash
lab-check 4
```

## Fragen zur Diskussion
- Wann benutzt du `kill -9`? Und was verlierst du dabei?
- Was passiert mit einem cron-Job, wenn er fehlschlägt? Wo siehst du seine Ausgabe? (Tipp: hänge `>> ~/backup.log 2>&1` an.)
- Was ist der Unterschied zwischen einem Prozess und einem Dienst?

## Zu systemd
In der Standard-Box gibt es **kein systemd** (Container starten es normalerweise nicht). Auf echten Servern werden Dienste mit `systemctl status|start|stop|enable nginx` verwaltet und ihre Logs mit `journalctl -u nginx` gelesen. Wenn du live mit systemd üben willst, lies [`docs/sysbox.md`](../docs/sysbox.md).

## Hinweise für den Lehrer
- cron läuft minütlich, plane also 5 Minuten Wartezeit in der Session ein, damit sie die entstehende Datei sehen.
- Häufiger Fehler in cron: relative Pfade. Immer vollständige Pfade verwenden.
