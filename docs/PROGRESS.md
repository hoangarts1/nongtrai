# PROGRESS — THE LIFE  (agent memory: read first, update last)

Last updated: 2026-10-26 (click regression fixed; chibi UI/presentation)

## Current milestone
`Phase 8 (NPCs & quests)` — requested slice of Roadmap 8.1–8.4 implemented and automatically verified: confirmed delivery, daily merchant offers, seasonal schedules, dialogue/journal and save v4. Human playtest pending. Roadmap 8.5/8.6 are separate and are not marked done.

## Last commit / tag
`npc-quests` — confirmed delivery and merchant transactions, Minh/Linh schedules, localized dialogue/journal, friendship, and save v4 migration

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
- Active request (2026-10-26): fix completely unclickable menus, then redesign title/HUD with cozy chibi art/icons and lightweight animated models; audit the whole project and proceed through missing milestones. User authorizes this broader visual scope. Immediate plan: reproduce physical mouse click failure; repair backdrop/input dispatch and start/continue entry; add SVG icons, generated title illustration and pastel UI; add procedural chibi presentation with gentle animation; verify real mouse/key paths and vi/en layouts at three sizes. Runtime scripts/assets only, no scene edits needed. File scope expands to scripts/view/, assets/icons/, assets/ui/, tests/unit/, docs/, localization/. Gameplay completion proceeds separately in Roadmap order; human gates cannot be asserted passed automatically.
- UI readability/overlap repair implemented after Phase 8 playtest screenshots; automated checks pass, human re-test pending.
- Approved execution process continues: record plan then implement without another approval. UI-only file scope: scripts/view/{main,debug_menu,hotbar_panel,inventory_panel,seed_shop_panel,shipping_bin_panel,start_menu,npc_actor,npc_system,ui_coordinator,ui_layout}.gd, their new .uid files, tests/unit UI regression/layout tests, localization/strings_{vi,en}.csv, docs/{API_INDEX,PROGRESS,UI_LAYOUT,DECISIONS}.md. No scene, shared Theme file, domain, economy, weather or save-schema changes.
- Plan: a view coordinator owns modal exclusivity/input/prompt suppression; a runtime layout/theme helper applies readable 18 px typography, responsive central panels and opaque surfaces using existing nodes; repair inventory/hotbar list sizing and permanent close/actions; test real key sequences, full inventory/shop lists, settings and modal switching at 1152x648, 1280x720, 1920x1080 in vi/en, then run official/headless suites and inspect rendered screenshots.
- Risks: old layout tests assume multiple simultaneous panels and tiny dimensions; update those expectations only where the new intentional modal/layout contract changes, retain all containment/readability checks. Runtime theme is duplicated, leaving the shared .tres outside the ALLOW_LIST untouched. Keep npc-quests tag intact; use a separate UI fix commit under the user's standing one-task/one-commit workflow.

## Chibi UI and mouse regression handoff
- Acceptance delivered: actual mouse clicks work in title/settings/new-game/inventory/shop; title always opens before gameplay; Continue accepts slot 0 or 1; New Game starts a clean farm/wallet/clock/onboarding/weather/social state; existing save v4 is unchanged.
- Root cause: ModalBackdrop was rendered behind buttons using z_index but placed after them in sibling GUI hit order. It intercepted mouse input. Now it is the first child, and modal/NPC input handlers leave mouse events to GUI. A regression test temporarily restoring the old order fails 0/2; fixed order passes. GUT overlay is excluded using an isolated SubViewport; tests inject real motion/left-button press/release events rather than emitting pressed signals.
- Visual delivery: assets/ui/title_valley.png generated with built-in image_gen (final prompt in title_valley.prompt.txt); 22 original SVG icons under assets/icons; cream/sage rounded theme; backpack/help/journal/pause and tool icons; item artwork in hotbar/inventory/shops; localized tooltips/full-name caption; compact icon bar; title art with subtle motes. The illustration is copied into the project and does not depend on the generation cache.
- Model delivery: ChibiAvatar procedural meshes for player/Minh/Linh, straw hat/backpack/face and idle/walk motion; WorldPresentation cottage, stall, shipping chest and ornamental trees. These are runtime mesh assemblies, not imported GLB files or completed character animation rigs. Domain state, collision anchors, season/weather/lighting profiles and scene files are unchanged. Title-art puppy is not a dog gameplay implementation.
- Windows computer-use verification completed on a separately launched game window: mouse-click Settings → New Game → Confirm → Got it → backpack icon → Close inventory. Observed clock advance from 06:00 to 06:26 and resume after closing. Closed only that verification window through its normal exit handler; editor was left open.
- Final full official runner:

```text
[check_parse] OK
[validate_data] PASS
Scripts              40
Tests               120
Passing Tests       120
Asserts            3781
Time              16.894s
---- All tests passed! ----
[run_tests] PASS
```

- Separate headless: 40 scripts / 120 tests / 120 passing / 3720 asserts / 8.928s. Final compact icon-bar layout rechecked afterwards: 2 scripts / 5 tests / 5 passing / 1278 asserts / 9.603s, both locales and three viewports. Current parse/validator/GUT/main/mouse/headless/final-UI logs: 0 SCRIPT ERROR / Parse Error / Failed to load script / ERROR: matches. git diff --check passes. Full-suite wrapper preserved/restored player slots 0/1 and backups byte-for-byte; new save-interaction tests preserve their own slot payloads too.
- UI tests were deliberately adapted only for new presentation semantics: hidden name labels no longer count as visible geometry (icons plus tooltips/caption replace them); weather HUD test enters gameplay because title screen now intentionally hides it. Original inventory, transaction, save, schedule and full-year invariants remain.
- Manual editor steps: none. Stop an old game instance and F5. Verify title click/New Game/Continue, backpack/help/journal/pause icons and close buttons; hover icons for labels; select keys 1–9; buy/sell; watch character idle/walk. Screenshots: docs/screenshots/chibi_title.png and chibi_hud.png. Human follow-up: play a 10–15 minute farm loop for Gate A evidence.
- Whole-project audit and remaining work: docs/PROJECT_AUDIT.md (phase coverage, source findings and execution order), docs/SOURCE_AUDIT.md (project-owned source/content inventory and methods). The game is still an MVP; economy ledger/orders, production/building, ecology/director, dog/story, full map/audio, export, online and release are not marked complete. Gate A/B require human/stranger playtests. Do not silently skip these gates or treat unchecked ROADMAP boxes as a reliable implementation inventory.
- Commit message for this task: `fix: restore mouse input and add cozy chibi presentation`. Review complete diff against 5c87cd5. Existing npc-quests tag is retained.

## UI repair results and handoff
- Fixed the reproduced inventory/pause/debug stack with UiCoordinator; one active panel through keys, HUD buttons and programmatic opens. Prompt and secondary HUD hide behind modal surfaces, Esc closes the active panel, I/H/J/Ctrl+M switch cleanly. New Game/help are separate; settings/name-entry forms are exclusive and repeated New Game clicks cannot duplicate Confirm.
- Duplicated runtime Theme: 18 px body, 24 px headings, opaque surfaces, 40+ px buttons; nine large hotbar slots with 16 px names, 18 px full-name caption and readable world NPC/home labels. All inventory slots remain in the scrollable inventory. Shop/bin changes affect list sizing and display only; transaction methods are unchanged.
- Fixed deferred minimum-size reflow so hidden/rebuilt content cannot leave oversized panels covering the HUD. Inventory close header, trade footer and debug close button stay available. Long lists and NPC text/actions scroll.
- Real official runner output (2026-10-26):

```text
[check_parse] OK
[validate_data] PASS
Scripts              39
Tests               115
Passing Tests       115
Asserts            3818
Time              12.166s
---- All tests passed! ----
[run_tests] PASS
```

- Separate headless GUT: 39 scripts / 115 tests / 115 passing / 3758 asserts / 6.147s. Rendered runs include 60 PNG-save assertions. Final scan of parse, validator, GUT, main, headless and UI capture logs: 0 matches for SCRIPT ERROR / Parse Error / Failed to load script / ERROR:. git diff --check passes. gdtoolkit remains unavailable and was not installed.
- Updated tests intentionally replace the old simultaneous-modal geometry assumptions with actual single-modal behavior, retain HUD non-overlap/containment, and add full inventory/shop lists, expanded pause/start settings, repeated New Game clicks, real modal shortcut sequences, viewport/button bounds, both languages and all three resolutions. Onboarding still checks every original binding and opt-out; it explicitly opens help after the start screen, matching the new exclusive flow.
- Manual editor steps: none. F5, start/continue, then I → Ctrl+M → H → J → Esc. Only one panel should appear, all text should be readable, Esc should return to play without another hidden menu. Open buy/sell panels, scroll lists, verify Close/Confirm stay visible; compare 1152x648/1280x720/1920x1080. Verify New Game/settings fields and scroll a full inventory. Human confirmation remains pending.
- Review diff: `git diff npc-quests..HEAD` after the separate UI commit. Commit message: `fix: improve UI readability and modal exclusivity`. No new milestone tag; existing npc-quests remains unchanged.
- Rendered evidence: user://ui_repair_{hud,InventoryPanel,PauseMenu,DebugMenu,TutorialPanel,SeedShopPanel,ShippingBinPanel,StartMenu}_{vi,en}_{1152x648,1280x720,1920x1080}.png; targeted capture uses -gopacity=0 so GUT does not obscure the game.

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
- [x] Hotbar slots use contained key/name/quantity labels without overlap at all supported viewport sizes
- [x] FarmView grid fits the brown FarmPlot and its projected centers avoid UI and the house at supported viewport sizes
- [x] Vietnamese is the default locale; item and crop names use translation keys with complete English/Vietnamese CSV coverage
- [x] Shared 14 px UI Theme, compact help modal, quest suppression and three-resolution all-panel layout tests
- [x] Official runner verified after UI polish: 21 scripts, 61 tests, 61 passing, 1185 asserts
- [x] Godot-generated `.uid` files are tracked project metadata and are not ignored
- [x] Pause menu, start menu, profile names, autosave slot 0 and save notification are implemented
- [x] Game-feel feedback includes animated item/invalid-action messages, soil response, crop growth stages and optional AudioService
- [x] NV1 pause/start menus include settings, profile naming, slot 0 autosave and save toast
- [x] NV2 optional audio naming is documented in `CREDITS.md`; missing audio files are silent
- [x] Autosave writes after exit, every 60 real seconds, and after debounced farm/inventory changes; Continue selects the newest valid save
- [x] Crop labels show localized remaining growth days, watering need and harvest readiness above each crop
- [x] DayNightProfile interpolates data keyframes and applies sun, moon, ambient, sky and house lighting to the gray-box world
- [x] WeatherState stores seeded current weather and forecast, rain waters crops, HUD/debug controls and placeholder rain FX are wired
- [x] Four data-defined 28-day seasons update GameClock, HUD and save state; crops reject wrong-season planting and can wither/clear
- [x] Distinct items and seeds for all 9 crops with differentiated buy/sell values, colors and DataValidator integrity checks
- [x] Season-based starter seeds guaranteed at new game start to prevent softlocks in the initial planting tutorial
- [x] WalletState domain state (coins, add, remove, can_afford, signals, serialize) with top-left WalletHud display
- [x] Shipping bin 3D interactable near house with [E] prompt, modal produce selector, quantity controls and immediate sale payouts
- [x] Seed shop 3D interactable with [E] prompt, current season filtering, out-of-season dimmed notes, and atomic transactions
- [x] Tutorial quest expanded to 7 steps (selling produce and buying seeds) and debug menu economy controls added (add coins, add all seeds)
- [x] Save schema bumped to save_version 3, backward-compatible migration for v1 and v2 saves, and save_v3 golden fixture
- [x] Integration test simulates an entire 4-season year: buying seeds, planting, watering, sleeping, harvesting and selling with non-negative wallet invariants
- [x] Official runner verified after economy milestone: 33 scripts, 97 tests, 97 passing, 2325 asserts
- [x] Phase 8 request: confirmed all-or-nothing delivery through existing wallet/inventory APIs; no shortage consumption, no duplicate payout, reward capacity checked after removal
- [x] Minh's seeded daily resource offers; finite stock persists across load; original item prices and existing full-year simulation unchanged
- [x] Minh/Linh placeholder actors follow AStarGrid2D routes, seasonal/weekly schedules, DayNightProfile night threshold and rain/home override
- [x] E dialogue, J journal, named NPCs, explicit quest/trade buttons, localizable feedback, debug quick-test buttons and modal input/clock locking
- [x] Save v4 social payload and v3 migration; old golden v1/v2/v3 retained; active/completed quests, friendships, heard dialogue, talk days, positions and used merchant offers round-trip
- [x] Final official runner: 39 scripts / 113 tests / 113 passing / 2850 asserts; parse/validator/main smoke PASS; headless GUT: 113 passing / 2838 asserts (12 PNG assertions apply only to rendered runs)

## Known issues / tech debt
- GUT 9.7.1 is installed under `addons/gut` for Godot 4.7.x.
- NPCs and their homes are simple placeholders; interiors, dog and Chapter I quest content are outside this slice. NPCs walk home before hiding; indoors NPCs cannot be spoken to in this placeholder version.
- Night follows the shared profile's moon-energy threshold (0.14 in NPC data), so it overrides Minh's nominal 22:00 visit end. Scheduled visits remain days 3/6 of each week, per Roadmap and D21.
- Dialogue pauses the clock; no periodic save while it is open. Closing marks the save dirty; exiting closes it and then saves at a safe point.

## Decisions since last update
- D08 and D13 confirmed from the submitted project form.
- Placeholder geometry is allowed until the developer supplies final models.
- HUD layout is documented in `docs/UI_LAYOUT.md`; prompt sits above the hotbar and inventory is centered with a close button.
- Hotbar item slots use a two-row responsive container and reserve space above the bottom HUD regions.
- Farm grid cells are inside the brown plot; red target highlighting means the selected tool is out of reach, green means usable.
- Player-facing item and crop names are stored as translation keys and rendered through `tr()`; Vietnamese is selected on startup when no settings override exists.
- UI uses `scenes/main/ui_theme.tres`; the help panel is limited to 36% viewport width and hides the quest panel while open.
- Pause and start overlays use the same Theme and are included in the documented modal layout; start menu blocks world input until a game is started or continued.
- While sleeping, debug set-time, set-speed, pause and next-day actions are ignored. This keeps the sleep state deterministic and prevents a debug action from leaving the player locked or the clock stuck at x20.
- Autosave uses slot 1 for active-progress recovery and selects the newest valid save between slots 0 and 1 using `saved_utc`.
- Crop status is rendered as world-space billboard `Label3D` with depth testing disabled so it remains readable above placeholder crops.
- The requested day/night, weather and season work is intentionally being delivered before Roadmap phases 7 and 11 per D19.
- Save schema is now v3: wallet is persisted, and v1/v2 saves migrate smoothly with default starting coins per D20.
- Out-of-season seeds in the seed shop are displayed dimmed and disabled with a localized season note to guide player purchasing.

## Open `<<FILL>>` items (must be empty before roadmap task 0.1)
- gdtoolkit 4.3.0 is selected but not installed yet

## Next up (agent proposal)
- MVP farming loop and the requested first polish pass are complete; final models and audio assets remain developer-supplied.
- Human: run the Phase 8 manual checklist below. Do not advance to dog/Chapter I or change the Roadmap status based on automated tests alone.

## Phase 8 execution plan (approved by product owner, 2026-10-26)
- Task 4 save domain verified: v4 social payload, explicit migrate_3_to_4, old golden fixtures retained, golden v4 added; v1/v2/v3 preserve onboarding/profile/farm/inventory/clock/player and wallet/weather. Dedicated tests cover unknown ids/types, friendship clamping, daily talk persistence, completed quests and merchant consumed days. The final headless run passes 39 scripts / 113 tests / 2838 asserts. Existing save-version assertions now expect v4 deliberately, with all original field checks retained.
- Task 3 domain verified: 36 scripts / 105 tests / 105 passing / 2667 asserts; full runner PASS. Four seasons, weekly visits, rain/night home override, obstacle avoidance and rebuilt routes after load covered. Fixed a signal-lambda reference cycle found by the error-log scan; final run has no resource-leak error. NPC visuals/dialogue are integrated in Task 4.
- Task 2 verified: 35 scripts / 103 tests / 103 passing / 2373 asserts; all runner stages PASS, including unchanged full-year economy simulation. Merchant stock is saved and finite; discount/request prices are isolated. Added missing DetRandom under the allowed domain folder (no existing implementation existed). Initial new-class cache error resolved by headless editor import; corrected an incorrectly transcribed golden seed against independent integer calculation (1466485800), no production algorithm changed for the test.
- Task 1 verified: 34 scripts / 100 tests / 100 passing / 2345 asserts; parse, data validation and main smoke PASS. Delivery preview accounts for exact freed slots; confirmation rejects null wallet, shortage, oversized rewards and duplicate/reentrant payout.
- Baseline: parse, validator, main smoke and GUT pass: 33 scripts / 97 tests / 2325 asserts; error-text scan zero matches. Existing NPC/quest base is committed separately; it is not yet integrated or covered by dedicated tests.
- Task 1: harden `scripts/domain/quests/quest_manager.gd`, add delivery tests in `tests/unit/`: explicit confirmation, all-or-nothing requirements/rewards using existing wallet/inventory APIs, reject duplicate payout and full reward inventory.
- Task 2: `scripts/data/merchant_offer_data.gd`, `data/npcs/`, `data/shops/`, `scripts/domain/quests/merchant_service.gd`: data-defined daily offer, deterministic selection, independent pricing; preserve the existing full-year test unchanged.
- Task 3: NPC/dialogue data and pure schedule/relationship/dialogue state under `scripts/data/` and `scripts/domain/quests/`; AStarGrid2D routes from data-defined cell locations, home at night and in rain, four-season and load tests. Views only animate routes.
- Task 4: `scripts/core/save_service.gd`, `scripts/view/main.gd`, new NPC UI/view scripts, `scenes/main/main.tscn` additions only, localization, validator and tests: integrate NPC dialogue/journal (J), debug actions, v4 social payload and v3 migration preserving onboarding, golden v4; layout checks at 1152x648, 1280x720 and 1920x1080.
- Documentation: API_INDEX, PROGRESS, DECISIONS, UI_LAYOUT, INPUT_MAP; no edits to farm/tools/weather/day-night/wallet/shop/bin implementations, no additional autoloads, no registry changes beyond the already committed base.
- Scope follows Roadmap 8.1–8.4 for this request; 8.5 dog and 8.6 Chapter I content remain separate tasks. Merchant visits obey the Roadmap schedule; a daily offer is selected every day but is available only while Minh is at the market. Night/rain override visits. See D21.
- Risks: atomic delivery must preview inventory after removal; retain the existing `quests` onboarding save field and add a separate social payload; modal UI must prevent world input and unsafe saves. Manual editor playtest remains human verification.

## How to run
- Parse check: `tools/check_parse.sh` (macOS/Linux) or `tools\check_parse.bat` (Windows). Set the `GODOT` env var to your Godot executable.
- All tests: `tools/run_tests.sh` / `tools\run_tests.bat`; Windows official runner uses the pinned Godot executable and bounded processes, with error-text scans.
- Main scene: `scenes/main/main.tscn` (F5). No manual node/Inspector/InputMap changes are required for Phase 8; additions are in the allowed main scene, while existing E/J/Esc actions are reused.

## Phase 8 handoff and manual checklist
- Acceptance: delivery changes inventory only on explicit confirmation with enough items and reward room; merchant quote is data-defined, finite and isolated; every season respects rain/night home schedules; v3 load keeps previous progress and v4 social state survives save/load.
- [ ] F5, start/continue, dismiss help; press J, close with J/Esc, check that movement/clock/HUD resume.
- [ ] Ctrl+M → Test Minh visit; close debug menu; E near Minh → accept quest. With fewer than 3 turnips, confirm is disabled and nothing is removed.
- [ ] Ctrl+M → add delivery turnips; close menu; E → confirm delivery. Exactly 3 turnips leave inventory; 60 coins and 2 spring carrot seeds arrive once. Check full-inventory blocking, including space freed by delivery.
- [ ] Confirm Minh's daily discount/request; compare the normal shop/bin price before/after. Repeat today and after save/load: no second trade. Advance to a new visit day: stock is available again.
- [ ] Use existing debug weather/time controls: rain and 20:00 send NPCs home; resume sunny daytime and observe routes around farm/buildings. Check all four seasons; Linh's warm/cool season destinations differ.
- [ ] Save with an active quest and after completing it, exit/Continue, inspect J: friendship and quest state persist; dialogue reflects the restored quest condition. `social.heard` in save JSON keeps heard dialogue ids. Repeated talk/load on the same day adds no extra friendship.
- [ ] Repeat dialogue/journal at 1152x648, 1280x720 and 1920x1080; scroll long English text/actions. Esc closes the NPC modal without opening Pause; I/H/Ctrl+M do not open another modal over it.
- Assumptions: small declared static navigation grid, no dynamic building placements in this milestone; home boxes are presentation markers and NPC navigation does not share player physics. Daily offers are deterministic from saved seed/day and shipped data.
- Rendered evidence: `user://npc_dialogue_{vi,en}_{1152x648,1280x720,1920x1080}.png` and matching `npc_journal_...png`; generated by test_npc_ui. Visual QA sampled both languages at all three sizes using GUT `-gopacity=0` to keep the runner overlay out of screenshots.
- Full code diff for review: `git diff 57c9bde..npc-quests` (includes the pre-existing base committed at Step 0); commit log separates base, docs, delivery, merchant, schedules, save migration and UI integration. Extra metadata-only Step 0 commit: 57c9bde; item_data.gd's missing final newline was restored with no resulting content diff.
- Proposed/used one-line integration commit: `feat: integrate NPC dialogue journal and validated trade UI`.

## Exact Phase 8 file manifest (relative to 57c9bde)

Created (includes the pre-existing NPC/quest base):

```text
data/npcs/phase8_world.tres
data/quests/quest_turnip_delivery.tres
data/shops/minh_autumn_discount.tres
data/shops/minh_spring_discount.tres
data/shops/minh_summer_discount.tres
data/shops/minh_turnip_request.tres
data/shops/minh_winter_discount.tres
scripts/data/dialogue_data.gd
scripts/data/dialogue_data.gd.uid
scripts/data/merchant_offer_data.gd
scripts/data/merchant_offer_data.gd.uid
scripts/data/npc_data.gd
scripts/data/npc_data.gd.uid
scripts/data/npc_schedule_entry.gd
scripts/data/npc_schedule_entry.gd.uid
scripts/data/npc_world_data.gd
scripts/data/npc_world_data.gd.uid
scripts/data/quest_data.gd
scripts/data/quest_data.gd.uid
scripts/data/world_locations.gd
scripts/data/world_locations.gd.uid
scripts/domain/quests/det_random.gd
scripts/domain/quests/det_random.gd.uid
scripts/domain/quests/merchant_service.gd
scripts/domain/quests/merchant_service.gd.uid
scripts/domain/quests/npc_schedule.gd
scripts/domain/quests/npc_schedule.gd.uid
scripts/domain/quests/npc_social_state.gd
scripts/domain/quests/npc_social_state.gd.uid
scripts/domain/quests/quest_manager.gd
scripts/domain/quests/quest_manager.gd.uid
scripts/view/npc_actor.gd
scripts/view/npc_actor.gd.uid
scripts/view/npc_panel.gd
scripts/view/npc_panel.gd.uid
scripts/view/npc_system.gd
scripts/view/npc_system.gd.uid
tests/golden_saves/save_v4.json
tests/unit/test_merchant_service.gd
tests/unit/test_merchant_service.gd.uid
tests/unit/test_npc_data_validation.gd
tests/unit/test_npc_data_validation.gd.uid
tests/unit/test_npc_quest_delivery.gd
tests/unit/test_npc_quest_delivery.gd.uid
tests/unit/test_npc_schedule.gd
tests/unit/test_npc_schedule.gd.uid
tests/unit/test_npc_social_save.gd
tests/unit/test_npc_social_save.gd.uid
tests/unit/test_npc_ui.gd
tests/unit/test_npc_ui.gd.uid
```

Modified:

```text
docs/API_INDEX.md
docs/DECISIONS.md
docs/INPUT_MAP.md
docs/PROGRESS.md
docs/UI_LAYOUT.md
localization/strings_en.csv
localization/strings_vi.csv
scenes/main/main.tscn
scripts/core/data_registry.gd
scripts/core/data_validator.gd
scripts/core/save_service.gd
scripts/view/main.gd
tests/unit/test_save_service.gd
tests/unit/test_weather.gd
tools/validate_data.gd
```

Real final runner output:

```text
[check_parse] OK
[validate_data] PASS
Scripts              39
Tests               113
Passing Tests       113
Asserts            2850
Time              5.728s
---- All tests passed! ----
[run_tests] PASS
```

Separate headless GUT: 39 scripts, 113 tests, 113 passing, 2838 asserts, 4.094s. Final error-text scan: 0 matches across parse, validator, GUT, main, headless and NPC UI logs. Human manual playtest is still pending; gdtoolkit lint was not run (not installed).

Exact UI repair files:

```text
docs/API_INDEX.md
docs/DECISIONS.md
docs/PROGRESS.md
docs/UI_LAYOUT.md
localization/strings_en.csv
localization/strings_vi.csv
scripts/view/debug_menu.gd
scripts/view/hotbar_panel.gd
scripts/view/inventory_panel.gd
scripts/view/main.gd
scripts/view/npc_actor.gd
scripts/view/npc_system.gd
scripts/view/seed_shop_panel.gd
scripts/view/shipping_bin_panel.gd
scripts/view/start_menu.gd
scripts/view/ui_coordinator.gd
scripts/view/ui_coordinator.gd.uid
scripts/view/ui_layout.gd
scripts/view/ui_layout.gd.uid
tests/unit/test_hotbar_layout.gd
tests/unit/test_npc_ui.gd
tests/unit/test_onboarding.gd
tests/unit/test_ui_layout.gd
```

Exact files for click/chibi task (relative to 5c87cd5):

```text
assets/icons/ui_backpack.svg
assets/icons/ui_backpack.svg.import
assets/icons/ui_cabbage.svg
assets/icons/ui_cabbage.svg.import
assets/icons/ui_carrot.svg
assets/icons/ui_carrot.svg.import
assets/icons/ui_close.svg
assets/icons/ui_close.svg.import
assets/icons/ui_coin.svg
assets/icons/ui_coin.svg.import
assets/icons/ui_corn.svg
assets/icons/ui_corn.svg.import
assets/icons/ui_harvest.svg
assets/icons/ui_harvest.svg.import
assets/icons/ui_help.svg
assets/icons/ui_help.svg.import
assets/icons/ui_hoe.svg
assets/icons/ui_hoe.svg.import
assets/icons/ui_journal.svg
assets/icons/ui_journal.svg.import
assets/icons/ui_pause.svg
assets/icons/ui_pause.svg.import
assets/icons/ui_pea.svg
assets/icons/ui_pea.svg.import
assets/icons/ui_play.svg
assets/icons/ui_play.svg.import
assets/icons/ui_pumpkin.svg
assets/icons/ui_pumpkin.svg.import
assets/icons/ui_radish.svg
assets/icons/ui_radish.svg.import
assets/icons/ui_seed.svg
assets/icons/ui_seed.svg.import
assets/icons/ui_settings.svg
assets/icons/ui_settings.svg.import
assets/icons/ui_sun.svg
assets/icons/ui_sun.svg.import
assets/icons/ui_tomato.svg
assets/icons/ui_tomato.svg.import
assets/icons/ui_turnip.svg
assets/icons/ui_turnip.svg.import
assets/icons/ui_watering_can.svg
assets/icons/ui_watering_can.svg.import
assets/icons/ui_wheat.svg
assets/icons/ui_wheat.svg.import
assets/ui/title_valley.png
assets/ui/title_valley.png.import
assets/ui/title_valley.prompt.txt
docs/API_INDEX.md
docs/CREDITS.md
docs/DECISIONS.md
docs/PROGRESS.md
docs/PROJECT_AUDIT.md
docs/screenshots/chibi_hud.png
docs/screenshots/chibi_title.png
docs/SOURCE_AUDIT.md
docs/UI_LAYOUT.md
localization/strings_en.csv
localization/strings_vi.csv
scripts/view/chibi_avatar.gd
scripts/view/chibi_avatar.gd.uid
scripts/view/hotbar_panel.gd
scripts/view/inventory_panel.gd
scripts/view/main.gd
scripts/view/npc_actor.gd
scripts/view/npc_system.gd
scripts/view/seed_shop_panel.gd
scripts/view/shipping_bin_panel.gd
scripts/view/start_menu.gd
scripts/view/title_backdrop.gd
scripts/view/title_backdrop.gd.uid
scripts/view/tutorial_panel.gd
scripts/view/ui_coordinator.gd
scripts/view/ui_icons.gd
scripts/view/ui_icons.gd.uid
scripts/view/ui_layout.gd
scripts/view/world_presentation.gd
scripts/view/world_presentation.gd.uid
tests/unit/test_hotbar_layout.gd
tests/unit/test_ui_mouse.gd
tests/unit/test_ui_mouse.gd.uid
tests/unit/test_weather.gd
```
