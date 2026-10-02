#!/usr/bin/env bash
# shellcheck disable=SC2088  # "~" inside hint texts is intentional
# shellcheck source-path=SCRIPTDIR
# shellcheck source=lib.sh
source "$(dirname "$0")/lib.sh"
echo "Session 3 - users and permissions"
D="${LAB_SRV_DIR:-/srv/startup}"
check "user 'deploy' exists" "sudo useradd -m deploy" id deploy
check "group 'devs' exists" "sudo groupadd devs" getent group devs
check "'deploy' is a member of 'devs'" "sudo usermod -aG devs deploy" bash -c 'id -nG deploy | tr " " "\n" | grep -qx devs'
check "$D exists" "sudo mkdir -p $D" test -d "$D"
check "$D owner is deploy" "sudo chown deploy:devs $D" bash -c "[ \"\$(stat -c %U '$D')\" = deploy ]"
check "$D group is devs" "sudo chown deploy:devs $D" bash -c "[ \"\$(stat -c %G '$D')\" = devs ]"
check "$D mode is 2775 (setgid + rwxrwxr-x)" "sudo chmod 2775 $D" bash -c "[ \"\$(stat -c %a '$D')\" = 2775 ]"
check "$D/deploy.sh exists and is executable" "create it and chmod +x" test -x "$D/deploy.sh"
summary
