# DECISIONS — THE LIFE

Format of every entry: **ID — Decision — Why — Consequence — Changeable until — Status.**
Rule: never edit an old decision in place. To change one, add a new entry "Dxx supersedes Dyy" and mark the old one `Superseded`.
Status `DEFAULT` = a recommended default chosen for you. Change it to `LOCKED` once YOU have read it and agree (tick the box). Date written: 2026-10-24.

---

### D01 — Technical direction: real 3D, orthographic `Camera3D`  `[ ] confirmed`  Status: DEFAULT
- Logical grid is a 2D `Vector2i` mapped onto the XZ plane. Aseprite is for UI icons / pixel textures only, not world sprites.
- Why: day/night/rain lighting, shadows; the depth buffer solves draw order (avoids isometric 2D Z-sort pain); multi-cell buildings do not break y-sort; many CC0 3D assets exist.
- Consequence: heavier asset pipeline for a solo developer.
- Fallback rule (spike): if the 1-week asset spike (Master Plan 10.9) cannot produce 1 character + 1 crop + 1 ground tile at the right scale/angle, switch to the 2D plan (Master Plan 10.8).
- Changeable until: before Phase 0.4 (gray-box). After that, practically never.

### D02 — Platform: PC first (Windows), keyboard + mouse  `[ ] confirmed`  Status: DEFAULT
- Mobile is a different project (UI, performance, input). Release target: Steam and/or itch.io.
- Changeable until: before Phase 1.

### D03 — Time model  `[ ] confirmed`  Status: DEFAULT
- Three clocks, never mixed: real time; in-game clock 06:00 → 26:00 (02:00 next day), one game day = `DAY_REAL_SECONDS` (default 720 s = 12 min, a data parameter); crop/machine counters in `day_index` and `total_minutes`.
- Crops store `planted_day`; machines store `finish_at_total_minutes`.
- Closing the game pauses the world (MVP). Offline progress is an optional Phase 11 feature: capped (e.g. 5 game days per launch), negative events off, backwards-clock detection, same `simulate_day()` path.
- Changeable until: before Phase 2 (GameClock).

### D04 — Authority: local-authoritative world; server only for non-competitive social  `[ ] confirmed`  Status: DEFAULT
- Gifts (cosmetic / capped), friend snapshots, capped community-project ledger, "casual" leaderboard. No client-reported coin/score is trusted.
- Changeable until: before Phase 10.

### D05 — Monetization: premium (one-time purchase)  `[ ] confirmed`  Status: DEFAULT
- No IAP, no premium currency, no gacha, no ads. Only Coin (+ a non-currency "valley development" progress value).
- Changeable until: before Phase 5 (economy).

### D06 — Pressure philosophy: "Telegraph – Explain – Counter"  `[ ] confirmed`  Status: DEFAULT
- Weather/events never silently punish and never destroy a season of crops. Every negative event is forecast (when the station is repaired), explained (ecology journal) and counterable.
- Changeable until: before Phase 7.

### D07 — Languages: Vietnamese + English from day one  `[ ] confirmed`  Status: DEFAULT
- `tr()` everywhere, `KEY_SNAKE` keys, `localization/` files. Font must render all Vietnamese diacritics (Phase 0 test).
- Changeable until: before Phase 3 (UI). Adding more languages later is always possible.

### D08 — Godot version & renderer  `[x] confirmed`  Status: LOCKED
- Pin Godot `4.7.2-stable`, renderer `Forward+`, and Jolt Physics.
- Only patch releases may be adopted mid-project, deliberately, after running all tests + golden tests.
- Changeable until: before Phase 0.4. Treat as frozen afterwards.

### D09 — Controls  `[ ] confirmed`  Status: DEFAULT
- WASD camera-relative movement; mouse targets a cell within reach (2 cells around the player); `use_tool`; hotbar keys 1–9. Gamepad later (Phase 11) but action names are standard from the start.
- Changeable until: before Phase 4 (ToolAction).

### D10 — Daily scarcity ("bottlenecks")  `[ ] confirmed`  Status: DEFAULT
- Without limits players "do everything, then sleep". MVP limits: number of tillable plots (unlocked by expansion), watering-can capacity (upgradable; auto-irrigation unlocks in Chapter II), the 02:00 day end (no harsh penalty — wake up a little later, lose nothing), daily order refresh and machine slots, inventory capacity.
- No stamina bar in the MVP; optional in Phase 11 if playtests show the need.

### D11 — Reasons to stay up at night  `[ ] confirmed`  Status: DEFAULT
- Merchant Minh at the market 17:00–22:00 on set days; night-only fish / fireflies / collectibles; NPC schedules; machines finishing at set hours; end-of-day order deadlines; timed festival events.

### D12 — Naming  `[ ] confirmed`  Status: DEFAULT
- Player-facing: "Cỗ máy Mùa" / Season Machine. Code/docs: `EventDirector`, `WeatherService`, `EcologyState`. The rule-based system is never called "AI"; no LLM calls at runtime.

### D13 — Camera  `[x] confirmed`  Status: LOCKED
- `Camera3D` projection = orthogonal; yaw `45°`; pitch `35°`. Locked BEFORE assets are made (shadows, model heights, tile highlight depend on it). Zoom: 2–3 small levels. No free rotation in the MVP.

### D14 — Grid cell size  `[ ] confirmed`  Status: DEFAULT
- 1 logical cell = 1 × 1 m (1 Blender unit = 1 Godot metre). Character height ≈ 1.2–1.5 cells. Buildings declare `footprint: Vector2i` in data.

### D15 — Player-to-player text  `[ ] confirmed`  Status: DEFAULT
- No free chat. Preset phrases and emotes only. If free text is ever added: filtering/moderation + report button are mandatory.

### D16 — Tools  `[ ] confirmed`  Status: DEFAULT
- Godot Editor (scenes, Inspector, run) + VS Code or Google Antigravity (code) + Git/GitHub (private) with Git LFS + ONE of GUT / gdUnit4 + gdtoolkit (gdlint/gdformat) if compatible with the pinned version.

### D17 — Director & Season Machine policy  `[ ] confirmed`  Status: DEFAULT
- Chapter I: the machine "sleeps"; weather is simple, seeded, by season. Chapter II (observation station repaired, milestone M2.4): `EventDirector` + forecast switch on. After 100% balance: "maintenance mode" (few negative events, optional challenges), never removed.

### D18 — Post-story content  `[ ] confirmed`  Status: DEFAULT
- Finishing the story is not the end: collections, free decoration, seasonal festivals, special orders, community projects, self-set goals.

### D19 — Early living-world slice scope — The requested day/night, weather and four-season systems are implemented before the Roadmap's later phase gates — Why: the product owner explicitly requested all three systems as the next continuous milestone — Consequence: the implementation remains placeholder/data-driven and does not add NPCs, economy or director systems — Changeable until: before production content — Status: DEFAULT

### D20 — MVP Economy: Distinct Seed & Produce Items, Shipping Bin, and Seed Shop with Season Filtering — Implemented dedicated seed and produce items for all crops with differentiated buy/sell values and colors, a shipping bin for selling produce near the farmhouse, an in-world seed shop with season filtering and atomic purchasing, wallet HUD integration, tutorial onboarding expansion (sell & buy), and save_version 3 migration. — Why: explicitly requested to establish the complete farming economic loop and prevent starter crop softlocks across all seasons. — Consequence: save_version bumped to 3; migration maps previous save files to version 3 with default wallet state. — Status: DEFAULT

### D21 — Phase 8 NPC/quest slice (2026-10-26) — Status: LOCKED by task scope
- Follow Roadmap 8.1–8.4: data-driven dialogue, a saved delivery quest, grid schedules, scheduled merchant visits with daily varying stock. Dog (8.5) and Chapter I content (8.6) remain separate tasks.
- Resolve the daily-merchant wording in favor of the Roadmap: prepare an offer each day, but Minh trades only during his data-defined visits (days 3 and 6 of the seven-day week), near the seed shop. Night and rain send all NPCs home.
- Keep base item prices unchanged. Merchant prices are isolated transaction quotes and cannot affect the existing year simulation.
- Use existing WalletState/InventoryState APIs as explicitly requested; do not introduce EconomyService/InventoryService refactors in this slice.
- Preserve `quests` for onboarding; v4 adds `social` for active/completed NPC quests, relationships, heard dialogue and consumed daily offers. Migrate v3 with empty social defaults while preserving all existing fields.

### D22 — UI readability and modal ownership (2026-10-26) — Status: LOCKED by playtest repair request
- Player screenshots showed overlapping inventory/pause/debug/prompt panels and unreadable hotbar/world labels. Main now owns a view-only UiCoordinator: one modal at a time, consistent close/switch input, dim background, hidden secondary HUD/prompt, and correct movement/clock restoration.
- Runtime Theme duplicates the existing resource: 18 px body, 24 px headings, at least 40 px main buttons; hotbar item labels use 16 px plus an 18 px full-name caption. Shared Theme/scene assets stay untouched within the authorized file scope.
- The hotbar displays nine slots matching keys 1–9; I still exposes every inventory slot. No inventory capacity, item quantity, transaction, NPC schedule or save format changes.
- This supersedes the earlier 14 px presentation and simultaneous-panel layout expectations only. UI tests now exercise visible panels one at a time, real shortcut transitions, full inventories, settings, both locales and three resolutions.

### D23 — Click-through regression and cozy chibi presentation (2026-10-26) — Status: LOCKED by explicit product request
- Fix event hit ordering: the backdrop precedes modal Controls in sibling order, and GUI mouse events are not consumed by gameplay key filters. Physical mouse tests use an isolated viewport to avoid GUT's own overlay intercepting clicks. Windows app testing confirms the title/settings/new-game/backpack/close sequence.
- Authorize original SVG icons under assets/icons, generated title illustration under assets/ui, and procedural low-poly chibi characters/scenery in view scripts with gentle idle/walk presentation. Shared scenes and save v4 schema remain intact. The puppy in title art does not represent a completed dog system.
- Always show the title screen; Continue resolves both slots through load_latest; New Game initializes a clean world through existing state APIs. Icons replace repeated text in HUD/tool slots while localized names/tooltips and quantities remain.
- Whole-project audit is recorded in PROJECT_AUDIT.md/SOURCE_AUDIT.md. The user's broad completion request is acknowledged as sequential Roadmap work; Gate A/B require human/stranger evidence, and external online/release steps are not claimed complete automatically.

### D24 — Compact HUD and click-to-inspect harvest estimate (2026-10-27) — Status: LOCKED by player feedback
- The permanent nine-slot item bar covered the map. Hide its grid/caption in gameplay, retain four small tool buttons and smaller corner menu targets; full item selection lives in InventoryPanel. Existing 1–9 shortcuts remain compatible.
- Replace tiny repeated crop text with a readable, nonmodal click-selected card. Count down in game days/hours/minutes to the estimated morning growth boundary, explicitly conditional on daily watering and a suitable season. Missing a watering day moves the forecast; this does not introduce real-time crop growth or change DaySimulator/save v4.
- Clicking a crop is inspection only. Water/Harvest are explicit card buttons using the existing controller, reach checks and atomic harvest-to-inventory flow. Clicking the visual top of a mature crop must select that crop, rather than a neighboring ground cell.

### D25 — Native low-poly farm/world art pass (2026-10-27) — Status: LOCKED by player visual feedback
- Replace identical crop cubes with lightweight native 3D silhouettes for sprouts, roots, vines, stalks, grains, pumpkins and leafy crops. The same crop root remains the click target, and all crop rules/timing stay in FarmGridState/DaySimulator.
- Present the player house, seed market, shipping bin and NPC homes as visibly different view-only structures around their existing anchors. Decorative rocks/moss live outside farm cells and do not become hidden collision blockers.
- Favor restrained Forward+ filmic color, small glow, shallow fog and soft directional shadows over global illumination or expensive shaders. DayNightProfile and weather remain the data sources; the art layer never owns time/weather values.
- This task deliberately uses reproducible Godot primitive meshes rather than a newly generated bitmap/model dependency. It fulfills the requested chibi low-poly look while preserving Windows mid-range performance, source transparency and existing marker/collision tests.

### D26 — Separated farm landmarks, original effects and grounded terrain (2026-10-27) — Status: LOCKED by player visual feedback
- The player cottage stays at `(11, 0, 10)` while the shipping-bin mesh and `%ShippingBinMarker` move together to `(5.2, 0, 10)`, making home and sale destination unambiguous without changing interaction reach, save data or transaction rules. Extra cottages, path stones, grass and rocks are non-interactive visuals.
- The existing successful farming action calls now use four compact, deterministic, project-generated PCM WAV effects. AudioService prefers an existing OGG asset, falls back to WAV, and applies the already-saved effects-volume preference. No music, ambient system, economy or gameplay feedback timing is introduced by this decision.
- Ground fidelity stays primitive-mesh based: tilled cells gain view-only furrows and watered tilled cells a subtle sheen. Warm filmic fog/shadow tuning improves sunlight while DayNightProfile and WeatherState retain ownership of all clock/weather values.

### D27 — Two-product harvest and drag farming strokes (2026-10-27) — Status: LOCKED by player request
- Every current crop Resource sets `yield_qty = 2`: one seed is consumed only after a valid planting action and one mature crop grants two product items only after the existing inventory-capacity check succeeds. Yield remains data-owned, must be positive, and needs no save migration because planted plots save only their stable crop id.
- Holding the existing left-use input across farm cells reuses the established seed/water/harvest action path. A cell is submitted once per held stroke, out-of-reach cells are ignored, and inventory/harvest atomics remain unchanged. There is no new InputMap action or timed auto-farming loop.
- A default hoe click on an occupied crop remains the way to open CropInspector. Selecting the existing Harvest control now chooses direct harvest mode, so click/drag harvest no longer has to route through the inspector button.
- This intentionally raises current crop returns without changing prices. The year simulation is retained and asserts the data-defined yield; a dedicated later balance pass must set intended profit caps/prices rather than hiding this requested output change in code.

### D28 — Chibi art-core start before deferred M0 automation (2026-10-27) — Status: LOCKED by direct product-owner request
- The product owner explicitly started C0 after the clean M1 boundary while the broader `MASTER_PROMPT` M0 additions (`smoke_run`, autoplay, full capture matrix, baseline measurements/tag and global `build_assets`) remain deferred. This C0 commit must not imply that deferred automation is complete.
- C0 is deliberately additive and opt-in: a validated `ArtPalette`, generated shader/material/model calibration assets, mesh audit/build tooling and a review-only lineup. Existing runtime presentation, scenes, game logic, save schema and data IDs remain untouched.
- Palette roles and triangle budgets live in data. The contact sheet requires a normal graphics renderer and verifies calibration assets only; it does not substitute for future real-game-scene capture. Runtime outline toggling and model migrations are later chibi milestones.

### D29 — C1 cosmetics, character presentation and dog-art boundary (2026-10-28) — Status: LOCKED by approved C1 scope
- The optional normalized cosmetic value lives inside the existing opaque `profile.appearance` dictionary. It does not change save version 4: old profiles normalize to the catalogue default while all unrelated old-save progress remains intact.
- The C1 avatar rig, face, held tools, clips and reaction bubble are view-only children beneath existing player/actor anchors. Player, Minh and Linh retain their existing state, schedules, positions, collisions, interaction range and Phase 8 ownership; An and Bac Lam are generated/reviewed art assets only until their data-backed gameplay anchors are introduced by a later approved milestone.
- The dog model is a calibration/reference asset only. It does not add dog following, naming, collision, input, save data or Roadmap 8.5 behavior, preserving D21's phase boundary.
- `tools\capture_chibi_characters.bat` may make an in-memory daylight showcase arrangement only when passed through the private project command-line review flag. It starts no save, writes no save and exits immediately; it is evidence for C1 visual integration, not gameplay authority or a public debug action.

### D30 — C2 chibi farming presentation preserves farming authority (2026-10-29) — Status: LOCKED by approved C2 scope
- C2 maps the existing nine crop IDs to generated stage scenes, generated item/tool props, stickers and data-owned visual colors. `FarmGridState`, crop timing/yield, inventory atomicity, drag strokes, wallet, weather, DayNightProfile and save v4 remain authoritative and are not changed by art assets.
- `ItemData.model_path` and `ItemData.icon_path` are optional presentation metadata only. The v4 save format continues to use stable item IDs and quantities, so no migration or economy change is warranted.
- Crop picking stays on the existing logical root, not individual generated leaves/fruit. Farm VFX are spawned only after the pre-existing successful action flow returns; failed, out-of-reach, missing-item and capacity-blocked actions create no effect.
- The generated source asset scenes preserve C0 material intent. Under the current world’s daylight pipeline, C2 applies a local view-only readability material override so crop silhouettes are not lost to dark shading. This is deliberately constrained to instantiated crop presentation and does not alter shared materials, scene lighting, gameplay data or the C0 review contract.
- C2 updates the affected visual assertions from old primitive child names to the stable `CropVisual`/stage contract. Crop inspector/root-picking and drag-farming regression tests remain required, so visual replacement cannot conceal an interaction regression.

### D31 — C3 generated chibi world is a view-only M5/M6 slice (2026-10-29) — Status: LOCKED by approved C3 scope
- C3 delivers reproducible presentation for buildings, paths, water, boundary, village props, background creatures and seasonal ambience. It is not completion of later building/occupancy, ecology/director, map expansion or story mechanics: `WorldArtCatalog` remains visual-only and no save/schema/domain/input/event authority is added.
- Existing House, SeedShop, ShippingBin, NPC-home and marker transforms, collision, NPC routes/schedules, FarmView/crop picking, wallet/shop/bin mechanics and save v4 remain authoritative. C3 placements are catalogued outside farm cells and interaction reach; all ambience observes existing GameClock/WeatherState only and stays within its visual cap.
- Generated source scenes retain C0 shader vocabulary. The existing main-world DayNightProfile renderer makes the C0 toon/outline combination render nearly black on C3 geometry, so runtime C3 toon instances deliberately receive a local readable `StandardMaterial3D`; foliage/water retain their lightweight shader behavior. This fixes presentation only and does not mutate source resources, palette data or lighting authority.
- C3 intentionally replaces old primitive-child visual assertions with stable generated-asset, safe-placement, grouped-art and anchor-transform assertions. Existing farm picking, NPC/merchant marker, weather/day-night, save and interaction tests remain in the full suite, so the visual migration cannot conceal a gameplay regression.

### D32 — C4 chibi UI stays map-first and input-neutral (2026-10-30) — Status: LOCKED by approved C4 scope
- C4 extends the existing runtime Theme rather than replacing scene-built Controls. Cream/pastel pill panels, native themed tooltips, outlined title typography and short view-only bounce use the C0 palette, Open Sans and existing localized labels/tooltips. No gameplay strings, UI scene path or modal API is renamed.
- `ChibiCursor` is project-original code art above the GUI. It hides the OS cursor only for its live non-headless lifetime, restores it on exit, ignores mouse filtering and never calls tool/farm/world methods. `ChibiUiMotion` merely observes real Control signals; tool badges follow the existing tool button `pressed` signal and do not become another selection authority.
- Compact tool/menu bars are intentionally retained at their D24 footprints so the map remains readable. Full inventory and all transaction/detail UI stay modal/scrollable. Keyboard focus improves access to the title/form/settings/modal controls without adding an InputMap action or bypassing `UiCoordinator`.
- The private `--capture-chibi-ui` path starts no save load/write flow and exits after title/HUD capture. It is C4 visual evidence only; the deferred M0 full screenshot/autoplay matrix remains deferred.
