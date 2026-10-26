# ARCHITECTURE — THE LIFE

Source of truth for how the pieces fit. Agents update the relevant table whenever they add a signal, autoload, domain class or save field.

## 1. Layers and dependency direction

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
