#!/usr/bin/env bash
# shellcheck disable=SC2088  # "~" inside hint texts is intentional
# shellcheck source-path=SCRIPTDIR
# shellcheck source=lib.sh
source "$(dirname "$0")/lib.sh"
echo "Session 2 - Text, Pipes, find/grep"
LOG="$HOME/challenges/s2/access.log"
TOP="$(awk '{print $1}' "$LOG" | sort | uniq -c | sort -rn | head -1 | awk '{print $2}')"
N404="$(awk '$9 == 404' "$LOG" | wc -l | tr -d ' ')"

a="$HOME/answers/s2-top-ip.txt"
if [ -s "$a" ] && [ "$(tr -d '[:space:]' < "$a")" = "$TOP" ]; then ok "haeufigste IP ist richtig"
else bad "haeufigste IP ist richtig" "awk '{print \$1}' access.log | sort | uniq -c | sort -rn | head"; fi

b="$HOME/answers/s2-404-count.txt"
if [ -s "$b" ] && [ "$(tr -d '[:space:]' < "$b")" = "$N404" ]; then ok "Anzahl der 404-Antworten ist richtig"
else bad "Anzahl der 404-Antworten ist richtig" "der Statuscode ist Feld 9: awk '\$9 == 404' access.log | wc -l"; fi

c="$HOME/answers/s2-decoded.txt"
if [ -s "$c" ] && [ "$(sha_of_file "$c")" = "$(cat "$EXPECTED/s2.sha256" 2>/dev/null)" ]; then ok "base64-Geheimnis richtig dekodiert"
else bad "base64-Geheimnis richtig dekodiert" "base64 -d secret.b64 > ~/answers/s2-decoded.txt"; fi
summary
