# PROJECT RULES — THE LIFE

The law of the project. Agents read this every session. Changing anything here requires a new entry in `docs/DECISIONS.md` (never silently edit a locked rule).

Items marked `<<FILL: ...>>` must be filled by the human before roadmap task 0.1 starts. An agent that finds an unfilled marker must STOP and ask.

---

## 1. Engine & tooling (LOCKED)

| Item | Value |
|---|---|
| Godot version | `<<FILL: exact version, e.g. 4.x.y-stable — take the latest stable from godotengine.org/download and write it here>>` |
| Renderer | `<<FILL: Forward+ / Mobile / Compatibility — choose one, never change>>` |
| 3D physics engine | `<<FILL: default or Jolt, if your pinned version offers a choice — choose one>>` |
| Language | GDScript 2.0, static typing everywhere |
| Test framework | `<<FILL: GUT or gdUnit4 — choose ONE>>` |
| Run all tests | `<<FILL: exact headless command; also stored in tools/run_tests.sh and tools/run_tests.bat>>` |
| Parse check | `godot --headless --path . --quit` (wrapped by `tools/check_parse.*`; must exit 0) |
| Lint / format | `gdlint`, `gdformat` from gdtoolkit `<<FILL: version matching your Godot major>>` |
| Target hardware | `<<FILL: e.g. mid-range PC, 8 GB RAM, integrated or entry GPU — used for performance budgets>>` |
| Window / UI | 1920x1080 base, stretch mode `canvas_items` |
| Platform | PC first (Windows); input = keyboard + mouse (see D02, D09) |

API names change between Godot 4.x versions (e.g. `TileMapLayer` since 4.3, typed Dictionary since 4.4). Before using any API you are not 100% sure exists in the PINNED version, check the official docs for that version or ask the human. Do not guess.

## 2. Architecture

```
DATA (Resource .tres / CSV)  ->  DOMAIN (RefCounted, no Node)  ->  VIEW (Node / Control)
```

- Dependency direction is one-way. VIEW reads DOMAIN and sends requests to it. DOMAIN reads DATA. DATA knows nothing.
- DOMAIN state is the single source of truth (`WorldState`). Scenes are only a way to display it.
- DOMAIN code must be testable without opening the editor (no Node, no SceneTree, no UI).
- Autoloads, in this order, maximum 6: `Events`, `Settings`, `DataRegistry`, `SaveService`, `GameClock`, `Net` (later). Autoloads hold no references to nodes and are not "god objects". Do NOT give an autoload script a `class_name` equal to the autoload's name.
- `WorldState` (farm grid, inventory, economy, occupancy, ecology, weather, director, quests…) is a domain object owned by the main game flow, not an autoload.
- Single owners: only `EconomyService` changes coins. Only `InventoryService` changes items. Both log every change (reason required).
- One simulation path: `DaySimulator.simulate_day(world)` in the fixed order in `docs/ARCHITECTURE.md`. Sleeping, the 02:00 cutoff and (later) offline catch-up all call it.
- Grid: logical grid is `Vector2i` on the XZ plane (`cell.y` ↔ `world.z`). `GridMath` is the ONLY converter between world and cell. Use `floori()`, never `int()`, for negative-safe division. Only the camera is rotated 45°; never use a diamond coordinate system for logic. Never store a world position as truth — store cell + facing.
- Network: gameplay never calls HTTP directly; everything goes through `Net` → `NetworkGateway` (with a `MockBackend`). World state is local-authoritative (D04).
- The player's world pauses when the game is closed (D03). No offline progress in the MVP.

## 3. Directory layout

See `docs/ARCHITECTURE.md` §Directory map. Do not create new top-level folders without a DECISIONS entry.

## 4. GDScript style

- Files, variables, functions: `snake_case`. `class_name`: `PascalCase`. Constants: `UPPER_SNAKE`. Signals: past-tense verbs (`day_started`, `crop_harvested`). Private members: leading `_`.
- Static types on every `var`, parameter and return type. Enable the "untyped declaration" warning in Project Settings.
- One responsibility per script; aim for ≤ 250 lines. Longer → split.
- Domain scripts start with a header comment block:

```gdscript
## <ClassName> — one-line purpose.
## API:
##   func foo(a: int) -> bool
##   signal bar_changed(x: int)
```

  `docs/API_INDEX.md` is assembled from these headers.
- No `get_node("../../X")` chains and no absolute scene paths. Use `@export var x: Type`, `%UniqueName` inside the same scene, or a service.
- Connect signals in code so they are visible in scripts.
- Errors: domain functions return explicit results (bool / result object / error code). Never swallow errors silently. Log with context through the `Log` utility.
- Comments explain WHY, not WHAT.

## 5. Forbidden patterns

Godot 3 leftovers:
`onready var`, `export var`, `yield`, `connect("sig", obj, "method")`, `instance()`, `KinematicBody*`, `Spatial`, `.translation`, `rand_range`, `OS.get_ticks_msec`, `setget`, `PoolStringArray` and other `Pool*Array`, `File` / `Directory` (use `FileAccess` / `DirAccess`), `change_scene()`.

`move_and_slide()` takes NO arguments in Godot 4 (it uses the `velocity` property).

Bad patterns:
- string-based `emit_signal("x")` — use typed signals.
- `randi()` / `randf()` global functions for gameplay — use `DetRandom`.
- `float` for coins or quantities.
- Hardcoded gameplay numbers in scripts.
- Crop/machine growth driven by `_process(delta)` or `Timer` nodes.
- Loading `.tres` / `.res` from untrusted sources (saves, network, shared files): they can embed scripts. Shared data is validated JSON only.
- Trusting save data or any client-provided data. Validate every external input.
- Saving node trees (`PackedScene.pack`). Save domain state; rebuild scenes from it.
- God scripts, duplicated logic across systems, new autoloads "for convenience".
- Calling the rule-based event system "AI" in code, docs or UI text. No LLM calls at runtime.

## 6. Data

- All gameplay values live in Resources (`data/**.tres`) or CSV (`data_src/**`). Rules and exact schemas: `docs/DATA_SCHEMA.md`.
- Ids are `StringName`, `snake_case`, and are never renamed. If a rename is unavoidable, add an entry to the `deprecated_ids` map and write a save migration.
- Asset file name == data id. Never invent asset paths; derive them from the id (naming table in `docs/DATA_SCHEMA.md`).
- Every user-visible string uses `tr()` with a `KEY_SNAKE` key present in both `vi` and `en` files in `localization/`.
- `DataValidator` (headless) must pass before every commit: unique ids, resolved references, existing icons, translation keys in both languages, profit-per-plot-day and value-added-per-game-hour under the stage caps.

## 7. Time & simulation

- Three separate clocks, never mixed (D03): real time; in-game clock (06:00 → 26:00, i.e. 02:00 next morning; one game day = `DAY_REAL_SECONDS` real seconds, a data parameter); crop/machine counters in `day_index` and `total_minutes`.
- `total_minutes = day_index * 1440 + minute_of_day`.
- A crop stores `planted_day`; its growth stage is derived. A machine job stores `finish_at_total_minutes`.
- `GameClock` only holds time and emits signals (`day_started`, `hour_changed`, `season_changed`, `sleep_requested`). It does not run the simulation.
- Weather/events/orders for day D are a pure function of `(world_seed, D, tag, data)`, pre-rolled up to 3 days ahead and SAVED. Loading never re-rolls (anti save-scum).

## 8. Economy & inventory

- Coins and item quantities are `int`. Every coin change goes through `EconomyService` with a `reason: StringName` and is recorded in the ledger.
- Purchases/sales are atomic transactions with rollback (spend first, grant second; remove first, earn second).
- Full inventory never destroys items: the action is blocked with feedback and the world stays unchanged.
- The cheapest basic seeds are always buyable (anti-softlock). NPC buy price ≥ NPC sell price for the same item.
- No weekly upkeep fees. Machines pause when their output buffer is full; they never break or punish absence (N6).
- Pressure on the player must be telegraphed, explained and counterable (N4).

## 9. Randomness & determinism

- Use `DetRandom.make_rng(world_seed, day, TAG_*)`. Tags are integer constants in `det_random.gd`.
- Do not rely on engine `hash()` / `String.hash()` for gameplay seeds (not guaranteed stable across versions).
- Golden tests pin outputs: seed X → sequence Y. If a Godot upgrade breaks a golden test, update it deliberately and record why.

## 10. State & saving

- Every stateful domain class implements `serialize() -> Dictionary` and `deserialize(d: Dictionary) -> void`.
- JSON loses types: cast ints explicitly after loading; `Vector2i` is stored as `"x,y"`; `StringName` is stored as `String`.
- Writes are atomic: write `*.tmp`, rotate backups (keep 3), then rename. Test the rename on Windows.
- Bump `save_version` and add `migrate_N_to_N+1` for any schema change; keep a golden save per version in `tests/golden_saves/` and never delete old ones.
- On load: validate each field (clamp, id exists), drop unknown parts with a warning, never crash. Fuzz-test corrupted JSON.
- Save only at safe points (no half-finished transaction or forced dialogue).
- Save path: `user://saves/slot_N.json`. Player settings live separately in `user://settings.cfg`.

## 11. Scenes & Inspector

- Agents write scripts and simple `.tres`. The human builds complex scenes in the editor following `docs/SCENE_CONTRACTS/*.md`.
- Do not edit `.tscn` unless it is listed in the ALLOW_LIST.
- A scene contract lists the node tree, unique names, `@export` variables (typed), signals, groups and collision layers. Agents use ONLY what the contract documents. If a node is needed that is not documented: ask, or create a stub and report it.
- Use `class_name` on important scripts so references can be typed.

## 12. Physics, input, layers

- Collision layer names/numbers come only from `docs/COLLISION_LAYERS.md`. Input actions come only from `docs/INPUT_MAP.md`. Both must match `project.godot`.
- Movement is camera-relative (input rotated by camera yaw).
- Gameplay input goes through `_unhandled_input` so UI can consume events first. Never read raw keys (`KEY_W`) in gameplay.

## 13. Localization

- No hardcoded display strings in code. `KEY_SNAKE` keys, `localization/*.csv` (or `.po`) for `vi` and `en`.
- The chosen UI font MUST render all Vietnamese diacritics. Phase 0 test string: `Thung Lũng Sống ẩn ệ ữ ợ ỡ ằ ẫ`.

## 14. Testing & honesty

- Every task adds or updates tests, runs them, and pastes the real output.
- Domain logic: unit tests without the editor. Systems: headless integration tests (e.g. sleep N days). Data: validator. Time-based systems: golden tests.
- If a test fails, fix the code, not the test — unless the test is wrong, in which case explain why.
- Never claim something works because it "should". Say what you ran and what you saw.

## 15. Process

- One milestone at a time, taken from the roadmap in `docs/ROADMAP.md`. Do not implement future systems.
- Work only inside the ALLOW_LIST. Preserve working behavior.
- The human commits before and after each task. Agents propose a one-line commit message.
- If requirements are ambiguous, ask ONE concise question before coding.
- Sessions are short: one task per session. Anything the next session must know goes into `docs/PROGRESS.md`.

## 16. Required output per task

1. Acceptance criteria  2. Files created/modified  3. Full contents  4. Manual editor steps  5. How to run + manual test cases  6. Assumptions + known failure points  7. Updates to `API_INDEX.md` and `PROGRESS.md`  8. Real test output + commit message.

## 17. Definition of Done

- All acceptance criteria met.
- Headless tests pass and the real log was pasted.
- Parse check exits 0; no new warnings/errors in the Godot Output/Debugger.
- Human ran the manual test cases in the editor.
- `docs/API_INDEX.md` and `docs/PROGRESS.md` updated.
- Committed with a clear message (tagged if it ends a milestone).
