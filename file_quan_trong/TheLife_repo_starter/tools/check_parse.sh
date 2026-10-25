#!/usr/bin/env bash
# Parse check: opens the project headless and quits. Exit code 0 = no script parse errors.
# Usage:  GODOT=/path/to/godot ./tools/check_parse.sh
# If GODOT is not set, falls back to `godot` on PATH.
set -euo pipefail
GODOT_BIN="${GODOT:-godot}"
cd "$(dirname "$0")/.."
echo "[check_parse] using: $GODOT_BIN"
"$GODOT_BIN" --version
"$GODOT_BIN" --headless --path . --quit
echo "[check_parse] OK (exit 0)"
