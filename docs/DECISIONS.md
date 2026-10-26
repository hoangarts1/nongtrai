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
