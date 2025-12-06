#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BIN="$ROOT/bin/vector_add"

if [ ! -x "$BIN" ]; then
  echo "Binary not found, building..."
  make -C "$ROOT"
fi

echo "Running vector_add..."
"$BIN"
