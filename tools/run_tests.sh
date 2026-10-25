#!/usr/bin/env bash
# Runs: (1) parse check, (2) the unit-test framework headless.
set -euo pipefail
cd "$(dirname "$0")/.."

./tools/check_parse.sh

echo "[run_tests] running GUT"
"${GODOT:-godot}" -d -s --path . addons/gut/gut_cmdln.gd -gdir=res://tests/unit -gprefix=test_ -gexit
echo "[run_tests] PASS"
