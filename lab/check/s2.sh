#!/usr/bin/env bash
# shellcheck disable=SC2088  # "~" inside hint texts is intentional
# shellcheck source-path=SCRIPTDIR
# shellcheck source=lib.sh
source "$(dirname "$0")/lib.sh"
echo "Session 2 - text, pipes, find/grep"
LOG="$HOME/challenges/s2/access.log"
TOP="$(awk '{print $1}' "$LOG" | sort | uniq -c | sort -rn | head -1 | awk '{print $2}')"
N404="$(awk '$9 == 404' "$LOG" | wc -l | tr -d ' ')"

a="$HOME/answers/s2-top-ip.txt"
if [ -s "$a" ] && [ "$(tr -d '[:space:]' < "$a")" = "$TOP" ]; then ok "most frequent IP is correct"
else bad "most frequent IP is correct" "awk '{print \$1}' access.log | sort | uniq -c | sort -rn | head"; fi

b="$HOME/answers/s2-404-count.txt"
if [ -s "$b" ] && [ "$(tr -d '[:space:]' < "$b")" = "$N404" ]; then ok "number of 404 responses is correct"
else bad "number of 404 responses is correct" "the status code is field 9: awk '\$9 == 404' access.log | wc -l"; fi

c="$HOME/answers/s2-decoded.txt"
if [ -s "$c" ] && [ "$(sha_of_file "$c")" = "$(cat "$EXPECTED/s2.sha256" 2>/dev/null)" ]; then ok "base64 secret decoded correctly"
else bad "base64 secret decoded correctly" "base64 -d secret.b64 > ~/answers/s2-decoded.txt"; fi
summary
