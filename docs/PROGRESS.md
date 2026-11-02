# PROGRESS — THE LIFE  (agent memory: read first, update last)

Last updated: 2026-11-02 (ISO-1 active 2D runtime delivered; automated checks pass, human editor playtest pending)

## Current milestone

`ISO-1 (2D isometric runtime)` — implementation delivered; final official runner passes 62/62 headless tests and 164/164 complete renderer tests, plus parse/data/main checks. Human editor playtest is pending. See the ISO-1 handoff below for the exact files, save compatibility, real output and manual tests. ISO-2 UI theme/gallery remains next, outside this code scope.

## Previous milestone

`ISO-0 (2D isometric migration specification)` — documentation delivered under the twelve-file scope approved by the owner's instruction “tôi đã bổ sung tài liệu ... bắt đầu đi”. D33–D35 supersede the old 3D target and stage later UI/data changes. No runtime script, scene, project setting, font, translation, domain object or save schema has changed. ISO-1 source work was subsequently approved by “oke tiếp tục”, with the explicit pause_menu.gd scope extension recorded below. The ISO-0 ROADMAP row stays in review for the human to tick.


## ISO-1 handoff — active 2D runtime (2026-11-02)

Acceptance delivered by automation:
- Active Main gameplay tree has zero Node3D descendants. Player is CharacterBody2D with its child Camera2D; eight collision names moved to 2D, Jolt project override removed, 1152×648/canvas_items/keep configured.
- Ground/Farmland share a generated 64×32 isometric Diamond Down TileSet. Cell picking, mouse position and screen/global round trips pass with negative cells, zoom/pan and a transformed layer. Grounded actor/crop/tree y-sort and swept house-footprint collision are checked.
- FarmGridState, inventory/wallet, GameClock/day simulation, weather, NPC/social/merchant logic, crop values/yield, save v4, existing InputMap/autoloads/font remain in use. No domain file was changed. Physical GUI click, modal, farming drag/inspection, transaction, old-save and vi/en three-size layout regressions run in the complete suite.
- ISO-1 is implemented and verified; human editor playtest is still pending, so ROADMAP ISO-1 remains in review. ISO-2 wooden Theme/fonts/gallery and later HUD/inventory/balance steps have not been started.

Implementation diff summary:
- Main/three scenes: CanvasLayer 1 keeps existing UI child paths; WorldCanvas 0 follows Camera2D. World children move under WorldCanvas; actors/crops/homes and passive art use Objects with nested y-sort. Typed main/world references replace active 3D APIs.
- New data/view files: IsometricWorldConfig and two Resources own map/reach/zoom/speeds; IsometricGrid delegates projection to Godot; PlaceholderAvatar2D/PlaceholderWorld2D are replaceable art only.
- Farm presentation: TileMapLayer terrain, Polygon2D soil decorations, cached Sprite2D growth textures, localized hidden Label status, transformed-sprite picking, transient bounded 2D effects. No growth or inventory authority moved into a view.
- NPC views: state stays under NpcSystem; actors/homes render under Objects, exposed through its actors/homes dictionaries. Existing Vector3 location Resources and GridMath remain pure legacy logical adapters; no TileMapLayer enters DOMAIN.
- Save compatibility: actual old v4 player.position.x/y/z is retained. The current 2D position resolves to a cell, saves its legacy center, and restores into the corresponding 2D cell. Old fractional offsets snap to a cell center; invalid numeric fields fall back to data-owned spawn and out-of-bounds cells clamp. SaveService/schema and golden saves were not edited.
- PauseMenu's approved extra change replaces its old GrayBoxWorld/Player lookup with the typed GrayBoxWorld.player reference. WeatherFx listens to time_changed as well as weather/season, so direct set_time changes day/night effects immediately.
- Test migration keeps archive-generated model/shader/animation audits. Only obsolete live 3D mesh/light/camera assertions are replaced by meaningful 2D state/picking/tint/canvas equivalents. Seven new tests cover migration-specific invariants. No test was skipped or weakened.
- Runner: parse → validator → headless domain/2D suite → COMPLETE renderer GUT → main headless. The bounded process helper hides windows, isolates APPDATA/user data under TEMP, retains the native process handle and propagates engine failures reliably.

Exact authored files created/modified (includes the earlier ISO-0 documentation carried in this working tree; twelve entries are new files including five generated .uid companions):
```text
AGENTS.md
docs/API_INDEX.md
docs/ARCHITECTURE.md
docs/CODE_PATTERNS.md
docs/COLLISION_LAYERS.md
docs/DECISIONS.md
docs/INPUT_MAP.md
docs/PROGRESS.md
docs/PROJECT_RULES.md
docs/ROADMAP.md
docs/SCENE_CONTRACTS/gray_box_world.md
docs/SCENE_CONTRACTS/player.md
project.godot
scenes/main/main.tscn
scenes/player/player.tscn
scenes/world/gray_box_world.tscn
scripts/core/data_validator.gd
scripts/player/player.gd
scripts/player/player_config.gd
scripts/view/camera_rig.gd
scripts/view/crop_presentation.gd
scripts/view/debug_menu.gd
scripts/view/farm_effects.gd
scripts/view/farm_view.gd
scripts/view/gray_box_world.gd
scripts/view/main.gd
scripts/view/npc_actor.gd
scripts/view/npc_system.gd
scripts/view/pause_menu.gd
scripts/view/soil_presentation.gd
scripts/view/tool_action_controller.gd
scripts/view/weather_fx.gd
scripts/view/world_presentation.gd
tests/unit/test_chibi_characters.gd
tests/unit/test_chibi_farming.gd
tests/unit/test_chibi_world.gd
tests/unit/test_crop_inspector.gd
tests/unit/test_day_night.gd
tests/unit/test_drag_farming.gd
tests/unit/test_farm_layout.gd
tests/unit/test_farm_view.gd
tests/unit/test_game_feel.gd
tests/unit/test_interaction_range.gd
tests/unit/test_move_dir.gd
tests/unit/test_project_config.gd
tests/unit/test_seed_shop.gd
tests/unit/test_shipping_bin.gd
tests/unit/test_tool_action.gd
tests/unit/test_weather.gd
tests/unit/test_world_presentation.gd
tools/run_godot_bounded.ps1
tools/run_tests.bat
tools/validate_data.gd
data/isometric_world_config.tres
data/player_2d_config.tres
scripts/data/isometric_world_config.gd
scripts/data/isometric_world_config.gd.uid
scripts/view/isometric_grid.gd
scripts/view/isometric_grid.gd.uid
scripts/view/placeholder_avatar_2d.gd
scripts/view/placeholder_avatar_2d.gd.uid
scripts/view/placeholder_world_2d.gd
scripts/view/placeholder_world_2d.gd.uid
tests/unit/test_isometric_migration.gd
tests/unit/test_isometric_migration.gd.uid
```

The owner's untracked the_life_prompt.md and docs/ui_reference PNGs remain inputs, not authored game assets. Godot's editor scan generated ordinary .png.import metadata beside the supplied references; no reference PNG was edited, renamed or used at runtime. Generated 3D assets/shaders/builders remain unchanged. Captures are ignored review outputs, not source edits. Full tracked patch: git diff -- AGENTS.md docs project.godot scenes scripts tests tools; inspect the twelve listed new files alongside it. No commit/push was run.

Real final official runner output:
```text
[check_parse] OK
[validate_data] PASS

Headless domain/2D:
Scripts              16
Tests                62
Passing Tests        62
Asserts             849
Time              2.973s
---- All tests passed! ----

Complete renderer suite:
Scripts              53
Tests               164
Passing Tests       164
Asserts            5366
Time              23.447s
---- All tests passed! ----

[run_tests] starting main scene headless
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org
[run_tests] PASS
```

Run from project root: tools\run_tests.bat (GODOT can point to D:\godot\Godot_v4.7.2-stable_win64_console.exe). Logs: TEMP/the_life_parse.log.*, the_life_validate.log.*, the_life_headless.log.*, the_life_gut.log.*, the_life_main.log.*. The intentional missing-script runner probe returned exit 1, confirming failure propagation; its expected error log is separate (the_life_iso1_expected_failure.log.*), not a successful validation log.

Final parse/validator/headless/full-suite/main/capture error-text scan: 0 matches for SCRIPT ERROR, Parse Error, Failed to load script or ERROR:. GUT still reports the same pre-existing two orphan Labels in test_inventory_ui and one in test_pause_menu as the ISO-0 baseline; the new migration test has no orphan warning. These are not claimed fixed or hidden. gdtoolkit lint was not run or installed.

Visual review:
- Normal Forward+/D3D12 capture flags produced screenshots/chibi-ui/chibi_ui_title.png and chibi_ui_hud.png, plus screenshots/chibi-farming/chibi_farming_main_scene.png. HUD and populated-farm captures were visually inspected at 1152×648: world is 2D with clear farm cells, grounded characters/buildings/trees and unchanged readable C4 UI. This is placeholder verification, not final mockup-art acceptance or a performance benchmark.
- Existing capture flag/tool names remain for compatibility; they now capture the 2D main scene. Historical 3D lineup tools/assets remain available separately.
- Capture logs: TEMP/the_life_iso1_capture.log.* and the_life_iso1_farming_capture.log.*.

Manual editor steps / test cases:
1. Stop an old running game, reload externally changed scenes if Godot prompts, open scenes/main/main.tscn and F5. No manual node construction, InputMap or Inspector change is required.
2. Continue an existing v4 save and confirm inventory/coins/crops/social progress. The player's position restores to the center of its saved logical cell.
3. WASD/arrows and Shift: movement follows screen axes; diagonals have no speed bonus in uncompressed movement space. Walk into a house blocker; it must stop/slide. Use = / - to zoom and check hover/click targeting at each level.
4. Select a seed in inventory (I/Tab), hoe/plant/water reachable plots, inspect the top of a plant, drag water/harvest, and verify quantities. Full inventory must leave a harvestable crop in place.
5. Near shop/bin use E; buy/sell and verify coins/items. Use existing debug visit for Minh, talk/deliver and verify journal/save progress. Change clock/weather: night tint/windows/rain follow real state; rain waters crops.
6. I/H/J/Esc and actual mouse buttons: one modal at a time, no world action beneath a modal, Pause closes/unlocks correctly, HUD stays fixed while the camera moves. Sleep when allowed and reload; day/crop/season state must remain consistent.
7. Compare vi/en and 1152×648, 1280×720, 1920×1080 as in automated layout coverage. Human gameplay acceptance and Gate A/B evidence remain outstanding.

Assumptions/known limits:
- Art is intentionally simple placeholder drawing/textures; detailed crops, seasonal critters, house lighting and final sprites remain replaceable. Current UI is still C4/Open Sans, not the new mockup Theme. Stamina remains absent/hidden.
- Legacy NPC Resources and save wire coordinates still use Vector3 data, while the active gameplay tree has no 3D nodes. This is intentional compatibility, not an alternate rendering path.
- New players use data-owned 2D movement/zoom/map values. Gameplay crop prices/timing/yield/capacity are untouched. Later tomato regrow/fertilizer/house-unlock requirements still need their own specification.
- Automated captures do not substitute for the owner's editor playtest. No unapproved future milestone, package install, git commit or git push is included.

Next: owner editor playtest of ISO-1; then define/approve ISO-2's UI resource/source allow list before building the shared Theme, font imports/components and gallery. Proposed commit: feat: migrate active gameplay to 2D isometric placeholders

## ISO-0 acceptance, changes and verification (2026-11-02)

- Acceptance delivered: reconcile old locked 3D rules with the requested 2D target; document scene/movement/grid/collision/UI boundaries; account for sixteen mockups; preserve current runtime API truth; define the staged migration and a reviewable source-scope proposal. No new test file is needed for specification-only changes; existing checks were run as a baseline, not evidence of a completed 2D game.
- Decisions: D33 selects 64×32 isometric tiles, CharacterBody2D/child Camera2D, TileMapLayer conversions, eight 2D collision layers and 1152×648 design size. D34 selects the wooden/paper shared Theme, placeholder strategy, later font/shortcut migration and hidden unsupported stamina UI. D35 stages the prompt's calendar/crop/price/inventory changes for their own tested tasks. Historical decisions are retained with superseded statuses where appropriate.
- Exact modified files (all inside the approved scope): `AGENTS.md`; `docs/PROJECT_RULES.md`; `docs/DECISIONS.md`; `docs/ARCHITECTURE.md`; `docs/ROADMAP.md`; `docs/INPUT_MAP.md`; `docs/COLLISION_LAYERS.md`; `docs/CODE_PATTERNS.md`; `docs/SCENE_CONTRACTS/player.md`; `docs/SCENE_CONTRACTS/gray_box_world.md`; `docs/API_INDEX.md`; `docs/PROGRESS.md`.
- Clear change summary: replace the normative 3D/XZ/camera-yaw target with a 2D target; retain legacy implementations as explicitly labelled migration references. Add ISO-0–ISO-7 sequencing and future acceptance. Separate current InputMap/API tables from planned bindings/types; preserve DOMAIN and save ownership. Correct the player contract's stale config path: the actual class is `scripts/player/player_config.gd`; `data/player_config.tres` does not exist. Full patch is reviewable with `git diff -- AGENTS.md docs` (reference PNGs and the owner's untracked prompt are untouched).
- Manual editor steps for ISO-0: none. Do not change project settings/scenes piecemeal to the target before ISO-1 code lands. After ISO-1, editor/manual acceptance must cover foot-level sorting/collision, picking at negative cells/zoom, WASD/Shift, modal input locks, farm planting/watering/harvest, full inventory, shop/bin/NPC interaction, sleep and v4 save/load.
- Known limits: selected new font files/licenses are not imported/verified yet; final frame/icon/sprite PNG assets are not supplied (use placeholders). Tomato regrow interval, fertilizer behavior and house-level unlock integration still need specification in ISO-6. Existing autoload count/schema documentation has historical differences from runtime; preserve actual registered autoloads during ISO-1 rather than performing an unrelated cleanup. Existing art tests include renderer-dependent assertions, so a full dummy-renderer headless run is currently not viable.

### Supplied reference inventory (read-only)

The owner supplied all files below. Header inspection found each numbered screen 01–15 is **2304×1296** (exactly 2× the 1152×648 design frame). Overview is **2536×3246**. No resize/rename is needed; layout measurements use the design frame. Overview and UI kit were visually inspected during ISO-0; other individual screens still require visual review in their corresponding implementation task. Mockups are references only, not runtime textures.

```text
docs/ui_reference/00-tong-quan-giao-dien.png
docs/ui_reference/01-menu-chinh.png
docs/ui_reference/02-tao-nhan-vat.png
docs/ui_reference/03-trong-game-ban-ngay.png
docs/ui_reference/04-trong-game-dem-mua.png
docs/ui_reference/05-ban-tin-sang.png
docs/ui_reference/06-tui-do.png
docs/ui_reference/07-nhan-vat.png
docs/ui_reference/08-so-nhiem-vu.png
docs/ui_reference/09-lich-su-kien.png
docs/ui_reference/10-cua-hang.png
docs/ui_reference/11-nang-cap-nha.png
docs/ui_reference/12-hoi-thoai.png
docs/ui_reference/13-ket-thuc-ngay.png
docs/ui_reference/14-tam-dung-cai-dat.png
docs/ui_reference/15-bo-ui-kit.png
```

### Real ISO-0 baseline results

Engine: `D:\godot\Godot_v4.7.2-stable_win64_console.exe` (version `4.7.2.stable.official.ed1daf0bf`). Parse and validator used an isolated APPDATA under `%TEMP%/the_life_iso0_appdata`; GUT used the same isolated user data to avoid touching player saves/settings. Main headless smoke subsequently ran against the unchanged main scene. No commit/push was run.

Initial sandbox parse/validator emitted `ERROR: Failed to read the root certificate store.`; the same commands rerun with approved escalation exited 0 without this error. Real validator output:

```text
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org
[validate_data] PASS
```

Headless GUT was attempted with `--headless --path . --script addons/gut/gut_cmdln.gd -gdir=res://tests/unit -gprefix=test_ -gexit`. It did NOT complete: existing `test_generated_shaders_and_materials_load_and_bind_to_a_viewport` in `test_chibi_art_foundation.gd` waits for `RenderingServer.frame_post_draw`, which the dummy renderer does not deliver. Only the matching test process was stopped after verifying its command line; the pre-existing editor was left alone. No test was skipped, weakened or changed. This is a harness limitation, not a headless pass.

Full GUT was rerun with the configured normal Forward+ renderer, hidden window and 120-second bound. Real final output (exit 0):

```text
Scripts              52
Tests               157
Passing Tests       157
Asserts            5146
Time              30.372s
---- All tests passed! ----
```

Logs: `%TEMP%/the_life_iso0_rendered.stdout`, `.stderr`; interrupted headless log: `%TEMP%/the_life_iso0_gut.log`. `--headless --path . --quit` and `--headless --path . --quit-after 120` both exited 0 outside the sandbox with no script/parse/error text. No manual gameplay or visual 2D test is claimed. Final review: `git diff --check` exit 0; rendered GUT logs have 0 matches for `SCRIPT ERROR|Parse Error|Failed to load script|ERROR:` and 1 all-tests-passed summary. Exactly the twelve approved documentation files are modified; the owner's sixteen reference images and `the_life_prompt.md` remain untracked and untouched. Suggested ISO-0 commit: `docs: specify 2D isometric migration and mockup UI stages`.

### ISO-1 source plan / approved ALLOW_LIST (2026-11-02)

Source scope was authorized by the owner's “oke tiếp tục”; the owner additionally approved scripts/view/pause_menu.gd through the scope-extension question. This records the plan that was executed. Convert active gameplay scenes in place, preserve their resource paths and UI/modal entry points, replace active 3D art with code placeholders, and leave generated art/review archives intact. Keep logical farm cells and existing services. Adapt NPC location conversion explicitly without giving TileMapLayer to domain routing; preserve save v4 unless the actual payload requires migration. Do not change crop balance, inventory capacity, fonts, shortcuts or final mockup layout in ISO-1.

Approved source scope (brace groups enumerate files; `tests/unit/**` permits only relevant regression updates/additions, never skipping or weakening assertions):

```text
project.godot
scenes/main/main.tscn
scenes/world/gray_box_world.tscn
scenes/player/player.tscn
scripts/player/{player,player_config}.gd
scripts/util/grid_math.gd
scripts/data/{world_locations,isometric_world_config}.gd
scripts/domain/quests/npc_schedule.gd
scripts/core/data_validator.gd
scripts/view/{main,gray_box_world,camera_rig,farm_view,crop_presentation,soil_presentation,farm_effects,tool_action_controller,tool_drag_stroke,debug_menu,npc_actor,npc_system,world_presentation,weather_fx,isometric_grid,placeholder_avatar_2d,placeholder_world_2d}.gd
scripts/view/pause_menu.gd (explicit owner-approved scope extension)
data/{isometric_world_config,player_2d_config}.tres
data/npcs/phase8_world.tres
tools/{run_tests.bat,check_parse.bat,run_godot_bounded.ps1,validate_data.gd}
tests/unit/**
Godot-generated .uid companions for new source/test files above
the same twelve documentation files listed in ISO-0
```

The isometric config/grid/placeholder paths above were approved as new files and now exist. Implemented exports/methods/node contracts are recorded in API_INDEX and the scene contracts. Existing `world_art_factory`, chibi mesh/face/bubble/seasonal-3D helpers and generated scenes can remain historical tools; active world/player/NPC code must stop instantiating them. If source inspection proves another file is required, request a scope extension before modifying it.

Acceptance: no Node3D in the active gameplay tree; correct 64×32 map/local round trips including negative cells and camera/layer transforms; normalized screen-relative movement with vertical ×0.5 and 2D collisions; matching eight layer names; deterministic farming/weather/NPC behavior; real physical GUI click/modal safety; old save round trip; data gate + parse + main smoke; domain tests headless and the complete renderer-dependent GUT suite on Forward+. Fix the test-runner separation explicitly rather than pretending full headless GUT can currently finish or silently skipping visual tests.

Risk: this touches 3D-typed view signatures and interaction/picking tests across several systems. Update expectations only where 2D intentionally replaces a 3D presentation detail; keep state, transaction, deterministic/golden and input assertions. Manual 2D gameplay review remains a human acceptance step. No git commit/push, archive deletion, package installation or unrelated refactor is authorized by this scope.

## Historical C4 status
`C3 (Chibi world)` — complete and tagged `chibi-world`. It adds only generated view-layer world/building/seasonal presentation while preserving all interaction anchors, collision, navigation, crop picking, weather/day-night authority and save v4.

`C4 (Chibi UI / M7)` — complete and tagged `chibi-ui`. It adds a C0-palette pastel pill Theme, compact icon-first HUD preservation, themed native tooltips, code-drawn tool-aware cursor, keyboard focus and restrained hover/press/open bounce. It preserves the readable map-first HUD, real GUI input routing, all current localization, and has no save/schema/input-domain change.

`C1 (Chibi characters)` — complete and tagged `chibi-characters`. C0 remains tagged `chibi-core`; C1 opts the existing player/NPC presentation into the C0 core without changing gameplay IDs, schedules or save schema.

## C4 approved plan and allow list (2026-10-30)

- Add runtime-only `ChibiUiMotion` and `ChibiCursor` view helpers. They will animate existing focusable controls with small hover/press/open tweens and draw a project-original rounded paw/tool cursor above all UI. They do not submit gameplay input, add an InputMap action, own UI state, save anything or change a node path required by a scene.
- Extend the existing runtime `UiLayout` theme from the C0 palette with warm rounded panel/button/field/tooltip styles, standardized readable font sizes and keyboard-focus treatment. Existing localized `tooltip_text` remains the tooltip source; the compact hotbar and corner icon bar retain their current map-safe footprints.
- Polish only the existing title card/backdrop with a restrained logo outline/bob and slow decorative parallax/motes. Keep actual StartMenu Buttons/OptionButtons and their callbacks, so physical mouse and keyboard paths remain Godot Controls rather than illustration hitboxes.
- Add an opt-in normal-renderer UI capture argument/tool that writes title and in-game HUD review PNGs without loading or writing a save. Add focused C4 regression coverage for cursor/tool modes, motion/theme wiring, native tooltip style, keyboard focus and compact three-resolution HUD constraints. Re-run the existing physical mouse/modal layout tests rather than weakening them.
- Planned C4 files only: `scripts/view/{chibi_cursor,chibi_ui_motion,ui_layout,start_menu,title_backdrop,main}.gd` and generated `.uid` companions; `tools/capture_chibi_ui.bat`; `tests/unit/test_chibi_ui.gd`; `docs/{API_INDEX,ART_BIBLE,PROGRESS,DECISIONS,UI_LAYOUT,CREDITS}.md`; and only existing C4-relevant UI tests if a deliberate assertion must change (with the reason recorded in `DECISIONS.md`). No `.tscn`, domain, save service/schema, economy, farming, NPC schedule, weather/day-night, localization text, input action, collision or C0–C3 generated model data is in scope.

## C4 completion and handoff (2026-10-30)

- Delivered the runtime-only `ChibiUiMotion` and `ChibiCursor`. Existing Buttons/fields receive small focus/hover/press/panel-open presentation tweens, while the code-drawn topmost cursor changes from paw-over-UI to a tiny selected hoe/watering-can/seed/harvest cue. It uses `MOUSE_FILTER_IGNORE`, restores the OS cursor on exit, creates no saved field or new input action, and does not call gameplay methods.
- `UiLayout` now derives its shared runtime Theme from the C0 palette: cream rounded panels, pastel pill Button/OptionButton/field states, visible keyboard focus, and a native styled Godot tooltip panel. The four tool icons and four corner buttons retain the compact D24 footprint; no item grid was restored over the map.
- Title keeps real Godot Controls and callbacks, now with an outlined/breathing logo, primary keyboard focus, form/settings focus routing and slow pointer-relative backdrop motes. The normal title/HUD capture was visually reviewed: no clipped cards, missing button, overlapping HUD or map-covering chrome was found. Tool icons intentionally stay compact after the earlier player feedback; their localized tooltips expose names/keys.
- New normal-renderer evidence is `screenshots/chibi-ui/chibi_ui_title.png` and `screenshots/chibi-ui/chibi_ui_hud.png`. The capture recorded `1152×648`, `60.0` FPS, `1,294` draw calls and `1,437` objects. The existing/current C4 UI regressions cover the same map-safe layout at `1152×648`, `1280×720` and `1920×1080` (vi/en); this one normal capture is not the still-deferred M0 full capture matrix.
- Final C4 verification: `tools\capture_chibi_ui.bat` PASS; `[check_parse] OK`; `[validate_data] PASS`; 52 scripts, 157/157 passing tests, 5,146 asserts, 27.415 s, `[run_tests] PASS`. The parse/validator/GUT/main/capture log scan found `0` matches for `SCRIPT ERROR`, `Parse Error`, `Failed to load script` or `ERROR:`; `git diff --check` passes. Generated assets remain unchanged at 162 files / 4,229,000 bytes.

## C3 approved plan and allow list (2026-10-29)

- Create original, reproducible rounded-primitive C3 world assets under `assets/generated/models/world/`: player cottage, seed market, shipping bin, generic NPC cottage, inactive observatory landmark, rounded tree, forest/cliff boundary, pond/bridge, fence/path and small village props (well, lamp, mailbox, signpost, bench, woodpile, flowers/rocks), plus tiny bird/butterfly/firefly silhouettes. Every model stays grounded, finite and within the C0 building/tree/prop budgets.
- Add a validated visual-only `WorldArtCatalog` under `data/art/world/`. It owns stable C3 asset IDs, palette roles, non-interactive placement/layout data and seasonal presentation colors. It must not encode gameplay price, collision, navigation, NPC schedule, farm grid, time or save data.
- Rebuild only the `WorldPresentation` art children through generated C3 scenes while retaining the exact House, SeedShop, ShippingBin, NPC-home, FarmView and marker transforms. Add soft terrain dressing, paths, water/bridge, rounded forest/cliff boundary and village props as non-colliding view children outside farm cells, route cells and interaction reach zones.
- Add a bounded `WorldSeasonFx` view that listens to existing `GameClock` season/time and `WeatherState` changes: spring petals, summer butterflies/day birds and night fireflies, autumn leaves, winter snow plus rain-water ripples. It owns no random gameplay, save field, input action, time/weather value or particle system outside the documented cap.
- Add reproducible C3 build, normal-renderer 4-angle/day-night/seasonal review and real-main-scene capture tools. Update the world scene contract before runtime changes, add narrow asset/data/view/review regression tests and preserve all current crop picking, NPC navigation/home, merchant/shop/bin and UI-layout coverage. Existing visual tests may change only where their primitive-art assertion is intentionally superseded; record why in a new decision.
- Planned C3 files only: `docs/{API_INDEX,ART_BIBLE,PROGRESS,DECISIONS,DATA_SCHEMA,UI_LAYOUT,CREDITS,SCENE_CONTRACTS/README,SCENE_CONTRACTS/gray_box_world,SCENE_CONTRACTS/world_art_lineup}.md`; `scripts/{data/world_art_catalog,core/data_validator,view/world_presentation,view/world_art_factory,view/world_season_fx,view/main}.gd`; `data/art/world/**`; `assets/generated/models/world/**`; `tools/{build_chibi_world,art_review_world,capture_chibi_world}.bat`, `tools/art/chibi/{build_chibi_world,chibi_world_builder,chibi_world_lineup,world_art_review_runner}.gd`, `tools/chibi_world_lineup.tscn`; `tests/unit/{test_chibi_world,test_world_review_layout,test_world_presentation}.gd`; and required generated `.uid` files. No existing gameplay `.tscn`, domain farm/economy/inventory/NPC schedule code, save service/schema, input map, collision layers, weather/day-night data or localization is in scope.

## C3 completion and handoff (2026-10-29)

- Delivered a validated, visual-only `WorldArtCatalog` and 21 reproducible rounded-primitive scenes: five buildings, a tree, cliff/forest boundary, pond/bridge, ten village-prop categories and three ambient critters. Measured triangles remain below their C0 budget: player cottage `600 / 8,000`, market `440 / 8,000`, NPC cottage `276 / 8,000`, tree `520 / 1,000`, and the largest prop/flower patch `600 / 1,500`.
- `WorldPresentation` now installs one runtime `C3WorldArt` root and safely replaces only visual children beneath the existing House, SeedShop, ShippingBin and Phase 8 home anchors. Exact anchors/markers, collision, NPC routes, FarmView/crop picking, merchant handling, time/weather authority and save v4 are unchanged. Passive catalog placements are tested outside farm cells and every protected interaction reach.
- `WorldSeasonFx` observes existing clock/weather state: spring petals, summer day butterflies/birds and night fireflies, autumn leaves, winter snow and rain ripples. The catalogue cap is `28`; the most populated current seasonal/rain combination is below that cap and it creates neither save data nor gameplay randomness.
- Normal-renderer C3 review writes five 4-season × day/night × four-angle contact sheets plus `screenshots/chibi-world/chibi_world_main_scene.png`. Three focused correction rounds found/fixed: generated scene ownership/anchor handoff; unsafe initial fence/path proximity to interaction areas; duplicate named presentation groups; and the C0 toon/outline pass rendering dark/black in the real world pipeline. Runtime toon instances now use a local readable material while generated sources and foliage/water shader treatment stay intact.
- Capture sample on the normal Forward+ renderer at `1152×648` recorded `58.3` frame FPS, `1,294` draw calls and `1,437` rendered objects (`Performance.TIME_FPS` reported `29.9` in this capture window). This is C3 review evidence, not the deferred M0 smoke/autoplay/full `1920×1080` benchmark; do not interpret it as a release-performance claim.
- Generated assets currently total `162` files / `4,229,000` bytes; the C3 world directory is `22` files / `696,982` bytes, well below the product prompt's overall generated-asset budget.
- Final verification before the C3 commit/tag: `tools\build_chibi_world.bat` PASS; `tools\art_review_world.bat` wrote five contact sheets and the main-scene image; `[check_parse] OK`; `[validate_data] PASS`; 51 scripts, 154/154 passing tests, 5,110 asserts, 24.665 s, `[run_tests] PASS`. The C3 build/review/capture/parse/validator/GUT/main log scan found 0 matches for `SCRIPT ERROR`, `Parse Error`, `Failed to load script` or `ERROR:`; `git diff --check` passes.

## C2 approved plan and allow list (2026-10-28)

- Deliver original, reproducible rounded-primitive farming assets under `assets/generated/`: four readable growth stages plus a wilted stage for each of the nine registered crops, small seed/produce props for all eighteen `ItemData` resources, and held hoe/watering-can/seed/harvest props. All use the C0 palette/material factory, grounded pivots and palette-owned triangle budgets.
- Rework only `CropPresentation` and `SoilPresentation` beneath the existing `FarmView` roots. Preserve `get_cell_view`, `get_crop_view`, `get_crop_label` and crop picking bounds while adding family-specific stage silhouettes, mature sparkle/bob, tilled furrows and wet-soil treatment. Do not change FarmGridState, crop timing/yield, weather, tool, inventory or save logic.
- Add a data-backed visual art catalogue and optional ItemData visual metadata so all current item data resolve deterministic generated 128 px transparent sticker icons. `UiIcons` may prefer these generated item icons but retains every SVG/tool-chrome fallback; this is item artwork only, not the C4 HUD/theme redesign.
- Add bounded view-only farm effects called only after the existing tool action succeeds. Failed, out-of-reach or capacity-blocked actions must not create an effect or mutate anything.
- Add reproducible build/icon/review tools and normal-renderer four-angle/day-night farm contact sheets plus a real-main-scene capture. Add narrow C2 tests/audits for assets, item icon resolution, crop-root picking, soil/effect behavior and regression locks. Review no more than three visual correction rounds and record actual findings.
- Planned C2 files only: `docs/{API_INDEX,ART_BIBLE,PROGRESS,DECISIONS,DATA_SCHEMA,UI_LAYOUT,CREDITS,SCENE_CONTRACTS/gray_box_world,SCENE_CONTRACTS/farming_art_lineup}.md`; `scripts/{data/item_data,farming_art_catalog,core/data_validator,view/crop_presentation,soil_presentation,farm_view,tool_action_controller,ui_icons,farm_effects,chibi_avatar,main}.gd`; `data/{items/**,art/farming/**}`; `assets/generated/{models/farming/**,icons/**}`; `tools/{build_chibi_farming,art_review_farming,capture_chibi_farming}.bat`, `tools/art/chibi/**`, `tools/farming_art_lineup.tscn`; `tests/unit/{test_chibi_farming,test_farming_review_layout,test_ui_mouse}.gd`; and required generated `.uid` files. No gameplay `.tscn`, domain crop/tool/inventory code, save service, economy, input map, prices or crop balance data is in scope.

## C2 completion and handoff (2026-10-29)

- Delivered a validated `FarmingArtCatalog` and 45 original generated crop scenes: four visible stages plus one withered state for each of the nine registered crops. The current crop-family mapping covers roots, vines, stalks, grain, ground vines and leafy crops, while `CropPresentation` preserves the existing logical root/picking contract, adds data-driven silhouette/dew/mature presentation, and never changes farm state.
- Delivered 18 grounded item prop scenes and 22 transparent 128 px stickers (18 seed/produce items plus four tools). Optional `ItemData.model_path` / `icon_path` are strictly view metadata. `UiIcons` prefers C2 stickers, retains SVG fallbacks, and the existing C1 held-tool animation now uses C2 props with its old procedural fallback intact.
- Delivered C2 tilled furrows, wet-soil treatment and bounded farm effects after successful hoe/seed/water/harvest paths only. Failed/missing-item/out-of-reach/capacity-blocked attempts remain visually and mechanically inert; crop growth, two-product harvests, economy, inventory atomicity, drag strokes and save v4 were not altered.
- Reproducible normal-renderer review tooling creates 14 four-angle/day-night sheets plus a real `main.tscn` capture under ignored `screenshots/chibi-farming/`. Review correction round 1 found focused assets too distant, 3D labels obscuring silhouettes and C0 shader shading too dark under the existing world pipeline; focused views now omit model labels, use closer framing, crop presentation gets a local readable material override, and the showcase spreads the nine crops over alternate cells. Round 2 found long crop captions crowded at tile seams; the sheets now use compact two-line captions. Final sheets show distinct growth silhouettes, items/tools and readable daylight/night contrast; the scene capture shows the C2 farm in the real HUD/camera context.
- Final verification before the C2 commit/tag: `tools\build_chibi_farming.bat` PASS; `tools\art_review_farming.bat` wrote 14 contact sheets and `chibi_farming_main_scene.png`; `[check_parse] OK`; `[validate_data] PASS`; 49 scripts, 151/151 passing tests, 4,741 asserts, 24.367 s, `[run_tests] PASS`. The C2 build/review/capture/parse/validator/GUT/main log scan found 0 matches for `SCRIPT ERROR`, `Parse Error`, `Failed to load script` or `ERROR:`.

## C1 approved plan and allow list (2026-10-27)

- Add a validated, data-owned character catalogue under `data/art/characters/`: six selectable player hair/skin/color combinations with a persisted cosmetic selection, plus distinct profiles for An, Bác Lâm, Linh and Minh. The existing opaque `profile` payload will store only an optional cosmetic dictionary, so older v4 saves retain their default appearance without a schema bump.
- Add original reproducible chibi-character tooling under `tools/art/chibi/` and generated scenes under `assets/generated/models/characters/` for player, An, Bác Lâm, Linh, Minh and one noninteractive dog calibration model. All models use C0 materials, grounded pivot rigs and data-defined character triangle budgets; the dog does not add Roadmap 8.5 follow/name/save behavior.
- Replace only the view-local `ChibiAvatar` mesh assembly with a pivot rig, `AnimationPlayer` clips (`Idle`, `Walk`, `Run`, `Tool`, `Sleep`, `Talk`), deterministic 8-direction facing, face/emotion API and code-built transient emotion bubbles. Bind the existing Player, Minh and Linh anchors only; do not create unplanned NPC gameplay actors for An/Lâm.
- Extend the existing new-game form with compact localized appearance selectors. Persist the selected cosmetic data through the existing profile round trip, apply it after New Game/Continue/load, and keep old two-argument test/caller compatibility. No new InputMap action, scene node, autoload, domain state, schedule, collision or save migration is planned.
- Add a character lineup/review runner with day/night four-angle sheets and a real `main.tscn` normal-renderer capture; add narrow GUT coverage for data validation, generated scene mesh audits, pivots/head ratio, animation clips, face/bubble API, old-profile fallback, save round-trip, player/NPC anchor preservation and three-resolution selector layout. Update API/ART/UI/decision/credits/progress docs and both locales.
- Planned C1 files only: `docs/{API_INDEX,ART_BIBLE,PROGRESS,DECISIONS,UI_LAYOUT,CREDITS,SCENE_CONTRACTS/art_lineup,SCENE_CONTRACTS/character_lineup}.md`; `scripts/{data/character_appearance_data,character_appearance_catalog,core/data_validator,view/chibi_avatar,character_face,emotion_bubble,npc_actor,npc_system,tool_action_controller,world_presentation,main,start_menu}.gd`; `data/art/characters/**`; `assets/generated/models/characters/**`; `tools/{art_review_characters.bat,build_chibi_characters.bat,capture_chibi_characters.bat,character_lineup.tscn,art/chibi/**}`; `tools/validate_data.gd`; `tests/unit/{test_chibi_characters,test_character_review_layout,test_ui_layout}.gd` (the prior exact three-child new-game-form assertion changes intentionally because the approved appearance form adds children); `localization/strings_{vi,en}.csv`; and generated `.uid` companions. Existing gameplay `.tscn` files, save service/schema, NPC data/schedules and Roadmap 8.5 behavior are out of scope.

## C1 completion and handoff (2026-10-28)

- Delivered a validated `CharacterAppearanceCatalog`: player appearance selection has six hair styles, six skin tones, six hair colors and six outfit colors. The optional normalized `profile.appearance` dictionary survives New Game, Continue and the existing v4 profile round-trip; old v4 profiles fall back deterministically without a schema bump.
- Delivered reproducible generated model scenes for player, An, Bac Lam, Linh, Minh and the visual-only dog calibration asset. Their measured triangle counts are player `2,808`, An `3,120`, Lam `2,820`, Linh `3,240`, Minh `2,820`, dog `2,052`, each under the `6,000` character budget with grounded pivots and finite geometry.
- Replaced the view-local avatar with the articulated chibi rig and view-only `Idle`, `Walk`, `Run`, `Tool`, `Sleep` and `Talk` clips, eight-way facing, distinct held hoe/watering-can/seed-bag/harvest-tool models, `CharacterFace` emotions and transient emotion bubbles. Successful existing farm actions and opening Minh dialogue trigger only these visuals; Player/Minh/Linh domain anchors and schedules remain authoritative.
- The normal-renderer review writes one six-model lineup plus six focused four-angle/day-night sheets to ignored `screenshots/chibi-characters/`, and captures the real `main.tscn` through the opt-in `--capture-chibi-characters` project argument. The capture uses an isolated in-memory review arrangement, never loads or writes a save slot.
- Three focused visual correction rounds were performed from those images. Actual issues found: (1) the first capture route compiled `main.tscn` without autoloads; (2) daytime/sunset prompt and name labels obscured the first real-scene review; (3) focused-sheet labels covered individual silhouettes; (4) the review camera was too high to inspect the face; and (5) generated face pieces were offset beyond the rounded head surface. The final tools launch the configured main scene, use a daylight/no-prompt in-memory showcase, suppress labels only for its capture, preserve the first 45-degree/35-degree game tile plus lower supporting views, and place a raised/compact hat and face features correctly on the head. Final review sheets show readable eyes, cheeks and individual accessories in daylight and night.
- Final verification before the C1 commit/tag: `tools\build_chibi_characters.bat` PASS; normal-renderer `tools\art_review_characters.bat` wrote 7 contact sheets and the real-scene PNG; `[check_parse] OK`; `[validate_data] PASS`; 47 scripts, 146/146 passing tests, 4,209 asserts, 22.931 s, `[run_tests] PASS`. The combined C1 build/review/capture/parse/validator/GUT/main log scan found 0 matches for `SCRIPT ERROR`, `Parse Error`, `Failed to load script` or `ERROR:`.

## C0 approved plan and allow list (2026-10-27)

- Create `docs/ART_BIBLE.md` and a data-owned `ArtPalette` Resource with one warm pastel, four-season palette in `data/art/palette/`. Validate the palette in the headless data gate.
- Add original generated shader/material foundations (toon/tinted shadow/rim, outline, foliage wind, water, dither fade) beneath `assets/generated/`; add a view-only material factory but do not alter `WorldPresentation`, `ChibiAvatar`, crops, UI, or existing scenes.
- Add deterministic primitive builders and mesh-audit helpers under `tools/art/chibi/`; use them to build five calibration scenes under `assets/generated/models/chibi_core/`, bounded by data-defined triangle budgets.
- Add the standalone `tools/art_lineup.tscn` tool scene, `tools/art_review.bat` contact-sheet runner, scene contract, and unit coverage for palette validation, shader/material load/render binding, generated scene loading, triangle budgets, bounds, pivots and review layout.
- Planned C0 files only: `docs/{ART_BIBLE,API_INDEX,PROGRESS,DECISIONS,CREDITS,SCENE_CONTRACTS/art_lineup}.md`; `scripts/{data/art_palette,core/data_validator,view/chibi_material_factory}.gd`; `data/art/palette/chibi_valley.tres`; `assets/generated/{shaders,materials,models/chibi_core}/**`; `tools/{art_review.bat,build_chibi_core.bat,art_lineup.tscn,art/chibi/**}`; `tools/validate_data.gd`; `tests/unit/test_chibi_art_foundation.gd`, Godot-generated `.uid` companions and the narrow `/screenshots/` ignore-rule addition. No existing game scene or runtime presentation script is in scope.

## C0 completion and handoff (2026-10-27)

- Delivered an original, data-driven `ArtPalette` (`chibi_valley`) with four seasonal role colors, chibi scale ratios and data-owned triangle budgets. The normal data validator loads it in the existing gate.
- Delivered five generated Godot 4.7 shader/material pairs (toon/tinted shadow/rim, inverted-hull outline, foliage wind, water and dither fade), an opt-in material factory, deterministic primitive builders and mesh audit coverage. Existing runtime presentation remains intentionally unchanged.
- Generated calibration scenes: character `672 / 6,000`, prop `100 / 1,500`, crop `128 / 400`, rounded building `300 / 8,000`, tree `220 / 1,000` triangles. Every scene loads, has finite grounded bounds, non-degenerate faces and is tested against its data budget.
- `tools\art_review.bat` now uses the normal RTX/Forward+ renderer and produces a labeled 4-angle × day/night lineup plus one focused 512 px-tile contact sheet per calibration model under ignored `screenshots/chibi-core/`. It fails on empty capture or parse/script/engine error text.
- Visual correction round 1 was reviewed from the generated sheets: models were initially too small; the grid/model/angle/light evidence was absent; shaders were not visible; building silhouette and shadow were harsh; and night was muddy. The tool now has compact two-row layout, 1 m grid, labels/captions, focused model sheets, generated toon/foliage/outline materials, a rounded building/softer shadow and brighter night. Round 2 caught inward normals on the first custom rounded meshes; winding was flipped and the final day/night sheets restore readable warm faces. A real `main.tscn` scene capture remains deliberately deferred to C1/C3 rather than being misrepresented as C0 evidence.
- Final verification before the C0 commit/tag: `tools\build_chibi_core.bat` PASS; normal-renderer `tools\art_review.bat` wrote 6 sheets; `[check_parse] OK`; `[validate_data] PASS`; 45 scripts, 137/137 passing tests, 3,996 asserts, 18.315 s, `[run_tests] PASS`. The combined build/review/parse/validator/GUT/main log scan found 0 matches for `SCRIPT ERROR`, `Parse Error`, `Failed to load script` or `ERROR:`. M0 smoke/autoplay/full-capture/baseline automation remains deferred per D28.

## Last commit / tag
`chore: persist Phase 8 scene resource serialization` — approved Godot 4 scene/resource canonicalization, isolated from gameplay feature work
`docs: add master production prompt` — moved the product-owner supplied master prompt into tracked documentation without changing its contents
`feat: add two-product harvest and drag farming` — data-driven two-product harvests, direct Harvest selection and de-duplicated mouse farming strokes
`feat: add original farm audio and grounded world polish` — reproducible farming effects, separated sale landmark, extra cottages, terrain detail and warm daylight
`npc-quests` — confirmed delivery and merchant transactions, Minh/Linh schedules, localized dialogue/journal, friendship, and save v4 migration

`feat: add chibi art foundation` / `chibi-core` — validated palette, generated shader/material suite, original calibration models and independent review tooling; no gameplay presentation migration
`feat: add chibi characters and customization` / `chibi-characters` — data-owned appearance options, generated character models, view-only rig/face/emotion/held-tool presentation and normal-renderer review capture; no save-schema, schedule or Roadmap 8.5 behavior change
`feat: add chibi farming art` / `chibi-farming` — data-owned crop families/stages, generated crop/item/tool assets and stickers, view-only soil/effects/readability plus normal-renderer review; no gameplay, economy or save-schema change
`feat: add chibi world presentation` / `chibi-world` — data-owned generated buildings/world props, bounded seasonal ambience, real-main-scene review and C3 interaction/anchor regression locks; no gameplay, economy or save-schema change
`feat: add chibi UI presentation` / `chibi-ui` — C0-palette runtime Theme, native tooltip styling, code-drawn cursor, focus/motion wiring and normal-renderer title/HUD review; no scene, gameplay, input or save-schema change

## Done
- [x] C3 chibi world: generated building/terrain/prop/critter art, bounded seasonal ambience, safe anchor/placement handling, normal-renderer review/capture and regression coverage (commit/tag recorded above)
- [x] C2 chibi farming: data-owned crop families/stages, generated crop/item/tool models and 128 px stickers, view-only soil/effects/readability, normal-renderer review/capture, interaction/icon regression coverage (commit/tag recorded below)
- [x] C1 chibi characters: player appearance selector, generated player/An/Bac Lam/Linh/Minh/dog-reference assets, articulated presentation, face/emotion bubbles, C1 review tooling and compatibility coverage (commit/tag recorded above)
- [x] `docs/MASTER_PROMPT.md` added from the root prompt source, byte-preserving in UTF-8 (commit `215d2d6`)
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

## Historical handoff notes
- 2026-10-27 crop-yield and drag-farming follow-up completed (player-approved). Every current crop Resource has `yield_qty = 2`, validator rejects non-positive data, and the existing harvest payload/inventory path now visibly grants two products for each mature crop. Holding left use across reachable cells plants, waters or harvests each cell once; click/default hoe inspection, keyboard use, modal locks, reach checks and inventory-capacity blocking remain intact. Harvest is now a selectable direct tool mode. The formerly pending `data/npcs/phase8_world.tres` and `scenes/main/main.tscn` reserialization was explicitly approved and committed as `3a4be46`.

## Requested M0 cleanup / M1 completion handoff (2026-10-27)

- `docs/MASTER_PROMPT.md` was added in its own commit `215d2d6` after SHA-256 equality with the root source (`7F9FBD9D75F3C721E1E4BFA69753B2AD48829573836EB2D894F68294AC7C0E45`). The root copy was moved, not duplicated.
- The former `data/npcs/phase8_world.tres` and `scenes/main/main.tscn` diffs are Godot serialization canonicalization (UIDs, resource ordering, values equal to script defaults, empty packed arrays as `null`, node unique ids, anchor presets and property ordering). The product owner explicitly approved retaining them; they are now isolated in `3a4be46`, rather than being represented as new NPC gameplay.
- Final official verification after `3a4be46`: `[check_parse] OK`, `[validate_data] PASS`, 44 scripts, 132/132 tests passing, 3,882 asserts, 17.772 s, `[run_tests] PASS`, with no captured `SCRIPT ERROR`, `Parse Error`, `Failed to load script`, or `ERROR:` text.
- Read-only M1 audit found no missing requested feature: conditional data dialogue/journal, confirmed atomic delivery/shortage safety, friendship and heard dialogue persistence, Minh's seeded data offer with isolated prices, all-four-season/rain/night schedules/routes, save v4/migration/golden coverage and validation are already implemented. `npc-quests` already exists at `8a30283`; do not move it.

## NEXT

- Start C5 (chibi audio / M8) only in a fresh task/conversation: read `docs/MASTER_PROMPT.md`, `docs/CHIBI_STYLE_PROMPT.md`, this file, `docs/ART_BIBLE.md`, `docs/API_INDEX.md`, `docs/DECISIONS.md` and every touched scene contract first. Audit the existing four farming WAV effects/AudioService before extending audio; preserve all C0–C4 generated paths, UI modal/input authority, FarmView/crop picking, DayNightProfile/weather authority and save v4. Do not quietly add gameplay systems, scene ownership changes or a new audio authority.
- Before a release claim, separately return to the deferred M0 automation named by `docs/MASTER_PROMPT.md`: `smoke_run`, autoplay, full capture matrix, baseline measurements/tag and global `build_assets`. Do not retroactively describe C0's isolated contact-sheet runner as that complete M0 suite.

## Chibi-style prompt reference handoff (2026-10-27)

- Added `docs/CHIBI_STYLE_PROMPT.md` from the product-owner supplied prompt. It is a visual-production reference for the future C0–C6 sequence; this documentation-only task does not start C0/M2, regenerate any model, or change runtime logic, IDs, resources, scenes, saves, tests, or current Phase 8 scope.
- The prompt intentionally retains its reference to `docs/MASTER_PROMPT.md`, which is now tracked in commit `215d2d6` after the product owner explicitly authorized moving the root source. Future sessions read both prompt files before continuing from this document.
- Project authority remains `AGENTS.md`, `docs/PROJECT_RULES.md`, approved Roadmap/task scope, and existing decision records. This prompt is not permission to bypass milestone order, scene ownership, save compatibility, or tests.
- Verification for this docs-only commit: `[check_parse] OK`, `[validate_data] PASS`, 44 scripts, 132/132 passing tests, 3,882 asserts, 17.974 s, and `[run_tests] PASS`. The captured runner output contained no `SCRIPT ERROR`, `Parse Error`, `Failed to load script`, or `ERROR:` text.

## Two-product harvest and drag farming handoff (2026-10-27)

- Assumption implemented: “one seed grows into two” means one valid planting consumes one seed and a mature crop grants two product items, rather than spawning two separate plot instances. This is data-owned in the nine crop `.tres` resources; no save migration is required because planted plots store only `crop_id` and harvest reads current crop data.
- Input behavior: select Seed, Water or Harvest, hold left mouse and move through reachable farm cells. A stroke visits each cell at most once even if the pointer returns over it. Default Hoe click on a planted crop continues to open CropInspector; direct Water/Harvest modes act on crops. Space/key use remains a one-cell action. No new InputMap action or auto-farming timer was added.
- Focused coverage: the new SubViewport input regression performs Seed → Water → mature → Harvest across two cells and returns over the first one; it verifies two seeds are consumed, watering occurs once per crop, harvest adds four turnips total and harvest mode does not open the inspector. Crop/data/year tests assert data-defined quantity 2, capacity protection and sale quantity. Validator now rejects `yield_qty <= 0`.
- Real final official runner:

```text
[check_parse] OK
[validate_data] PASS
Scripts              44
Tests               132
Passing Tests       132
Asserts            3882
Time              17.878s
---- All tests passed! ----
[run_tests] PASS
```

- Error-text scan across parse, validator, GUT and main-scene logs: `0` matches for `SCRIPT ERROR`, `Parse Error`, `Failed to load script`, or `ERROR:`. The requested yield doubles current sale output without changing any price; the full-year simulation remains green, but a future data-only economy balance pass should recalibrate profit targets rather than hiding this change in code.
- 2026-10-27 presentation/audio follow-up completed (approved player scope; mechanics unchanged). Delivered: four reproducible original WAV effects for the existing hoe/seed/water/harvest calls; AudioService resolves OGG first then WAV and honors saved effects volume. The selling bin and its marker moved together to `(5.2, 0, 10)`, over 4 m from the cottage bed marker; the seed stall stays fixed. Two non-interactive cottages, grass tufts and a stone path distinguish village places. Farm cells now present dry tilled furrows and a subtle wet sheen, and warm low-cost fog/shadow/ground tuning improves sunlight without taking clock or weather authority. No domain, economy, growth, save, time, reach or input behavior changed.

## Presentation/audio follow-up handoff (2026-10-27)

- Files: original audio source/rebuild script `tools/build_audio.gd`; generated `assets/audio/{hoe,seed,water,harvest}.wav` plus Godot import metadata; `scripts/core/audio_service.gd`; view-only `scripts/view/soil_presentation.gd`, `farm_view.gd`, `world_art_factory.gd`, `world_presentation.gd`; the documented world-anchor scene movement, focused tests, and API/layout/scene/credits/decision docs.
- Automated coverage: audio files resolve and load as `AudioStream`s; a normal tool sound creates a player; bin mesh/marker remain aligned at the separated sale point; cottages/path/ground dressing exist; warm sunlight properties are present; tilled/watered soil adds only the expected view meshes. Existing shipping-bin reach, shop, crop, interaction, save and year-economy coverage remain in the full suite.
- Real final official runner:

```text
[check_parse] OK
[validate_data] PASS
Scripts              43
Tests               131
Passing Tests       131
Asserts            3857
Time              17.811s
---- All tests passed! ----
[run_tests] PASS
```

- Error-text scan across the generator, parse, validator, GUT and main-scene logs: `0` matches for `SCRIPT ERROR`, `Parse Error`, `Failed to load script`, or `ERROR:`. Godot imported the WAVs using `--headless --import`; the generated `.wav.import` files are tracked. No manual game-window automation was run because the player is using the existing game window.
- Manual check: stop an old run, F5 and Continue/New Game. Use hoe, seed, watering can and harvest on reachable plots to hear four gentle effects; change Effects volume in Settings and repeat. Walk to the new sale-bin location south-west of the cottage and press E; verify sell panel opens. Visit cottage, seed stall, village homes and farm at morning/afternoon/rain/night; ensure all markers still show only their existing prompts. Tilled soil should have raised rows; watered planted soil should appear darker with a small sheen.
- 2026-10-27 world-art pass, requested after the compact HUD review. Delivered: view-only native low-poly crops are distinct by family (sprout, roots, tomato, pea, corn, wheat, pumpkin, cabbage, wilted); healthy crops have a minimal sway and watered crops show dew. Existing crop root meshes and CropInspector remain the only click/detail path. Existing House, SeedShop, ShippingBin and NPC-home anchors now render as separate cottage/market/bin structures, and four exterior rock/moss clusters make the map edge less empty. Filmic color, restrained glow/fog and softened directional shadows improve daylight while retaining DayNightProfile/weather ownership and night house lights. No domain, timing, save, marker, collision, input or `.tscn` change.
- Visual/manual evidence: launched the real 1152x648 game on 2026-10-27, used Continue, and inspected the daylight world: cottage, separate awning seed market, NPC homes, terrain rocks, compact HUD and farm grid appeared with no overlapping HUD or missing interaction surfaces. A user input event was then detected, so automation stopped without further game input. Automated proof is `test_world_presentation.gd` plus the normal interaction/layout suite.
- The player added `Prompt tổng hoàn thiện game The Life.md` at the repository root (currently untracked/user-owned) and supplied the same Downloads copy. It was read as a long-term product reference, not treated as authority over `AGENTS.md`, `PROJECT_RULES.md`, Roadmap order, scene ownership or current user scope. Its direct art guidance matches this completed view-only pass; its suggested generator/palette/shader pipeline is a separate next milestone.

## World-art pass handoff (2026-10-27)

- Delivered files: `scripts/view/{crop_presentation,world_art_factory,farm_view,world_presentation,npc_system}.gd` and generated `.uid` files; `tests/unit/{test_world_presentation,test_game_feel}.gd`; `docs/{API_INDEX,DECISIONS,PROGRESS,UI_LAYOUT,SCENE_CONTRACTS/gray_box_world}.md`. The player-owned root prompt file is deliberately not part of this art commit.
- Acceptance: crop meshes are now family-specific and stateless; their existing root bound remains the click target. The map renders a cottage at the house anchor, a visibly separate seed-market stall, a distinct bin, decorated Minh/Linh homes and four non-colliding edge rock clusters. Lighting is limited to Forward+ Environment/sun parameters and leaves data-driven clock/weather behavior intact.
- Automated coverage: `test_world_presentation.gd` checks visual children, unchanged shop/bin marker positions, decorated NPC homes, exterior-rock exclusion from the 6×6 farm, Forward+ post-processing/shadow configuration, sprout-to-mature change and cleanup after harvest. The earlier game-feel test was changed only because it deliberately asserted the superseded BoxMesh implementation; it now asserts a taller mature crop and recognizable sprout/root nodes.
- Real final official runner (backgrounded only to avoid the host command's 30 s transport cap):

```text
[check_parse] OK
[validate_data] PASS
Scripts              42
Tests               129
Passing Tests       129
Asserts            3830
Time              18.46s
---- All tests passed! ----
[run_tests] PASS
```

- Error-text scan across parse, validator, GUT, main-scene and runner logs: `0` matches for `SCRIPT ERROR`, `Parse Error`, `Failed to load script`, or `ERROR:`. Visual manual smoke: started the actual game at 1152×648, pressed Continue, and checked the daylight world. Do not automate the still-open game further: an input event from the user was detected during a later debug-menu attempt.
- Known limits / NEXT: this is a low-poly presentation pass, not the full `world-v1` or M2 art-foundation milestone. A separate next task should add the reproducible palette/material/generator framework, then a purpose-built screenshot/performance harness before expanding terrain, water, audio or future Roadmap systems. No claim is made that later Roadmap phases are complete.
- 2026-10-27 compact HUD/crop inspection task, approved standing plan-then-proceed workflow: hide the nine item-slot grid and caption in normal gameplay, keep a small four-tool strip and smaller corner menu buttons; expose selectable items only in the inventory modal. Add a nonmodal CropInspector view (large localized name, countdown, estimated game-day/morning, water/ready/withered status) on crop click; hide repetitive world-space crop labels. Reuse GameClock time_changed/FarmGridState queries and existing tool/harvest APIs, with a conditional daily-watering estimate and no save/growth changes. Files: scripts/view/{hotbar_panel,inventory_panel,main,ui_layout,ui_coordinator,tool_action_controller,farm_view,crop_inspector}.gd (+ new .uid), localization/strings_{vi,en}.csv, tests/unit UI/crop regressions, docs/{API_INDEX,PROGRESS,UI_LAYOUT,DECISIONS}.md and screenshot evidence. Initial workspace has two generated docs/screenshots/*.png.import metadata files; preserve them. Verify default HUD footprint, inventory mouse selection, crop click/action routing, minute/day countdown, watering/ripeness/removal, modal suppression and three resolutions in vi/en before the task commit.

## Compact HUD/crop countdown handoff (2026-10-27)
- Acceptance delivered: default item grid/caption hidden; tool strip is 220×60 and menu strip 216×60 at 1152×648; readable item selection appears only inside inventory. Selecting an inventory row closes it, selects the existing stack for use and never changes quantity. 1–9 shortcuts remain.
- Crop click opens a readable lower-left card with localized name, 24 px countdown, expected game day/morning and water state. It updates on GameClock.time_changed and FarmGridState.plot_changed, stays nonmodal and does not pause the clock. World labels remain API-compatible but hidden. Visual crop bounds, not just ground-ray cells, determine clicks on taller crops.
- Countdown assumption: remaining watered growth-day boundaries, daily care and a suitable season, using current GameClock data. It is an estimate in game time, not real-world seconds or offline progress; skipping water delays the forecast. Ready/withered states replace the timer. Water/Harvest buttons route through existing reach/locked-input/harvest capacity checks. No growth logic, economy, scene file or save schema changed.
- Six new regression tests cover physical crop clicks with no accidental tool use/consumption, minute countdown, daily growth and missed watering, inventory selection, mature crop top picking, withered/out-of-reach safety, removal after harvest, modal suppression, and vi/en layout at 1152×648 / 1280×720 / 1920×1080. Old world-label/hotbar geometry assertions were deliberately updated for the requested hidden UI; lifecycle text, tool bounds and gameplay invariants remain checked.
- Real final official runner:

```text
[check_parse] OK
[validate_data] PASS
Scripts              41
Tests               126
Passing Tests       126
Asserts            3789
Time              15.565s
---- All tests passed! ----
[run_tests] PASS
```

- Separate headless GUT: 41 scripts / 126 tests / 126 passing / 3716 asserts / 8.904s. Rendered-only PNG assertions explain the assertion-count difference. Player save slots 0/1 and backups were preserved/restored around both suites. No lint installation was performed.
- Manual editor steps: none. Stop old game/F5 → Continue. The map has no expanded item slots. Open backpack/I → Select a seed → inventory closes → plant as before. Click a planted crop → inspect countdown/water state → Water, wait game minutes or sleep, inspect again → Harvest when ready. Full modal opening hides the crop card. Check close button, far-away crop feedback, missing watering and full inventory. Human playtest remains pending; automation exercised physical press/release events in isolated viewports and rendered both languages/sizes.
- Screenshot evidence: docs/screenshots/compact_hud.png and crop_inspector.png. API_INDEX and UI_LAYOUT describe the view contract; D24 records the presentation/forecast decision. Proposed/used task commit: `fix: compact HUD and inspect crop harvest countdown`. Exact task diff is available against a741cfa; existing milestone tags are retained.
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
