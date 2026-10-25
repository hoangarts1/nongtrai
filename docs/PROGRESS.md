# PROGRESS — THE LIFE  (agent memory: read first, update last)

Last updated: 2026-10-25 (starter integrated)

## Current milestone
`P-3` — integrate the starter into the existing Godot project, then begin Phase 0 foundations. The full list is in `docs/ROADMAP.md`.

## Last commit / tag
(none yet)

## Done
- [x] Master plan written (reference copy: `docs/reference/THE_LIFE_MASTER_PLAN.txt` — not read every session)
- [x] Repo starter docs integrated into the existing project
- [x] MVP scope confirmed: gray-box farming loop through harvest
- [x] Godot 4.7.2-stable, Forward+, Jolt Physics, PC Windows target confirmed
- [x] Camera confirmed: orthographic, yaw 45°, pitch 35°
- [x] Open Sans regular font copied for the Vietnamese UI
- [x] GUT 9.7.1 installed and headless smoke tests configured
- [x] GridMath implemented with boundary, negative-coordinate and footprint tests
- [x] InputMap, physics layer names and foundation autoloads configured
- [x] Gray-box world scene with orthographic camera and placeholder farm plot created
- [x] Smooth camera follow and player/map bounds added

## In progress
- Developer playtest of smooth camera follow and map bounds

## Known issues / tech debt
- The Godot executable is not currently available as `godot` on the terminal PATH.
- GUT 9.7.1 is installed under `addons/gut` for Godot 4.7.x.

## Decisions since last update
- D08 and D13 confirmed from the submitted project form.
- Placeholder geometry is allowed until the developer supplies final models.

## Open `<<FILL>>` items (must be empty before roadmap task 0.1)
- gdtoolkit 4.3.0 is selected but not installed yet

## Next up (agent proposal)
- Next: implement camera-relative player movement, then the day clock and farm domain state.

## How to run
- Parse check: `tools/check_parse.sh` (macOS/Linux) or `tools\check_parse.bat` (Windows). Set the `GODOT` env var to your Godot executable.
- All tests: `tools/run_tests.sh` / `tools\run_tests.bat` (fails on purpose until roadmap task 0.1 configures the test command).
- Main scene: (not created yet)
