#!/usr/bin/env bash
# Usage: break-fix/run.sh <up|down> <01|02|03|04>
# Runs a broken variant of the stack. Works from any directory.
set -euo pipefail
cd "$(dirname "$0")/.."
action="${1:?usage: break-fix/run.sh <up|down> <01|02|03|04>}"
n="${2:?scenario number missing}"
files=(break-fix/"${n}"-*.yaml)
file="${files[0]}"
[ -f "$file" ] || { echo "no scenario $n"; exit 1; }
[ -f .env ] || { echo "create .env first: cp .env.example .env"; exit 1; }
case "$action" in
  up)   docker compose --project-directory . -f "$file" up -d --build ;;
  down) docker compose --project-directory . -f "$file" down ;;
  *)    echo "action must be up or down"; exit 1 ;;
esac
