#!/usr/bin/env bash
# Session 4: a harmless runaway job. The student must find and kill it.
while true; do
  echo "$(date +%T) bad-job is still running" >> "$HOME/challenges/s4/bad-job.log"
  sleep 5
done
