# Session 2: Text, Pipes und Suche

**Dauer:** 2 Stunden · **Ort:** Lab-Box · **Voraussetzung:** Session 1

## Ziel
Der Freund bearbeitet echte Logdateien mit kleinen Befehlen, die sich zusammenstecken lassen. Genau darin liegt die eigentliche Stärke der Kommandozeile.

## Die Idee in zwei Minuten
Jeder Befehl macht eine Sache richtig gut. Die **Pipe** `|` gibt die Ausgabe eines Befehls als Eingabe an den nächsten weiter, so baust du eine "Fertigungsstraße":
```bash
cat access.log | grep 404 | wc -l
```

## Spickzettel

| Befehl | Was er tut |
|---|---|
| `grep "Text" Datei` | Zeilen, die den Text enthalten (`-i` Groß-/Kleinschreibung egal, `-v` umkehren, `-c` zählen, `-n` Zeilennummern, `-r` rekursiv) |
| `wc -l` | Anzahl der Zeilen |
| `sort` / `sort -rn` | Sortieren / numerisch absteigend sortieren |
| `uniq -c` | Wiederholungen zählen (nach `sort`) |
| `awk '{print $1}'` | Erste Spalte ausgeben (`$9` die neunte) |
| `cut -d' ' -f1` | Einfachere Variante, eine Spalte zu holen |
| `find Pfad -name "*.log"` | Dateien suchen (`-size +1M`, `-type f`, `-mtime -1`) |
| `>` / `>>` | Ausgabe in eine Datei schreiben / anhängen |
| `base64 -d` | base64 dekodieren |
| `tail -f Datei` | Einer wachsenden Datei folgen |

## Erst ausführen, dann verstehen
1. Sieh dir das Log an:
   ```bash
   cd ~/challenges/s2
   head -3 access.log
   wc -l access.log
   ```
   Jede Zeile ist eine HTTP-Anfrage: Spalte 1 ist die **IP** des Besuchers, Spalte 9 der **Statuscode** (200 Erfolg, 404 nicht gefunden, 500 Serverfehler).
2. Bau die Pipe Schritt für Schritt und sieh dir nach jedem Schritt die Ausgabe an:
   ```bash
   awk '{print $1}' access.log
   awk '{print $1}' access.log | sort
   awk '{print $1}' access.log | sort | uniq -c
   awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -3
   ```
3. In eine Datei speichern: `awk '$9 == 500' access.log > ~/errors.log`, dann `wc -l ~/errors.log`.
4. Dateien suchen: `find /var/log -type f -size +0` und `find ~ -name "*.txt"`.

## Aufgabe
Schreibe die Ergebnisse in diese Dateien unter `~/answers/`:
1. `s2-top-ip.txt`: die **häufigste** IP-Adresse in `access.log`.
2. `s2-404-count.txt`: die **Anzahl** der Anfragen mit Status 404.
3. `s2-decoded.txt`: das Ergebnis nach dem Dekodieren von `secret.b64` (Befehl `base64 -d`).

## Prüfen
```bash
lab-check 2
```

## Fragen zur Diskussion
- Warum brauchen wir `sort` vor `uniq -c`? (Probier es ohne.)
- Was ist der Unterschied zwischen `>` und `>>`? Was passiert, wenn du `>` auf eine wichtige Datei anwendest?
- Wo brauchst du solche Pipes in der DevOps-Arbeit? (Logs auswerten, einen Angriff entdecken, Fehler zählen)

## Hinweise für den Lehrer
- Lass jeden Freund die Ausgabe der Pipe **vorhersagen**, bevor er sie ausführt.
- Häufiger Fehler: `sort` vor `uniq` vergessen, oder `$8` statt `$9` nehmen (zählt die Spalten gemeinsam durch).
- Das `access.log` wird pro Box zufällig erzeugt, die Ergebnisse unterscheiden sich also und lassen sich nicht voneinander abschreiben.
