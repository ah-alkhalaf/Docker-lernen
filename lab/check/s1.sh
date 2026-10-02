#!/usr/bin/env bash
# shellcheck disable=SC2088  # "~" inside hint texts is intentional
# shellcheck source-path=SCRIPTDIR
# shellcheck source=lib.sh
source "$(dirname "$0")/lib.sh"
echo "Session 1 - navigation and files"
A="$HOME/answers/s1.txt"
check "answers/s1.txt exists" "write the content of the hidden file into ~/answers/s1.txt" test -s "$A"
if [ -s "$A" ] && [ "$(sha_of_file "$A")" = "$(cat "$EXPECTED/s1.sha256" 2>/dev/null)" ]; then
  ok "hidden-file content is correct"
else
  bad "hidden-file content is correct" "files starting with a dot are hidden: try ls -a, or find -name '.*'"
fi
check "~/startup/ directory exists" "mkdir ~/startup" test -d "$HOME/startup"
check "~/startup/README.md exists" "touch ~/startup/README.md" test -f "$HOME/startup/README.md"
summary
