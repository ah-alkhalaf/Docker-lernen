# Session 8: Repariere das kaputte System (Break/Fix)

**Dauer:** 2 Stunden · **Ort:** Dein Rechner (Docker) · **Voraussetzung:** Session 7

## Ziel
Der Freund lernt zu **diagnostizieren**, und das ist es, was einen DevOps-Ingenieur von anderen unterscheidet. Niemand kennt alle Lösungen auswendig, aber jeder kann einer Methode folgen.

## Die Diagnose-Methode (häng sie dir vor die Nase)
1. **Was sehe ich genau?** Lies die ganze Fehlermeldung, nicht die Hälfte.
2. **Wo scheitert es?** `docker compose ps`, welcher Dienst ist nicht healthy?
3. **Was sagen die Logs?** `docker compose logs --tail 50 dienstname`
4. **Was sagen die Healthchecks?** `docker inspect --format '{{json .State.Health}}' containername`
5. **Geh rein und probier es selbst:** `docker compose exec dienst sh`
6. **Was ist die Hypothese?** Ändere **genau eine** Sache und teste erneut.
7. **Schreib auf**, was die Ursache war. Das ist das Postmortem, und sei es nur eine Zeile.

## So wird gespielt
Das Verzeichnis [`startup/break-fix/`](../startup/break-fix/) enthält 4 kaputte Szenarien (und ein fünftes von Hand). Die Symptome stehen in [`startup/break-fix/README.md`](../startup/break-fix/README.md). **Öffne `SOLUTIONS.md` nicht, bevor du fertig bist!**
```bash
cd startup
cp .env.example .env          # falls noch nicht geschehen
break-fix/run.sh down 01      # erst aufräumen (falls vorher etwas lief)
break-fix/run.sh up 01        # das kaputte Szenario 01 starten
```
Die Regel: Repariere, indem du eine Kopie der Datei änderst, und starte sie, bis `./verify.sh` durchläuft.

## Vorschlag für ein Punktesystem
- Gelöst ohne Tipp: 3 Punkte · nach einem Tipp: 2 · nach zwei Tipps: 1.
- 5 Zusatzpunkte für zwei geschriebene Zeilen: Was war die Ursache? Und wie verhindern wir eine Wiederholung?

## Abschluss des Kurses
Bitte jeden Freund um **zwei Minuten**: Was war das Schwierigste? Und was davon wirst du morgen in der Arbeit oder im Studium benutzen? Entscheidet danach gemeinsam, wie es weitergeht: Kubernetes? Terraform? Ein echtes Projekt?

## Hinweise für den Lehrer
- Lass die Freunde 5 bis 10 Minuten festhängen, bevor du einen Tipp gibst. Die Geduld mit dem Scheitern ist die eigentliche Lektion.
- Diagnose ist wie Insektensuche: Lass sie ihre Hypothese **laut aussprechen**, bevor sie sie ausprobieren.
