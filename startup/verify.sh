#!/usr/bin/env bash
# Quick end-to-end check of the startup stack (sessions 6-7).
# Usage: ./verify.sh [port]      (default 8080)
set -uo pipefail
PORT="${1:-8080}"
pass=0; fail=0
t() { if "${@:2}" >/dev/null 2>&1; then echo "  [PASS] $1"; pass=$((pass+1)); else echo "  [FAIL] $1"; fail=$((fail+1)); fi; }

t "compose file is valid"                docker compose config -q
# shellcheck disable=SC2016  # the single-quoted script is run by bash -c on purpose
t "all services are running"             bash -c 'test -z "$(docker compose ps --status exited -q)" && test -n "$(docker compose ps -q)"'
t "app answers through caddy (/health)"  curl -fsS --max-time 5 "http://localhost:$PORT/health"
t "visit counter works (/api/visits)"    curl -fsS --max-time 5 "http://localhost:$PORT/api/visits"
t "db is NOT published on the host"      bash -c '! docker compose port db 5432 2>/dev/null | grep -q .'
echo; echo "  $pass passed, $fail failed"; [ "$fail" -eq 0 ]
