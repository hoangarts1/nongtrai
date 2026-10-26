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
