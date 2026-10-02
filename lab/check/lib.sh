# shellcheck shell=bash
# Shared helpers for the session checks.
PASS=0; FAIL=0
ok()  { echo "  [PASS] $1"; PASS=$((PASS+1)); }
bad() { echo "  [FAIL] $1"; [ -n "${2:-}" ] && echo "         hint: $2"; FAIL=$((FAIL+1)); }
check() { # check "description" "hint" command...
  local d="$1" h="$2"; shift 2
  if "$@" >/dev/null 2>&1; then ok "$d"; else bad "$d" "$h"; fi
}
sha_of_file() { tr -d '[:space:]' < "$1" | sha256sum | awk '{print $1}'; }
# shellcheck disable=SC2034  # used by the s*.sh files that source this file
EXPECTED="${LAB_EXPECTED_DIR:-/opt/lab/expected}"
summary() {
  echo
  if [ "$FAIL" -eq 0 ]; then echo "  ALL DONE: $PASS/$((PASS+FAIL)) checks passed. Great work!"; exit 0
  else echo "  $PASS/$((PASS+FAIL)) checks passed. Keep going."; exit 1; fi
}
