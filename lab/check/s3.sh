#!/usr/bin/env bash
# shellcheck disable=SC2088  # "~" inside hint texts is intentional
# shellcheck source-path=SCRIPTDIR
# shellcheck source=lib.sh
source "$(dirname "$0")/lib.sh"
echo "Session 3 - Benutzer und Rechte"
D="${LAB_SRV_DIR:-/srv/startup}"
check "Benutzer 'deploy' existiert" "sudo useradd -m deploy" id deploy
check "Gruppe 'devs' existiert" "sudo groupadd devs" getent group devs
check "'deploy' ist Mitglied von 'devs'" "sudo usermod -aG devs deploy" bash -c 'id -nG deploy | tr " " "\n" | grep -qx devs'
check "$D ist vorhanden" "sudo mkdir -p $D" test -d "$D"
check "Eigentuemer von $D ist deploy" "sudo chown deploy:devs $D" bash -c "[ \"\$(stat -c %U '$D')\" = deploy ]"
check "Gruppe von $D ist devs" "sudo chown deploy:devs $D" bash -c "[ \"\$(stat -c %G '$D')\" = devs ]"
# Im Container verwirft chmod als root das setgid-Bit still, wenn CAP_FSETID fehlt
# und root nicht in der Gruppe der Datei ist. Als Eigentuemer, der in dieser Gruppe
# ist, bleibt das Bit erhalten - deshalb sagt der Hinweis genau das.
check "Rechte von $D sind 2775 (setgid + rwxrwxr-x)" "sudo -u deploy chmod 2775 $D
         Hinweis: 'sudo chmod 2775' meldet Erfolg, verliert das setgid-Bit aber
         im Container ohne CAP_FSETID - fuehr es als Benutzer in der Gruppe 'devs' aus" bash -c "[ \"\$(stat -c %a '$D')\" = 2775 ]"
check "$D/deploy.sh ist vorhanden und ausfuehrbar" "anlegen und chmod +x" test -x "$D/deploy.sh"
summary
