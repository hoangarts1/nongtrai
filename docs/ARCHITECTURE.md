# ARCHITECTURE — THE LIFE

Source of truth for how the pieces fit. Agents update the relevant table whenever they add a signal, autoload, domain class or save field.

## 0. 2D migration target (D33–D35, 2026-11-02)

Status: ISO-1 active scenes are now 2D (D36). The legacy architecture tables/save sketch below are retained as historical target context; API_INDEX and this section describe the implemented migration. Human editor playtest remains pending.

- DATA → DOMAIN → VIEW remains unchanged. Farm/inventory/wallet/clock/weather/quest state and deterministic simulation remain authoritative. No UI owns gameplay state.
- The logical farm is `Vector2i -> plot data`; no TileSet, camera, Node or pixel position belongs in domain state.
- Target world: `Node2D`, Ground and Farmland `TileMapLayer`, Objects `Node2D` with y-sorting, Highlight overlay. Isometric TileSet tiles are 64×32 px. Conversion belongs to VIEW and uses `map_to_local()` / `local_to_map()` including the layer's local/global transforms. `GridMath` remains responsible for pure logical footprint operations, not a second isometric projection.
- Player: `CharacterBody2D`, grounded placeholder visual and a child `Camera2D`. Screen-relative normalized input is vertically compressed by 0.5; camera follow/zoom must not change cell picking. Layer numbers/names remain the eight entries in COLLISION_LAYERS, migrated to 2D physics.
- Target design size is 1152×648 with `canvas_items` and preserved aspect. UI uses anchors/containers. ISO-1 retains current UI, fonts, InputMap and autoload configuration; ISO-2 introduces the single `ui/theme/the_life_theme.tres` and reusable UI components. `ui/` is the approved new top-level UI resource directory (D34).
- Existing NPC routes are logical cells. Their legacy `WorldLocations` Vector3 data and `GridMath` calls require an explicit adapter/migration; domain routing must not start consulting TileMapLayer. Existing save v4/golden saves are preserved; change save version only if a payload/schema actually changes.
- Existing weather/time services are kept. Their 3D renderers must be replaced with 2D views; CanvasModulate, house-light and rain attachment points must not invent weather values. Detailed visual polish follows the relevant UI/world step.
- Keep old generated 3D art/review assets intact as historical tools. ISO-1 acceptance requires no 3D node in the active gameplay tree; it does not authorize deleting archive assets or bypassing their tests.
- No new bus signal, autoload or save field is defined by ISO-0. Planned APIs must remain separate from the implemented API index.

## 1. Layers and dependency direction

ISO-9 boundary (D46): Main owns LifeMorningFlow, a presentation-only queue appended to the existing completed day_started path. The flow waits for synchronous day-end/final save, sleep and other modal guards; MorningSnapshot reads real date/weather/farm/quest/price values and MorningPresenter formats them into six native scene components. No domain simulation, forecast roll, transaction or save mutation occurs during display/dismissal. Pending/last-shown ints are transient, reset on New Game/load/title, and never saved; Continue/tutorial do not generate a bulletin. UiCoordinator retains sole modal ownership, prior hold restoration and day-end precedence. Core/domain/data/DayEndFlow/v8/goldens remain unchanged; unsupported calendar/trends stay explicit.

ISO-8b boundary (D45): reference02 creation reuses the StartMenu/profile request lifecycle. UI-only name fields, six-choice rows/swatches and presenter own drafts; existing catalogue normalizes them, unchanged Main applies them only after Start. One submission latch stops reentry. UI-local Node2D preview and actual player share PlaceholderAvatar2D/AvatarHair2D silhouettes and colors; empty NPC customization keeps legacy hair. No data/domain/save/clock/collision/input/bus/3D state is added. Profile becomes a wide two-panel consumer of the same modal owner/Theme.

ISO-8a boundary (D44): StartMenu remains Main's existing entry adapter; five ui/title scene/script pairs plus presenter/helpers replace only script-created title internals. SaveService's actual newest payload supplies read-only summary; Settings owns preferences, the existing appearance catalogue normalizes choices, and unchanged Main callbacks own game initialization/continue/quit. Transient view mode/drafts/names do not become game state before a request. UiCoordinator retains one modal owner across title/profile/settings and blocks the world. Existing background, all old scene files, core/domain/data, v8 format and golden saves stay unchanged.

ISO-7 boundary (D43): PauseMenu remains a Main child adapter; six small ui/pause scene/script pairs plus a presenter compose reference14. Controls hold transient drafts only; Settings remains the preference authority and SaveService remains the atomic JSON authority. Main callbacks propagate bool outcomes without a save schema change. UiCoordinator retains exclusivity, existing pause holds and day-end precedence; native GUI keys precede overlapping world shortcuts inside pause. Unsupported mockup preferences remain disabled. No new autoload, Events signal, InputMap action or domain state.

ISO-4 boundary (D39): Main owns LifeDayEndFlow, which holds pure DayLedgerState/DayEndState and a read-only modular sheet. The flow observes existing wallet deltas/trade metadata and never spends/grants coins. Bed requests or GameClock's cutoff signal open one modal review and hold the clock. Confirm is latched through the existing sleep_to_morning -> Main.day_started -> DaySimulator path, emits existing sleep notifications and autosaves only after completion. No new autoload, bus signal or InputMap action.

ISO-3 active HUD (D38): Main wires a `LifeHudPresenter` to a `LifeHudRoot` and the existing HUD adapters. `LifeHudRegions` handles anchors independently of bindings. Dedicated clock/arc, pinned checklist, eight-slot toolbar/slot, shortcut bar and toast stack/card scripts supply small reusable views under `ui/hud/`. World remains CanvasLayer 0; Main HUD layer 1; existing interaction layer 2; modal backdrop/panels use z80/81 and supported transaction-result toasts z82. Existing Main direct paths and Label text adapters remain compatible while their obsolete visual surfaces are hidden. No UI owns coins, inventory, weather, tutorial completion or simulation. B now opens inventory; `open_build` remains as an unbound action ID. No new domain system/autoload/save field is introduced.

ISO-2 implemented UI foundation (D37): `ui/theme/the_life_theme.tres` is the project GUI theme and the same resource is assigned to active Main panels, world labels and the standalone gallery. `LifeTheme` is a VIEW resource accessor; `LifeThemeFactory` and `tools/build_ui_theme.gd` are offline tooling, never a new autoload. `ui/components/` contains native Controls with read-only display setters and request signals. Consumers remain responsible for validating requests through existing services. Gallery examples own no domain state and never save. Body/headings/secondary fonts are Nunito 600, Baloo 2 800 and Noto Serif Italic 400 with Open Sans fallback. Existing C4 geometry, modal ownership, InputMap, autoload order and save v4 are unchanged; final artwork and ISO-3 onward remain separate tasks.

```
DATA (Resource .tres / CSV)  --->  DOMAIN (RefCounted, no Node)  --->  VIEW (Scene / UI)
   CropData, ItemData,             WorldState: ClockState,             FarmView, HUD,
   RecipeData, NPCData,            FarmGridState, InventoryState,      BuildingView, NPC nodes,
   DirectorEventData ...           EconomyService, OccupancyMap,       VFX, Audio, Lighting
                                   EcologyState, WeatherService,
                                   DirectorState, QuestState
```

- View reads Domain and sends REQUESTS (calls a service or emits a command signal).
- Domain notifies View with typed signals through the `Events` bus.
- Domain reads Data. Data knows nobody.
- Tests exercise Domain without the editor.

## 2. Autoloads (max 6, in this load order)

| # | Name | Role | Notes |
|---|---|---|---|
| 1 | `Events` | Typed signal bus | No logic |
| 2 | `Settings` | Language, volumes, key bindings | Reads/writes `user://settings.cfg` |
| 3 | `DataRegistry` | Loads all `.tres` / CSV into dictionaries by id | `get_item(id)`, `get_crop(id)` … |
| 4 | `SaveService` | Codec, atomic write, backups, migration | Knows save paths |
| 5 | `GameClock` | Day / time / season state + signals | Does not run the simulation |
| 6 | `Net` (later) | Access to `NetworkGateway` | Defaults to `MockBackend` / offline |

Logging is a static `Log` utility class, not an autoload. `WorldState` is a domain object owned by the main game flow.

## 3. WorldState composition (target; grows by milestone)

| Domain class | Owns | Phase |
|---|---|---|
| `ClockState` (inside GameClock) | day_index, minute, season, year; season calendar comes from SeasonData resources | 2 |
| `InventoryState` | item stacks, capacity | 3 |
| `FarmGridState` + `PlotState` | plots by `Vector2i` | 4 |
| `EconomyService` + `Ledger` | coins, ledger, sold_pressure | 5 |
| `ShopService`, `OrderBoard` | prices, daily orders | 5 |
| `MachineState` | jobs with `finish_at_total_minutes` | 6 |
| `OccupancyMap` | which cell is occupied by what | 6 |
| `BuildingsState` | placed buildings (uid, id, origin, rotation) | 6 |
| `WeatherService` | today + pre-rolled forecast | 7 |
| `EcologyState` | tree_cover, water_clarity, biodiversity | 7 |
| `DirectorState` / `EventDirector` | rng_state, history, cooldowns | 7 |
| `QuestState`, `DialogueService` | quests, flags, NPC state | 8 |

## 4. Event catalog (typed signals on `Events`)

Add a row BEFORE emitting a new bus signal.

| Signal | Parameters | Emitted by | Listened by | Phase |
|---|---|---|---|---|
| `day_started` | `day_index: int` | GameClock / DaySimulator | views, UI, audio, lighting | 2 |
| `hour_changed` | `hour: int` | GameClock | lighting, audio, NPC schedule, shops | 2 |
| `season_changed` | `season: StringName` | GameClock | farm, UI, weather | 2 |
| `sleep_requested` | — | bed Interactable | DaySimulator | 2 |
| `inventory_changed` | `slots: PackedInt32Array` | InventoryState | hotbar, inventory UI | 3 |
| `item_added` | `item_id: StringName, qty: int` | InventoryState | quests, UI feedback | 3 |
| `item_removed` | `item_id: StringName, qty: int` | InventoryState | quests | 3 |
| `plot_changed` | `cell: Vector2i` | FarmGridState | FarmView | 4 |
| `plot_tilled` | `cell: Vector2i` | FarmGridState | onboarding state | 4 |
| `plot_watered` | `cell: Vector2i` | FarmGridState | onboarding state | 4 |
| `crop_planted` | `cell: Vector2i, crop_id: StringName` | FarmGridState | audio, quests | 4 |
| `crop_matured` | `cell: Vector2i, crop_id: StringName` | FarmGridState | FarmView, audio | 4 |
| `crop_harvested` | `cell, crop_id, quantity: int, quality: int` | FarmGridState | inventory, quests, ecology stats | 4 |
| `tool_hit` | — (local on the player; bridged to bus if needed) | AnimationPlayer track | farm actions | 4 |
| `coins_changed` | `new_total: int, delta: int, reason: StringName` | EconomyService | HUD, audio | 5 |
| `transaction_failed` | `reason: StringName` | ShopService | UI | 5 |
| `building_placed` | `uid: int, building_id: StringName` | BuildingsState | BuildingView, quests | 6 |
| `weather_changed` | `weather_id: StringName` | WeatherService | lighting, FX, audio, farm | 7 |
| `forecast_updated` | `days: Array` | WeatherService | HUD / forecast UI | 7 |
| `ecology_changed` | `metrics: Dictionary` | EcologyState | journal UI | 7 |
| `threshold_crossed` | `threshold_id: StringName` | EcologyState | moments, FX | 7 |
| `director_decided` | `event_id: StringName` | EventDirector | HUD, debug panel | 7 |
| `quest_updated` | `quest_id: StringName, state: int` | QuestState | HUD | 8 |
| `item_delivered` | `item_id: StringName, qty: int, to: StringName` | OrderBoard / NPC | quests | 5/8 |
| `moment_triggered` | `moment_id: StringName` | MomentService | VFX, audio, dialogue | 7/9 |

## 5. Day simulation order (fixed — `DaySimulator.simulate_day(world)`)

ISO-6b1 (D42) keeps the same path and adds per-plot frozen first/repeat growth targets. FarmGridState owns them; stateless CropCycleRules/FarmSaveCodec use Resource snapshots. UI reads target/remaining values, and Main refreshes existing FarmView after full restore. CropEconomyRules checks current Resource returns against data/crop_economy_config.tres; migration durations live in data/crop_migration_v7.tres, not active script literals. No autoload or bus change.

ISO-6a implemented adapter (D41): the existing GameClock.day_started callback already has the next day index. Main resolves the finished day using its stored plot water and outgoing WeatherState.today, invokes DaySimulator exactly once, marks new-season withering, advances WeatherState, then applies new-morning rain to survivors. Care counters persist in FarmGridState; no simulation is added to views or review/cancel. This corrects the previous new-rain-before-old-day order while retaining the existing sleep/clock/guard path. The larger future world simulation sketch below remains a target, not implemented animal/machine/director APIs.

Triggered by: sleeping, reaching 02:00, or (later) offline catch-up calling it N times.

1. Lock input, fade out.
2. Compute the finished day (no rendering):
   a. `Weather.resolve_today()` (read the pre-rolled value from the save)
   b. `Farm.advance_day(weather)` — grow watered/rained plots; dormant out of season
   c. `Animals.advance_day()`
   d. `Machines.advance_to(total_minutes_next_morning)` — complete due jobs
   e. `Ecology.update(counts)` — ease toward targets; check thresholds
   f. `Economy.new_day()` — recover saturation pressure; generate the new order board
   g. `Quests/NPC.advance_day()`
3. Prepare the new day:
   h. `Weather.preroll(D+3)` if missing (seeded)
   i. `Director.decide(D+1)` if enabled — save the decision and apply timed effects
4. `GameClock`: `day_index += 1`, minute = 360 (06:00), handle season change.
5. `SaveService.autosave()` (safe point).
6. Emit `day_started(day_index)`; fade in.
7. Show the morning summary (weather, forecast, new orders, events).

Invariant (tested): `simulate_day` called N times in a row == N nights of sleeping.

## 6. Save format (JSON, `user://saves/slot_N.json`)

Actual format is v8; v8 adds growth_target/regrowing, preserving pre-v8 first-growth timing via the historical Resource mapping and keeping all previous fields (D42, v1–v8 goldens); v7 adds per-plot consecutive_dry_days with unknown old history defaulting to 0 (D41, v1–v7 goldens); v6 floors player inventory capacity to configured 40, preserves larger capacities/all stacks/previous fields, and adds metadata-driven modular inventory views (D40; v1–v6 goldens). InventoryActions is stateless; InventoryState owns item mutations, views own transient selection/filter/confirmation. Existing journal shares the supported tab header. No new autoload. the older sketch below is historical target context. v5 adds day_ledger/day_end (DATA_SCHEMA), keeping wallet/inventory/farm/quests/profile/weather/social and legacy player.position.x/y/z. Migration creates incomplete history rather than fictitious prior transactions. Review can be saved/restored with its clock hold; advancing is never written halfway through live rollover. Restore reconciles old/new-day snapshots. Atomic writes/backups remain; latest-save selection uses fractional time and later-day tie breaking. See D39 and v1–v5 goldens.

```json
{
  "meta":      { "save_version": 1, "game_version": "0.1.0", "saved_utc": 0, "world_seed": 0, "playtime_s": 0 },
  "clock":     { "day_index": 0, "minute": 360 },
  "player":    { "cell": "0,0", "facing": 0, "tool_state": {} },
  "inventory": { "slots": [] },
  "economy":   { "coins": 0, "ledger_tail": [], "sold_pressure": {} },
  "farm":      { "plots": [] },
  "quests":    { "completed": [] },
  "buildings": [],
  "ecology":   { "metrics": {}, "triggered": [] },
  "weather":   { "world_seed": 0, "today": "sunny", "forecast": [] },
  "director":  { "enabled": false, "rng_state": 0, "history": [], "cooldowns": {} },
  "quests":    {},
  "npcs":      {},
  "flags":     {}
}
```

Migration: `save_version` + `migrate_N_to_N+1` chain. Version 2 adds saved weather and forecast; v1 saves migrate with an empty weather payload. Golden saves per version in `tests/golden_saves/`. Details: `docs/PROJECT_RULES.md` §10.

## 7. Determinism policy

All gameplay randomness = `DetRandom.make_rng(world_seed, day, TAG_*)`. Pre-rolled results are saved. Director decisions are saved with a reason trace. Golden tests pin sequences.

## 8. Network boundary (Phase 10+)

World = local-authoritative (D04). The server only serves social features that are not competitively economic: friend codes, gift inbox (idempotent, capped), friend farm snapshots (compact layout JSON), community project ledger (capped contributions), "casual" leaderboard. The client holds only the public key; the server validates every write (RLS / server functions). The game is fully playable offline and solo.

## 9. Directory map

```
TheLife/
├── project.godot
├── AGENTS.md  (GEMINI.md optional)  .gitignore  .gitattributes  .editorconfig
├── .agent/workflows/            Antigravity workflows (task-start / task-review / task-finish)
├── docs/                        this documentation set
├── data_src/                    CSV sources; scripts generate .tres
├── tools/                       headless scripts: check_parse, run_tests, validate_data, sim_economy, sim_director
├── scenes/   main/ world/ player/ farming/ buildings/ characters/ ui/ fx/
├── scripts/
│   ├── core/        events, settings, data_registry, save_service, game_clock
│   ├── util/        grid_math, det_random, log
│   ├── data/        item_data, crop_data, recipe_data, building_data, director_event_data ...
│   ├── domain/      farm/ inventory/ economy/ world/ ecology/ director/ production/ quests/
│   ├── components/  interactable, grid_actor ...
│   ├── player/      player.gd, states/
│   ├── actions/     tool_action + hoe/water/seed/harvest ...
│   ├── view/        farm_view, building_view, lighting_view, weather_fx_view ...
│   ├── ui/          hud, hotbar, inventory_ui, shop_ui, build_ui, journal_ui ...
│   └── net/         network_gateway, mock_backend (later: real backend)
├── data/            .tres: items crops recipes buildings tools weather ecology director_events npcs dialogue quests shops orders moments
├── assets/          characters environment buildings crops props icons audio vfx fonts
├── localization/    vi / en
└── tests/           unit/ domain/ view/ golden_saves/ fixtures/
```

## 10. Build order

Follow the milestone table in `docs/ROADMAP.md` (Phase 0 → 12). Gates: after Phase 4 (is the plant-harvest loop fun?) and after Phase 9 (do strangers want to keep playing?).

The approved ISO migration sequence now takes precedence for presentation work. The historical Phase table and old schematic save example above are retained for context; actual implemented saves are v4 (see API_INDEX/SaveService), not the v1 example. This migration does not mark any human playtest gate passed.

## ISO-1 implemented wiring (D36)

- Main is a CanvasLayer at layer 1. Existing Control children retain their direct Main paths and remain stationary under camera movement. GrayBoxWorld is a Node2D wrapper containing WorldCanvas (CanvasLayer 0, follow_viewport_enabled); world-only modulation, tiles, actors and camera render there. InteractionLayer remains a separate CanvasLayer at 2 and UiCoordinator suppresses it behind modals.
- WorldCanvas contains Ground, Farmland, Objects, Highlight, FarmView, WeatherFx, WorldTint and the existing interaction/spawn marker names. Objects is y-sorted; player, crop Sprite2D roots, houses and NPC actors/homes share foot-level origins. WorldArt2D also enables y-sort so nested passive tree placeholders sort with the actors.
- IsometricGrid is a VIEW RefCounted adapter around Ground TileMapLayer. Its transforms delegate entirely to Godot's map/local/canvas APIs. It is never passed into domain objects. FarmView.setup(world) runs before configure(farm_state).
- NpcSystem is now a nonvisual Node under Main. It owns the existing social state and lookup dictionaries; actors/homes render beneath world Objects. Existing WorldLocations Vector3 Resources and pure GridMath XZ conversion are retained as a legacy logical-coordinate adapter for scheduling. No domain class gained a Node or a pixel dependency.
- Actual save v4 already stores player.position.{x,y,z}, unlike the older cell/facing target sketch. Main saves the legacy center coordinate of the current logical cell and loads legacy positions through GridMath then IsometricGrid. Subcell movement is intentionally snapped to the cell center on restore. Invalid numeric fields fall back to the data-owned spawn; out-of-bounds cells are clamped. This changes no JSON field or save version; existing golden migration tests remain.
- The real clock/weather/day simulator, inventory/wallet/merchant/quests and settings APIs are reused. WorldTint consumes the existing DayNightProfile; WeatherFx consumes weather/time signals. Runtime art is code-generated TileSet/crop textures, drawn avatars/scenery and 2D action marks. Generated C0–C3 3D scenes/shaders/builders remain intact for archive review only.
- tools/run_tests.bat runs parse, data validation, a headless domain/2D regression suite, the COMPLETE GUT suite on the configured renderer, then main headless. No renderer-dependent test is skipped. The bounded helper hides windows, preserves exit codes and isolates APPDATA/user data under TEMP.
