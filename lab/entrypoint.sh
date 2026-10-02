#!/usr/bin/env bash
# Runs as root when the box starts.
set -euo pipefail

U="${STUDENT_USER:-student}"
H="${STUDENT_HOME:-/home/$U}"

ssh-keygen -A >/dev/null

# Password: from STUDENT_PASSWORD, otherwise generate one and print it to the logs.
PW="${STUDENT_PASSWORD:-}"
if [ -z "$PW" ]; then
  PW="$(openssl rand -base64 24 | tr -dc 'A-Za-z0-9' | head -c 12)"
  echo "==> GENERATED STUDENT PASSWORD: $PW"
fi
echo "$U:$PW" | chpasswd

# Optional SSH public key
if [ -n "${PUBLIC_KEY:-}" ]; then
  install -d -m 700 -o "$U" -g "$U" "$H/.ssh"
  echo "$PUBLIC_KEY" > "$H/.ssh/authorized_keys"
  chown "$U:$U" "$H/.ssh/authorized_keys"
  chmod 600 "$H/.ssh/authorized_keys"
fi

/opt/lab/setup-challenges.sh

# cron daemon (session 4)
cron

# The "bad job" of session 4: a process the student must find and stop.
runuser -u "$U" -- bash -c 'nohup setsid /opt/lab/bad-job.sh >/dev/null 2>&1 &'

echo "==> Box ready. SSH is listening on port 22 inside the container."
exec /usr/sbin/sshd -D -e
