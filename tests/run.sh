#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
for t in tests/*.lua; do
  echo "== $t"
  nvim --headless -u NONE -l "$t"
done
