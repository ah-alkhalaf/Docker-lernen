# Session 3: Benutzer, Gruppen und Rechte

**Dauer:** 2 Stunden · **Ort:** Lab-Box · **Voraussetzung:** Session 1 und 2

## Ziel
Der Freund versteht, wer im System was darf, und ändert Rechte bewusst. Das ist die Grundlage von Sicherheit in jeder DevOps-Umgebung.

## Die Idee in zwei Minuten
Jede Datei hat einen **Eigentümer** und eine **Gruppe**, und für drei Klassen werden Rechte vergeben: Eigentümer (u), Gruppe (g) und alle anderen (o).
Jede Klasse hat `r` lesen = 4, `w` schreiben = 2 und `x` ausführen = 1.
```
-rwxr-x---   ← Eigentümer: rwx (7), Gruppe: r-x (5), andere: --- (0)  =  750
```

## Spickzettel

| Befehl | Was er tut |
|---|---|
| `ls -l` | Eigentümer, Gruppe und Rechte anzeigen |
| `id` / `whoami` / `groups` | Wer bin ich? In welchen Gruppen? |
| `chmod 750 datei` / `chmod u+x datei` | Rechte ändern (numerisch / symbolisch) |
| `chown benutzer:gruppe datei` | Eigentümer und Gruppe ändern |
| `sudo befehl` | Befehl mit Administratorrechten (root) ausführen |
| `sudo useradd -m name` | Benutzer anlegen (mit Home-Verzeichnis) |
| `sudo groupadd name` | Gruppe anlegen |
| `sudo usermod -aG gruppe benutzer` | Benutzer zu einer Gruppe hinzufügen (**-a** ist wichtig!) |
| `su - benutzer` | Zu einem anderen Benutzer wechseln |

## Erst ausführen, dann verstehen
1. `ls -l /etc/passwd /etc/shadow`. Warum darf jeder die erste Datei lesen und nur root die zweite?
2. Rechte in Aktion:
   ```bash
   echo 'echo hallo' > ~/test.sh
   ./test.sh          # Permission denied
   chmod +x ~/test.sh
   ls -l ~/test.sh
   ```
3. Lege einen Benutzer an: `sudo useradd -m alice`, dann `sudo -u alice cat ~/test.sh`. Warum schlägt das fehl? (Die Rechte auf `~` zählen auch.)
4. Der klassische Fehler: `sudo usermod -G devs alice` statt `-aG` löscht alle anderen Gruppen des Benutzers! Lies `man usermod` zu `-a`.

## Aufgabe: Das Deploy-Verzeichnis einrichten
Jedes Start-up hat ein Verzeichnis, aus dem der Dienst veröffentlicht wird. Richte Folgendes ein:
1. Benutzer `deploy` und Gruppe `devs`, und `deploy` ist Mitglied von `devs`.
2. Verzeichnis `/srv/startup`, Eigentümer `deploy:devs`, Rechte **`2775`**.
3. Datei `/srv/startup/deploy.sh`, ausführbar (irgendein einfaches Skript, das `deploying` ausgibt).

> **Stolperstein im Container:** `sudo chmod 2775 /srv/startup` meldet Erfolg, aber das setgid-Bit ist danach weg. Der Kernel verwirft es, wenn dem Aufrufer die Capability `CAP_FSETID` fehlt und er nicht in der Gruppe der Datei ist, und genau das trifft auf root in der Lab-Box zu. Führe den Befehl deshalb als jemand aus, der in `devs` ist: `sudo -u deploy chmod 2775 /srv/startup`. Prüfe das Ergebnis immer mit `stat -c '%a %A' /srv/startup` statt dem Exit-Code zu vertrauen.

## Prüfen
```bash
lab-check 3
```

## Fragen zur Diskussion
- Was bedeutet die führende **2** in `2775`? (setgid: neue Dateien erben die Gruppe des Verzeichnisses.) Lege eine Datei darin an und sieh dir ihre Gruppe an.
- Warum geben wir nicht einfach allem `chmod 777`?
- Wann benutzt du `sudo` und wann nicht? (Prinzip der **geringsten Rechte**)

## Hinweise für den Lehrer
- Erkläre das Oktalsystem einmal an einem Rechenbeispiel (7 = 4+2+1) und lass die Rechte danach durch Wiederholung sitzen.
- In der Lab-Box hat `student` volles `sudo`, weil das Lernen es erfordert. Auf echten Systemen ist das nicht so.
- Der setgid-Stolperstein oben ist eine gute Gelegenheit, über den Unterschied zwischen "Befehl erfolgreich" und "Ergebnis geprüft" zu sprechen.
