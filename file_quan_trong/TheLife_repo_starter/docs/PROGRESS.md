# PROGRESS — THE LIFE  (agent memory: read first, update last)

Last updated: 2026-10-24 (initial scaffold)

## Current milestone
`P-1` — fill and confirm `docs/DECISIONS.md`, then `P-2` (asset spike), `P-3` (tools + repo). The full list is in `docs/ROADMAP.md`.

## Last commit / tag
(none yet)

## Done
- [x] Master plan written (reference copy: `docs/reference/THE_LIFE_MASTER_PLAN.txt` — not read every session)
- [x] Repo starter docs generated (this folder)

## In progress
- (nothing)

## Known issues / tech debt
- (none)

## Decisions since last update
- (none; defaults are listed in `docs/DECISIONS.md`)

## Open `<<FILL>>` items (must be empty before roadmap task 0.1)
- Godot exact version + renderer + physics engine (`PROJECT_RULES.md` §1, `DECISIONS.md` D08)
- Test framework (GUT or gdUnit4) + its headless command
- gdtoolkit version
- Camera yaw/pitch (D13) — decided in task 0.4
- Target hardware

## Next up (agent proposal)
- (agent writes the next milestone and its risks here at the end of each session)

## How to run
- Parse check: `tools/check_parse.sh` (macOS/Linux) or `tools\check_parse.bat` (Windows). Set the `GODOT` env var to your Godot executable.
- All tests: `tools/run_tests.sh` / `tools\run_tests.bat` (fails on purpose until roadmap task 0.1 configures the test command).
- Main scene: (not created yet)
