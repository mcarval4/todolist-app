#!/bin/sh
set -eu

required_commands="docker kind kubectl terraform helm git"

for command in $required_commands; do
  if ! command -v "$command" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "$command" >&2
    exit 1
  fi
done

if ! docker info >/dev/null 2>&1; then
  printf '%s\n' 'Docker daemon is not available. Start Docker Desktop and retry.' >&2
  exit 1
fi

available_kib=$(df -Pk . | awk 'NR == 2 { print $4 }')
required_kib=$((25 * 1024 * 1024))
if [ "$available_kib" -lt "$required_kib" ]; then
  printf '%s\n' 'At least 25 GiB of free disk space is required.' >&2
  exit 1
fi

printf '%s\n' 'Preflight checks passed.'
