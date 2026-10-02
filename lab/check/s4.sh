#!/usr/bin/env bash
# shellcheck disable=SC2088  # "~" inside hint texts is intentional
# shellcheck source-path=SCRIPTDIR
# shellcheck source=lib.sh
source "$(dirname "$0")/lib.sh"
echo "Session 4 - processes and cron"
check "the runaway 'bad-job.sh' is stopped" "ps aux | grep bad-job, then kill <PID>" bash -c '! pgrep -f bad-job.sh'
check "~/backup.sh exists and is executable" "create it, then chmod +x ~/backup.sh" test -x "$HOME/backup.sh"
check "crontab has an entry that runs backup.sh" "crontab -e   (example: */5 * * * * \$HOME/backup.sh)" bash -c 'crontab -l 2>/dev/null | grep -v "^#" | grep -q backup.sh'
summary
