#!/usr/bin/env bash
# Runs: (1) parse check, (2) the unit-test framework headless.
# Task 0.1 of the roadmap fills in step 2 with the REAL command for the framework you chose
# (GUT or gdUnit4 — pick ONE; follow that addon's README and `godot --help` for your pinned version).
# Until then this script FAILS ON PURPOSE, so nobody mistakes "no tests" for "all green".
set -euo pipefail
cd "$(dirname "$0")/.."

./tools/check_parse.sh

echo "[run_tests] <<FILL: put the exact headless test command for your test framework here>>"
echo "[run_tests] Test command is not configured yet (roadmap task 0.1)."
exit 1
