# Session 1: Zum ersten Mal auf einem Linux-Server

**Dauer:** 2 Stunden · **Ort:** Lab-Box (`ssh -p 2201 student@HOST`) · **Voraussetzung:** keine

## Ziel
Der Freund meldet sich per SSH auf einem Linux-Server an, bewegt sich zwischen Verzeichnissen, legt Dateien an und liest sie, und weiß, wo die Dinge liegen.

## Die Idee in zwei Minuten
- Unter Linux ist **alles eine Datei oder ein Verzeichnis**, und alles hängt in einem Baum, der bei `/` beginnt.
- Das **Terminal** ist das Fenster, in das du tippst. Die **Shell** (hier `bash`) versteht deine Befehle und führt sie aus.
- Befehle haben die Form: `Befehl  -Optionen  Ziel`.

## Spickzettel

| Befehl | Was er tut |
|---|---|
| `pwd` | Wo bin ich gerade? |
| `ls -la` | Alle Dateien anzeigen (auch versteckte) mit Details |
| `cd Pfad` | In ein Verzeichnis wechseln (`cd ..` nach oben, `cd ~` ins Home, `cd -` zurück) |
| `cat Datei` / `less Datei` | Inhalt anzeigen (`q` beendet less) |
| `head` / `tail -n 5 Datei` | Erste oder letzte Zeilen |
| `mkdir -p a/b` | Verzeichnis anlegen (mit Elternverzeichnissen) |
| `touch Datei` | Leere Datei anlegen |
| `cp` / `mv` / `rm` | Kopieren / verschieben oder umbenennen / löschen |
| `man Befehl` | Handbuch (`q` beendet) |
| `tree` | Den Baum anzeigen |

**Tastenkürzel, die dein Leben ändern:** `Tab` vervollständigt · `↑` letzter Befehl · `Ctrl+C` bricht ab · `Ctrl+R` durchsucht die Befehlshistorie.

## Erst ausführen, dann verstehen
1. **Anmelden:** `ssh -p 2201 student@HOST` (Passwort vom Lehrer, oder bei ihm `make passwords`).
2. **Wo bin ich?** `pwd`, dann `ls`, dann `ls -la`. Achte auf die Dateien, die mit einem Punkt beginnen.
3. **Eine Runde durch den Baum:**
   ```bash
   cd /          && ls
   cd /etc       && cat hostname
   cd /var/log   && ls
   cd ~          && pwd
   ```
   Frage: Was ist der Unterschied zwischen `cd /etc` und `cd etc`? (**absoluter** gegen **relativen** Pfad)
4. **Anlegen, kopieren, verschieben:**
   ```bash
   mkdir -p ~/startup/docs
   touch ~/startup/docs/idea.txt
   cp ~/startup/docs/idea.txt ~/startup/docs/idea-backup.txt
   mv ~/startup/docs/idea-backup.txt ~/startup/docs/old.txt
   ```
5. **Warnung:** `rm` kennt keinen Papierkorb. Tippe `rm -rf` nicht, bevor du zweimal gelesen hast, was da steht.
6. **Hilfe holen:** `man ls`, dann suche nach `-h`, und probiere `ls --help`.

## Aufgabe
In `~/challenges/s1/inhere/` liegt eine **versteckte** Datei mit einem Passwort darin. Finde sie und schreibe ihren Inhalt in `~/answers/s1.txt`.
Lege danach `~/startup/README.md` an, die erste Datei deines fiktiven Start-ups.

## Prüfen
```bash
lab-check 1
```

## Fragen zur Diskussion
- Warum beginnen versteckte Dateien mit einem Punkt? Sind sie wirklich "geheim"?
- Was ist der Unterschied zwischen `/home/student` und `~`?
- Wo erwartest du die Logs des Servers? Wo die Konfiguration?

## Bonus: SSH-Schlüssel statt Passwort
Auf **deinem eigenen Rechner**: `ssh-keygen -t ed25519`, dann `ssh-copy-id -p 2201 student@HOST`. Danach geht die Anmeldung ohne Passwort.

## Hinweise für den Lehrer
- Plane 15 Minuten nur für Anmeldung und Verbindung ein, denn hier scheitern die meisten Anfänger (Windows: PowerShell oder Windows Terminal, beide bringen `ssh` mit).
- Lass sie die Befehle **tippen**, nicht kopieren. Tippfehler gehören zum Lernen.
- Erkläre die Rechte jetzt noch nicht, die kommen in Session 3.
