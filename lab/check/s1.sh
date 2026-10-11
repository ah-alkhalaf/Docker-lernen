#!/usr/bin/env bash
# shellcheck disable=SC2088  # "~" inside hint texts is intentional
# shellcheck source-path=SCRIPTDIR
# shellcheck source=lib.sh
source "$(dirname "$0")/lib.sh"
echo "Session 1 - Navigation und Dateien"
A="$HOME/answers/s1.txt"
check "answers/s1.txt ist vorhanden" "schreibe den Inhalt der versteckten Datei nach ~/answers/s1.txt" test -s "$A"
if [ -s "$A" ] && [ "$(sha_of_file "$A")" = "$(cat "$EXPECTED/s1.sha256" 2>/dev/null)" ]; then
  ok "Inhalt der versteckten Datei ist richtig"
else
  bad "Inhalt der versteckten Datei ist richtig" "Dateien mit einem Punkt am Anfang sind versteckt: probiere ls -a oder find -name '.*'"
fi
check "Verzeichnis ~/startup/ ist vorhanden" "mkdir ~/startup" test -d "$HOME/startup"
check "~/startup/README.md ist vorhanden" "touch ~/startup/README.md" test -f "$HOME/startup/README.md"
summary
