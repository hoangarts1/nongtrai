# DATA SCHEMA — THE LIFE

Every gameplay value lives here (as a schema) and in `data/` or `data_src/` (as content). Scripts contain no gameplay numbers.
Class sketches below are shapes; the agent checks syntax against the pinned Godot version (e.g. exporting typed `Array`/`Dictionary` varies by version). Where an `Array[Dictionary]` is awkward in the Inspector, use a small child Resource (e.g. `RecipeIO {item, qty}`).

## 1. Rules

- Ids: `StringName`, `snake_case`, unique per type, never renamed (use the `deprecated_ids` map + a save migration if unavoidable).
- Asset file name == data id (section 3). Do not invent paths.
- Display text via translation keys (`name_key`, `desc_key`), never raw strings.
- Big tables (prices, recipes, order templates) are CSV in `data_src/`; a script generates `.tres`, or `DataRegistry` loads CSV directly. Things that reference an icon/scene use `.tres`.
- `DataValidator` (headless, `tools/validate_data.gd`) fails the build on: duplicate id, missing reference, missing icon, missing translation key (vi or en), value out of range, profit over stage cap (section 4).

## 2. Design order (build them in this order)

1. `ItemData`  2. `CropData`  3. `ToolData` (+ `ToolAction`)  4. `RecipeData`  5. `BuildingData`  6. `WeatherStateData` + `SeasonData`  7. `EcologyMetricData`  8. `DirectorEventData` (+ `Condition`/`Effect`)  9. `NPCData`, `DialogueData`, `QuestData`  10. `ShopData`, `OrderTemplateData`  11. `MomentData`

## 3. Schemas

```gdscript
# ItemData
class_name ItemData
extends Resource
@export var id: StringName
@export var name_key: String              # e.g. "ITEM_WHEAT_NAME"
@export var desc_key: String
@export var category: StringName          # crop | product | seed | tool | decor | quest
@export var stack_max: int = 99
@export var base_value: int = 0           # coins, int
@export var icon: Texture2D
@export var tags: PackedStringArray

# CropData
class_name CropData
extends Resource
@export var id: StringName
@export var seed_item: StringName
@export var product_item: StringName
@export_range(1, 999) var yield_qty: int = 1  # current shipped starter crops use 2
@export var growth_days: int = 3          # watered/rained days needed to mature
@export var regrow_days: int = 0          # 0 = harvest once
@export var seasons: Array[StringName]    # &"spring", &"summer", &"autumn", &"winter"
@export var water_need: int = 1
@export var stage_scene_ids: Array[StringName]   # models per growth stage
@export var quality_rule_id: StringName   # used from Phase 11

# RecipeData
class_name RecipeData
extends Resource
@export var id: StringName
@export var machine_id: StringName
@export var inputs: Array[Dictionary]     # [{"item": &"wheat", "qty": 2}]
@export var outputs: Array[Dictionary]
@export var duration_minutes: int = 60    # GAME minutes
@export var unlock_flag: StringName

# BuildingData
class_name BuildingData
extends Resource
@export var id: StringName
@export var scene_id: StringName
@export var footprint: Vector2i = Vector2i(1, 1)
@export var cost: int = 0
@export var slots: int = 0
@export var allowed_terrain: Array[StringName]
@export var unlock_flag: StringName

# DirectorEventData
class_name DirectorEventData
extends Resource
@export var id: StringName
@export var tags: Array[StringName]
@export var conditions: Array[Resource]   # DirectorCondition child resources
@export var effects: Array[Resource]      # DirectorEffect child resources (timed, reversible)
@export var weight: float = 1.0           # float is fine: it is a weight, not money/quantity
@export var cooldown_days: int = 7
@export var max_per_season: int = 2
@export var is_negative: bool = false
@export var telegraph_days: int = 2       # days of forewarning (0 for a pleasant surprise)
@export var counter_hint_key: String      # how the player can respond
@export var explanation_key: String       # why it happened
```

Outlines for the remaining types (agents write the full class in the matching milestone):

| Type | Key fields |
|---|---|
| `ToolData` | id, name_key, icon, `tool_action: ToolAction`, tier, reach_cells, params |
| `WeatherStateData` | id, season probabilities, effects (water/day, walkability, audio), `forecastable: bool` |
| `SeasonData` | id, days_in_season (28), crops/decor/activities |
| `EcologyMetricData` | id, sources + weights (counts in the world), decay/ease speed (%/day), thresholds → unlock ids |
| `NPCData` | id, name_key, job, schedule [(from,to,place,activity)], dialogue ids, quest ids, preferred items |
| `DialogueData` | nodes: text_key, choices, conditions (flags/quest/season/ecology), actions (start_quest, reward, set_flag) |
| `QuestData` | id, objectives measured by Events, rewards, unlocks, prerequisites |
| `ShopData` | id, stock [(item, price, unlock_flag)], always-available basic seeds |
| `OrderTemplateData` | requester, requirement ranges (item, qty_min–max), deadline days, reward factor range, cap, optional non-coin reward table |
| `MomentData` | id, condition (ecology/quest/weather/hour), effect (VFX id, music, camera, dialogue), once/cooldown, seen flag |

## 4. Starter numbers (a starting point — real values come from `tools/sim_economy.gd` and playtests)

Assumptions: 1 game day = 12 real minutes; 28 days/season; start with 200 coins, watering can 20 cells, inventory 24 slots, 8 tillable plots.

### Crops

Current shipped crop resources set `yield_qty = 2`: one consumed seed yields two product items when a mature plant is harvested. This player-requested output increase intentionally changes current balance; no price was changed in this interaction task, so a later data-only balance pass must revise the example profit targets below.

| id | seasons | growth_days | regrow | seed price | yield | product base_value | profit / plot-day |
|---|---|---|---|---|---|---|---|
| `wheat` | spring, summer, autumn | 2 | — | 8 | 1 | 20 | (20-8)/2 = 6.0 |
| `carrot` | spring, autumn | 3 | — | 15 | 1 | 45 | (45-15)/3 = 10.0 |
| `corn` | spring, summer | 4 | — | 30 | 1 | 90 | (90-30)/4 = 15.0 |
| `tomato` | summer, autumn | 5 | every 2 days | 40 | 1 per pick | 55 | 11-day cycle: 4 picks × 55 = 220 − 40 = 180 → 16.4 |

(Profit per plot-day ignores the player's watering/travel effort, so caps are safety nets, not real income.)

### Products and recipes

| id | base_value |
|---|---|
| `flour` | 55 |
| `bread` | 150 |
| `egg` | 30 |

| recipe | machine | inputs | output | duration (game min) | value added / game hour |
|---|---|---|---|---|---|
| `recipe_flour` | mill | 2 wheat (40) | 1 flour (55) | 90 | (55−40)/1.5 = 10.0 |
| `recipe_bread` | bakery oven | 2 flour (110) | 1 bread (150) | 180 | (150−110)/3 = 13.3 |

Chicken coop: 4 hens, feed 1 wheat/hen/day → 1 egg/hen/day. Hens not fed produce nothing and never die.

### Stage caps used by `DataValidator` (profit per plot-day for crops / value added per game hour for recipes)

| Stage | Crops ≤ | Recipes ≤ |
|---|---|---|
| GĐ1 new player | 18 | 15 |
| GĐ2 farm owner | 30 | 40 |
| GĐ3 businessperson | 60 | 120 |

### Progression & sinks (starter targets)

| Stage | Days | Income / game day (target) | Spend goals |
|---|---|---|---|
| GĐ1 | 1–7 | 40–150 | inventory +12 slots (300), land expansion #1 (500) |
| GĐ2 | 8–30 | 150–500 | mill (600), bakery oven (900), coop (700), expansion #2 (1,100) |
| GĐ3 | 31–80 | 500–1,500 | expansions #3–#4, greenhouse (6,000), bridge project (8,000) |
| GĐ4 | 80–200 | 1,500–4,000 | plaza (25,000), festivals, landmark buildings |
| GĐ5 | 200+ | open | decoration, cosmetics, collections, large projects |

Land expansion cost: `round_to_50(500 × 2.2^(n−1))` → 500, 1,100, 2,400, 5,300, 11,700…
Watering can 20 → 40 → 80 cells: 200, 600, 1,800. Inventory 24 → 36 → 48 → 60 slots.

### Saturation pricing (anti "one best crop")

Each item has `sold_pressure` (int). Selling 1 → `pressure += 1`. Each day: `pressure = max(0, pressure − 3)`. Price factor = `max(0.6, 1 − 0.02 × max(0, pressure − 5))`. Sell price = `floor(base_value × factor)`. Parameters are data. Show a price-trend arrow to the player so it never feels like a hidden penalty.

### Weather probabilities per day (MVP)

| Season | sunny | light rain |
|---|---|---|
| spring | 70% | 30% |
| summer | 75% | 25% |
| autumn | 70% | 30% |

(Fog, heavy rain, heatwave, snow come later; each weather has a `forecastable` flag.)

### Ecology thresholds (examples)

`biodiversity ≥ 25` → butterflies/bees · `tree_cover ≥ 30` → birds · `water_clarity ≥ 50` → clear water + new fish · two metrics ≥ 60 → fireflies · all three ≥ 80 → WOW moment "valley reborn". Each metric = smoothed function of world counts (living mature trees vs target, cleared stream cells vs total, flower cells / species count); the current value eases toward the target by 5–10% per day.

### NPC schedule examples

An: bakery 07:00–18:00, home 18:00–21:00 · Lâm: workshop 08:00–17:00, tavern evening · Linh: forest 10:00–17:00, stream in the morning · Minh: market 17:00–22:00 on days 3 and 6 of every 7-day week.

### Orders (`OrderTemplateData`)

Formula, not "AI": reward = `round(total base_value × seeded factor in [1.15, 1.5])`, hard cap `2.0 × total base_value`. 3–5 orders/day, expire without penalty. Seed = `mix(world_seed, day, TAG_ORDERS)`.

## 5. Asset naming (filename == data id)

| Kind | Pattern | Example |
|---|---|---|
| Character model | `chr_<name>.glb` | `chr_player_base.glb` |
| Environment | `env_<name>_<nn>.glb` | `env_tree_oak_01.glb` |
| Building | `bld_<name>_lv<n>.glb` | `bld_bakery_lv1.glb` |
| Prop | `prop_<name>_<variant>.glb` | `prop_fence_wood_a.glb` |
| Crop stages | `crp_<crop_id>_s<n>.glb` | `crp_wheat_s0.glb … s3` |
| VFX scene | `fx_<name>.tscn` | `fx_rain_drop.tscn` |
| Material | `mat_<name>.tres` | `mat_grass_a.tres` |
| Icon | `icon_item_<item_id>.png` | `icon_item_wheat.png` |
| SFX | `sfx_<name>_<nn>.ogg` | `sfx_hoe_hit_01.ogg` |
| Ambience | `amb_<place>_<time>.ogg` | `amb_forest_day.ogg` |
| Music | `mus_<name>.ogg` | `mus_farm_morning.ogg` |

Import hints (node/animation name suffixes in Blender; verify the list in the docs of the pinned version): `-col`, `-convcol`, `-colonly`, `-noimp`, `-loop`.

## C2 visual metadata (implemented)

`ItemData` now optionally carries `model_path: String` and `icon_path: String` for generated presentation. They are not inventory data: saves continue to serialize only item IDs/quantities and all economy/crop data continues to resolve through the existing stable IDs. C2 uses `assets/generated/models/farming/item_<item_id>.tscn` and `assets/generated/icons/item_<item_id>.png` rather than the aspirational GLB/icon naming examples above.

`FarmingArtCatalog` is a visual-only Resource at `data/art/farming/chibi_farming_catalog.tres`. It maps existing crop IDs to silhouette families and data-owned stage scales/colors; it contains no crop balance, timing, yield, save or world-state fields.

## C3 visual metadata (implemented)

`WorldArtCatalog` is a visual-only Resource at `data/art/world/chibi_world_catalog.tres`. It owns stable generated world asset IDs, asset categories, palette roles, non-interactive exterior placement vectors and a maximum count for ambient visual effects. It has no farm grid, crop/economy/quest/NPC schedule/navigation data, collision layer, input action, time/weather authority or saved-state field. Existing `GameClock` season/time and `WeatherState` rain are observed by `WorldSeasonFx` only for display selection.

Generated source scenes retain C0 palette/shader intent. In the current `DayNightProfile` world renderer, C3 may create a local readable material override for a toon piece; this is not catalog data, does not modify a shared source asset, and never adds a save field or a gameplay color rule.
