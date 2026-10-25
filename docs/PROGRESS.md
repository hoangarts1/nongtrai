# PROGRESS — THE LIFE  (agent memory: read first, update last)

Last updated: 2026-10-25 (HUD and onboarding)

## Current milestone
`4.6 + UI onboarding` — Save/Load v1 is complete; HUD regions and first-run farming guidance are now implemented.

## Last commit / tag
`3e2e221` — `feat: add save load v1`; final tag pending after the full-suite verification below.

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
- Phase 4.1 complete and verified; next is 4.2 FarmView placeholder.

## Done
- [x] Reusable interaction prompt anchored to the viewport with readable background and outline
- [x] Prompt integration tests for near/far player positions and visible text
- [x] Debug-only Ctrl+M menu with clock, player position, FPS, time controls and extensible action registry
- [x] GameClock debug time and speed APIs with tests
- [x] Overnight sleep runs at x20 until 06:00, then restores the previous time speed
- [x] Daytime sleep prompt and interaction are hidden/no-op
- [x] Clock display wraps overnight hours to 00:00, 01:00 and 02:00 instead of showing 24:00+ or 25:00+
- [x] HUD and debug menu use the shared GameClock.format_time() formatter
- [x] Sleeping continues through displayed 00:00–05:59 and finishes at 06:00; awake rollover at 02:00 remains unchanged
- [x] InventoryState supports capacity, stacking, add/remove validation, signals and save serialization
- [x] DataRegistry loads temporary seed and harvest item definitions from Resource data
- [x] Basic inventory panel opens with I and debug menu can add seeds or clear the inventory
- [x] Shared HUD button bar adds a mouse inventory button with tooltip, active state and sleep lock
- [x] DataValidator checks item resource presence, unique IDs, snake_case IDs and positive max_stack values
- [x] Hotbar displays inventory stacks and selects non-empty slots without mutating quantities
- [x] Hotbar redraw is safe during inventory updates and button signals; 3.3 tests pass
- [x] Localization autoload loads Vietnamese and English CSV translations; UI labels use `tr()`
- [x] Official runner discovers Godot at `D:\godot\Godot_v4.7.2-stable_win64.exe`, uses bounded non-debug runs, scans error text, and starts the main scene headless
- [x] FarmGridState parse/runtime error fixed; 4.1 lifecycle tests pass
- [x] FarmView builds a visible GridMath-aligned placeholder grid and updates soil/crop visuals from domain signals
- [x] ToolData and ToolAction support hoe, watering and seed actions with reach checks
- [x] Hotbar tool buttons select actions; target highlight distinguishes reachable and unreachable cells
- [x] World tool input is handled through unhandled input and is blocked by inventory, debug menu and sleep
- [x] Mature crops preview their harvest, deliver products to InventoryState, and remain planted when the full inventory blocks delivery
- [x] DaySimulator advances only watered crops and dries plots; Main connects it to GameClock.day_started
- [x] Debug menu includes seed, hoe-all, water-all, grow-one-day and reset-farm actions
- [x] SaveService writes versioned JSON atomically, rotates three backups and ignores corrupted/future saves safely
- [x] Debug menu exposes localized save/load actions; Main restores clock, player, inventory and farm state
- [x] HUD regions use anchors and containers; layout tests cover 1152x648, 1280x720 and 1920x1080
- [x] First-run controls guide uses InputMap bindings, H and HUD `?`, with persistent opt-out in Settings
- [x] New players receive turnip seeds and the farming checklist tracks domain events through harvest
- [x] Onboarding checklist is included in save/load state

## Known issues / tech debt
- GUT 9.7.1 is installed under `addons/gut` for Godot 4.7.x.

## Decisions since last update
- D08 and D13 confirmed from the submitted project form.
- Placeholder geometry is allowed until the developer supplies final models.
- HUD layout is documented in `docs/UI_LAYOUT.md`; prompt sits above the hotbar and inventory is centered with a close button.
- While sleeping, debug set-time, set-speed, pause and next-day actions are ignored. This keeps the sleep state deterministic and prevents a debug action from leaving the player locked or the clock stuck at x20.

## Open `<<FILL>>` items (must be empty before roadmap task 0.1)
- gdtoolkit 4.3.0 is selected but not installed yet

## Next up (agent proposal)
- MVP farming-loop implementation is complete through 4.6; 4.7 game-feel polish remains outside this checkpoint.

## How to run
- Parse check: `tools/check_parse.sh` (macOS/Linux) or `tools\check_parse.bat` (Windows). Set the `GODOT` env var to your Godot executable.
- All tests: `tools/run_tests.sh` / `tools\run_tests.bat` (fails on purpose until roadmap task 0.1 configures the test command).
- Main scene: (not created yet)
