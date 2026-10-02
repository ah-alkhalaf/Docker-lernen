#!/usr/bin/env bash
# Creates the per-box challenge files once (first start). Safe to re-run.
set -euo pipefail

U="${STUDENT_USER:-student}"
H="${STUDENT_HOME:-/home/$U}"
EXP="${LAB_EXPECTED_DIR:-/opt/lab/expected}"
C="$H/challenges"

[ -f "$H/.lab-initialized" ] && exit 0

rand_flag() { echo "lab-$(head -c 8 /dev/urandom | od -An -tx1 | tr -d ' \n')"; }
hash_of()   { printf '%s' "$1" | sha256sum | awk '{print $1}'; }

mkdir -p "$EXP" "$C/s1/inhere/docs" "$C/s1/inhere/notes" "$C/s2" "$C/s4" "$H/answers"

# ---- Session 1: a hidden file ----
FLAG1="$(rand_flag)"
echo "$FLAG1" > "$C/s1/inhere/notes/.hidden-note"
echo "Nothing to see here."   > "$C/s1/inhere/docs/readme.txt"
echo "Not this one either."   > "$C/s1/inhere/notes/todo.txt"
hash_of "$FLAG1" > "$EXP/s1.sha256"

# ---- Session 2: logs, pipes, base64 ----
awk -v seed="$(date +%s)$RANDOM" 'BEGIN {
  srand(seed)
  n = split("41.33.12.7 102.8.9.14 10.0.0.5 185.22.4.9 77.5.6.100 203.0.113.50 198.51.100.23 192.0.2.77 45.60.7.8 88.99.1.2 62.10.20.30 5.9.8.7", ip, " ")
  m = split("200 200 200 200 301 404 404 500 403", st, " ")
  p = split("/ /index.html /api/visits /login /admin /health /static/app.js /favicon.ico", path, " ")
  for (i = 1; i <= 600; i++) {
    k = (rand() < 0.30) ? 1 : int(rand() * n) + 1
    printf "%s - - [02/Oct/2026:10:%02d:%02d +0000] \"GET %s HTTP/1.1\" %s %d\n", \
      ip[k], int(i / 60) % 60, i % 60, path[int(rand() * p) + 1], st[int(rand() * m) + 1], int(rand() * 5000) + 200
  }
}' > "$C/s2/access.log"

FLAG2="$(rand_flag)"
printf '%s' "$FLAG2" | base64 > "$C/s2/secret.b64"
hash_of "$FLAG2" > "$EXP/s2.sha256"

# ---- Session 4: a log file for the runaway job ----
: > "$C/s4/bad-job.log"

chmod -R a+rX "$EXP"
if [ "$(id -u)" = "0" ]; then chown -R "$U:$U" "$H"; fi
touch "$H/.lab-initialized"
