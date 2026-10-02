#!/usr/bin/env bash
# shellcheck disable=SC2088  # "~" inside hint texts is intentional
# shellcheck source-path=SCRIPTDIR
# shellcheck source=lib.sh
source "$(dirname "$0")/lib.sh"
echo "Session 5 - networking and bash scripts"
S="$HOME/healthcheck.sh"
check "~/healthcheck.sh exists and is executable" "create it, chmod +x" test -x "$S"
if [ -x "$S" ]; then
  T="$(mktemp -d)"; echo ok > "$T/index.html"
  PORT=$((20000 + RANDOM % 20000))
  ( cd "$T" && python3 -m http.server "$PORT" --bind 127.0.0.1 >/dev/null 2>&1 ) &
  SRV=$!
  sleep 1
  OUT_GOOD="$("$S" "http://127.0.0.1:$PORT/" 2>&1)"; RC_GOOD=$?
  OUT_BAD="$("$S" "http://127.0.0.1:1/" 2>&1)"; RC_BAD=$?
  kill "$SRV" 2>/dev/null; wait "$SRV" 2>/dev/null; rm -rf "$T"
  if [ $RC_GOOD -eq 0 ] && echo "$OUT_GOOD" | grep -q "OK"; then ok "prints OK and exits 0 for a healthy URL"
  else bad "prints OK and exits 0 for a healthy URL" "use: curl -fsS -o /dev/null --max-time 3 \"\$1\""; fi
  if [ $RC_BAD -ne 0 ] && echo "$OUT_BAD" | grep -q "FAIL"; then ok "prints FAIL and exits non-zero for a broken URL"
  else bad "prints FAIL and exits non-zero for a broken URL" "exit 1 when curl fails"; fi
fi
summary
