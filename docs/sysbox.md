# Optional: Sysbox für Boxen mit systemd und Docker

> **Ehrlicher Hinweis:** Diese Datei beschreibt **eine Richtung** und wurde in diesem Repository nicht getestet. Folge der offiziellen Sysbox-Dokumentation und prüfe die genannten Images, bevor du dich darauf verlässt.

## Warum?
Die Standard-Lab-Box ist ein gewöhnlicher Container: Es gibt kein `systemd` darin, und Docker lässt sich darin nicht sicher betreiben. [Sysbox](https://github.com/nestybox/sysbox) ist eine alternative Runtime, die **System-Container** startet, die sich wie ein kleiner Server verhalten: mit `systemd`, mit Docker darin **ohne** `--privileged`, und mit stärkerer Isolation über User-Namespaces.

## Wann brauchst du das?
- Für echtes Üben mit `systemctl` und `journalctl` (Session 4).
- Um die Sessions 6-8 **in** der Box laufen zu lassen statt auf den Rechnern der Freunde.

## Voraussetzungen
- Nur ein **Linux**-Host (läuft nicht unter macOS oder Windows mit Docker Desktop).
- Sysbox nach seiner Dokumentation installieren und dann mit `docker info | grep -i runtimes` prüfen, dass `sysbox-runc` erscheint.

## Die praktische Idee (ungetestet)
```bash
docker run -d --name sysbox-box --runtime=sysbox-runc -p 2301:22 \
  nestybox/ubuntu-jammy-systemd-docker
```
Danach Benutzer und SSH darin einrichten, wie es die Dokumentation des Images beschreibt. Prüfe zuerst, ob das Image `sshd` mitbringt, sonst installiere es darin mit `apt install openssh-server`.
Die sauberere Alternative: Bau dein eigenes Image (`FROM nestybox/ubuntu-jammy-systemd-docker`), das den Benutzer `student` und das Verzeichnis `lab/` aus diesem Repository hinzufügt.
