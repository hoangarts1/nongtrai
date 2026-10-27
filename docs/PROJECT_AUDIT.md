# Project audit — 2026-10-26

This records actual source/test coverage against ROADMAP, rather than treating unchecked boxes as proof that nothing is implemented. `docs/SOURCE_AUDIT.md` contains the programmatic project-owned source inventory and public/private method inventory. Vendor addon internals, .godot cache, Git internals and duplicate starter material are excluded from implementation ownership. Master Plan is the design reference; PROJECT_RULES and ROADMAP remain authoritative.

## Blocking UI defects resolved in the chibi UI task

1. ModalBackdrop was a later sibling than every button. Godot GUI picking uses sibling order; a higher visual z_index on the buttons did not make them clickable. The backdrop now precedes them. Real SubViewport mouse press/release tests reproduce the failure with the old order and pass with the fix.
2. Modal key filters now leave mouse events to GUI routing. Their full-screen background still stops clicks outside panels. NPC dialogue follows the same rule.
3. Title screen always opens before gameplay. Previously a save could hide StartMenu while `_game_started` stayed false, locking movement.
4. Continue uses the same `load_latest()` source as its summary and load request, including slot 0. Previously a slot-0 summary could be shown while Continue was disabled by a slot-1-only check.
5. New Game resets clock, farm, inventory, wallet, onboarding, weather and social state through existing state APIs. Previously returning to the title and starting again retained the previous world.
6. Hotbar 1–9 now dispatches selection instead of merely displaying key badges. English help text no longer contains hardcoded Vietnamese mouse/arrow binding descriptions.

## Roadmap coverage

Status “partial” means the MVP has a useful implementation, but does not meet every acceptance condition of the original full roadmap.

| Phase/tasks | Actual state | Evidence / missing acceptance |
|---|---|---|
| Preparation P | Partial / human decisions | D08/D13 confirmed; most early decisions still DEFAULT; asset spike and human approvals are not recorded as passed. |
| 0.1–0.4 | MVP present | Pinned engine, Windows bounded parse/tests/validator, input/layer definitions, GridMath and gray-box world tests. Autoload layout differs from original cap/order (Localization plus development helper); docs need explicit reconciliation. |
| 0.5 | Partial | DetRandom exists under domain/quests and merchant seed golden test exists; weather still uses its earlier local deterministic formula. |
| 0.6 | Partial | Debug menu/FPS/time actions exist; shared Log utility and context-rich domain logging are absent. |
| 1.1/1.3 | Partial | Camera-relative movement, sprint, follow/bounds; zoom actions have no implementation. |
| 1.2/1.4/1.5 | Partial / absent | Ground collision exists; house/obstacle/shop meshes have no world-static body. No Idle/Move node state machine or general nearest Interactable detector. Existing world/NPC prompts use separate distance logic. |
| 1.6 | Absent, optional | No occluder fading. |
| 2.1–2.3 | MVP present | GameClock, sleep/rollover, season/year, HUD, debug controls and tests. |
| 3.1–3.4 | Partial | DataRegistry, resource validation, stack inventory, icon hotbar, localization, field drag strokes and tests. Inventory-panel item drag/drop, data-wide icon metadata and all original profit caps are not implemented. |
| 4.1–4.7 | MVP present, integration gaps | Crop lifecycle, tools, harvest, simulation, v1–v4 saves, feedback and original farming effects. Original architecture requires stricter domain independence, day ordering, corrupt-field validation and editor playtest acceptance. |
| Gate A | Human verification pending | Requires 10–15 minute plant–harvest playtest and a judgment about the loop. Automated test success cannot satisfy this criterion. |
| 5.1–5.6 | MVP partial | Wallet, seasonal seed shop, immediate shipping sales and year-loop test exist. No EconomyService/Ledger, shared ShopService, saturation price pressure, daily order board, multi-strategy economy harness or land-expansion balance target. D20 explicitly delivered a smaller economy slice. |
| 6.1–6.7 | Absent | No recipes/machines, occupancy/building placement, land parcels, upgrades, chickens/eggs or recipe profit-cap validation. |
| 7.1/7.2 | MVP present | Saved seeded weather/forecast, rain visuals and DayNightProfile lighting; weather independence/day-boundary integration still needs review. |
| 7.3–7.6 | Absent | No ecology metrics/thresholds, birds/butterflies ecology response, EventDirector, decision trace or 1000-day harness/journal. |
| 8.1–8.4 | Implemented slice | Data dialogue with quest conditions, confirmed delivery, friendship/history, AStarGrid2D schedules and finite merchant offers. Two villagers; Chapter content is not complete. |
| 8.5 | Absent | No follow/name dog state or gameplay. Puppy in title artwork is an illustration only. |
| 8.6 | Absent | Chapter I/M2.1–M2.4 narrative/moments/station unlock content not implemented. |
| 9.1–9.5 | Partial | Seven-step onboarding, settings, NPC journal, title/HUD redesign, original SVG icons, generated illustration and procedural character/scenery meshes. No full village/forest map, regional audio, complete imported art set or external usability playtest. |
| 9.6–9.7 | Absent / human | No export_presets.cfg, clean-machine Windows package verification or 3–5 stranger playtest metrics. |
| Gate B | Human verification pending | Requires actual stranger playtests and retention assessment. |
| 10 | Absent, gated | No NetworkGateway/MockBackend, account backend, friend/gift systems, shared project validation or moderation/privacy release work. Do not fabricate credentials or deploy services. |
| 11 | Mostly absent | Four simple seasons and basic volume/language settings exist. Offline progress, festivals, fishing/foraging, quality/fertilizer/irrigation, remaining NPCs/story, controller/accessibility/achievements and profiling are not delivered. |
| 12 | Absent, gated | Store, trailer, beta, release/legal checks and post-launch workflow need a finished product plus human accounts/reviews. |

## Source findings requiring targeted follow-up tests

These are code-review findings, not claims that a new repro test has passed. Keep separate commits and preserve the existing year simulation.

- **Day-boundary weather order:** Main._on_day_started currently advances weather, waters from the new day, and only then grows/dries crops. ARCHITECTURE §5 describes simulating the finished day's weather first and preparing the new day afterwards. Add a deterministic rainy/sunny transition test before changing this path.
- **Withered crop behavior:** FarmGridState.advance_day and can_harvest do not reject `withered`; test the mature/out-of-season and watered/withered cases before choosing intended recovery/clear behavior.
- **Language persistence:** Localization.apply_default_locale unconditionally selects vi after Settings loads, overriding a saved English preference. UI is now translated, but startup preference needs a core localization follow-up.
- **Layer ownership:** FarmGridState/InventoryState reference GameClock/DataRegistry/Events nodes; this is the historical MVP, not the fully pure domain layer in PROJECT_RULES. Wallet/Inventory owner APIs currently follow D21; avoid introducing a second coin/item authority without a migration plan.
- **Save robustness:** Some nested dictionary fields assume correct types. Existing broken-JSON tests do not prove every corrupted field is safe. Player position also remains world XYZ rather than logical cell/facing in the target architecture.
- **Test isolation:** Some older tests use actual user save slots 0/1 and settings. During this task full-suite runs were wrapped with byte-for-byte preservation/restoration of player slots/backups. New mouse tests also preserve the slot payloads they temporarily replace. A dedicated test-data directory remains a tooling follow-up.
- **Tooling parity:** Windows runner is bounded and scans error text; run_tests.sh still uses the older debug flag and lacks Windows parity. gdtoolkit is not installed. No package installation was performed.
- **Scope/status drift:** ROADMAP checkboxes remain untouched for human acceptance; PROGRESS records delivered slices. ARCHITECTURE's save example is a target sketch with a duplicate quests key, while actual version is v4. Reconcile these in a docs-specific task.

## Execution order after this visual/UI milestone

1. Human re-test the now-clickable title and one full farm loop (Gate A evidence). Critical bug fixes above may be implemented before adding new systems.
2. Close foundational simulation/save/localization/input/collision gaps with independent regression tests.
3. Complete economy 5.1–5.6, then production/building 6, then ecology/director 7; each row is a separate reviewed commit with data/schema/save migrations where needed.
4. Complete dog/story 8.5/8.6, then vertical slice 9 and clean Windows export.
5. Pass Gate B using real players before online 10. Expansion/release work follows afterwards.

The current codebase is a playable MVP slice, not a completed release. “Finish missing work” is tracked by this list; absent systems and human gates are not silently marked done by the UI task.
