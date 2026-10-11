#!/usr/bin/env bash
# shellcheck disable=SC2088  # "~" inside hint texts is intentional
# shellcheck source-path=SCRIPTDIR
# shellcheck source=lib.sh
source "$(dirname "$0")/lib.sh"
echo "Session 4 - Prozesse und cron"
check "der entlaufene 'bad-job.sh' ist gestoppt" "ps aux | grep bad-job, dann kill <PID>" bash -c '! pgrep -f bad-job.sh'
check "~/backup.sh ist vorhanden und ausfuehrbar" "anlegen, dann chmod +x ~/backup.sh" test -x "$HOME/backup.sh"
check "crontab enthaelt einen Eintrag fuer backup.sh" "crontab -e   (Beispiel: */5 * * * * \$HOME/backup.sh)" bash -c 'crontab -l 2>/dev/null | grep -v "^#" | grep -q backup.sh'
summary
