# gray_box_world.tscn — ISO-1 implemented and historical C4 contract

## AUDIT-F1 derived crop stage (D87)

No node/scene/Inspector/physics/input edit. FarmView._render_cell passes its actual plot.regrowing to CropPresentation's new optional final argument. Crop roots still use the manifest texture/pivot and shared world grid. Normal image stages change at25/50/75%; mature metadata waits for actual100% and a non-withered plot. Repeating crops keep normal/wilted image3 during the wait and image4 at maturity; no seed-stage tree replacement after harvest. Existing roots/hidden Labels/crop picking and farm state fields are retained. Care reads the shared stateless stage rules; no view advances days or grants produce. Full-gate/human acceptance is recorded separately in PROGRESS.

## Phase7.1b weather transaction (D86; no scene edits)

Main uses the existing WeatherState instance at actual GameClock day. On a legitimate next morning, reserve captured weather before outgoing-rain/farm callbacks; keep farm->animal->machine ordering, finish the weather day once, apply morning rain, reconcile ledger and then safe autosave/bulletin. Weather busy blocks save/load/new/title/sleep commands during callbacks; duplicate/skipped/stale signals do nothing. Saved3 forecasts remain exact through load/migration, newly needed tail uses DetRandom tag1. Save12 weather day must match saved clock; missing/corrupt weather is explicitly initialized at loaded day without replaying simulation. Existing typed events/views/modal tree/input/Inspector remain unchanged. Bulletin and tomorrow card only read forecast; no view rolls weather.

Manual: record today/three forecasts, sleep once through review, confirm new today equals saved first forecast; save/load and repeat through all three predictions. Compare water/coop/items/coins and ensure no duplicated care/eggs/bookkeeping, one morning bulletin, unchanged rain presentation. Continue/load alone must neither advance a day nor open bulletin. No editor setup required; full automated evidence/current acceptance in PROGRESS.

## D83 coop delegate
Existing world adds configure_chicken_coop(query:Callable,request:Callable). E/prompt checks water then actual coop context then old anchors. Runtime SiteView is a child of objects outside passive WorldArt2D; owns only illustration/owned-only layer1 collision. Existing node paths/scenes/Player/camera remain. See chicken_coop.md.


## Phase6.5h2b runtime watering hooks (D78)

No .tscn/Player/camera/map/source/collider/marker/Inspector/stroke change. Main adds one WateringCanState and WateringRuntime application Node; existing ToolActionController.configure_watering(runtime) routes its converged manual water branch to the real can. GrayBoxWorld.configure_water_refill(query:Callable,request:Callable) delegates source authorization/command; it owns no charges. New `_water_context` accepts only actual source context from the delegate.

Selected can + unlocked actual dry bank adds honest refill/full text to existing InteractionPrompt.message_label (existing Message child) and handles existing E before bin. Normal tools keep old interactions; GUI/NPC/menu routing and movement/sleep locks remain. Shared SourceRules/WorldLocations geometry authorizes banks, not a new marker or duplicated projection. Source view art/labels/collisions stay D77. See watering.md for exact runtime/HUD APIs/tree and savev10 boundary.

No editor wiring. F5: select watering can (visible slot3), water dry crops via mouse/drag/Space/Inspector, see amount decrease once; at0 next dry crop waits. Reach well dry cell(7,9), stream(-14,6), pond(15,9), E refills; full is unchanged. Test hoe at nearby bin, menu E, pause/placement, legacy farming/land/machines/save/Continue. Actual human playtest pending.

## Phase6.5h2a expanded source world (D77)

No .tscn or Inspector/InputMap change. IsometricWorldConfig now supplies85×85 Ground,39×39 Player bounds and43×43 scenery bounds plus expanded camera/pan. WorldPresentation creates WaterSources Node2D under existing WorldCanvas (obtained from Ground parent), not the default GrayBoxWorld canvas; see water_sources.md for exact generated tree. Source floor art z=-15, optional stream/pond NameLabel z16; well art in Objects y-sort. Existing exports/markers/interactions/player/camera/anchors unchanged.

WorldLocations.get_solid_regions supplies existing static generator with deduplicated sources: reuse old well cell once, append stream/pond colliders on layer1/group obstacles. Farm stays passable for Player. NPC routing clips the same solids to its unchanged nav region; ownership/parcel validation retains current rights and excludes water. Existing Objects/WorldArt2D rebuild clears only passive scenery, whose source/approach reservation is cached. No source-refill prompt or new interaction exists yet; unlimited watering/savev9 remain.

F5: walk from farm boundary(3,6) along data routes to well(7,9), stream(-14,6), pond(15,9); each dry approach is passable and stone/water blocks movement. Try old farm/east parcel/buildings/machines, five zooms/pan/picking, vi/en and paused ripples. No manual scene setup. Automated output/manual limits are in PROGRESS.

## D72-C4 live-language label/feedback correction (D76)

No scene/tree/Inspector/InputMap/Theme/localization-file edit. Existing WorldPresentation-created House/SeedShop/ShippingBin art labels and NpcSystem.homes labels respond to the existing translation notification, using current profile name/NpcData and existing keys. The same nodes/positions/colors/colliders/appearance and paused animation phases remain. Requesting redraw updates the decorative label pill while paused; it does not reconfigure/reset art. Empty/unconfigured/teardown states are guarded. Player-authored names stay unchanged.

Existing HudRoot.toasts dismisses old formatted messages on an actual locale change. Hide immediately during tree notification, free captured old IDs afterward; show_message flushes only dismissed IDs before adding new cards. Three-second/max-two and same-locale lifetime stay unchanged. Old deferred timer IDs cannot affect replacements. Public view APIs/signals remain; no event replay/metadata/Settings/domain/save change. Earlier startup-language residue described below is the historical C1/C3 limitation corrected here for these named labels and visible toasts, not a claim about every other UI/debug string.

Manual: on one running game with visible feedback, use existing pause/settings Apply to switch vi->en->vi; player/shop/bin/NPC-home signs change without reopening game, old toast disappears, subsequent feedback uses chosen language. Same-language Apply keeps existing feedback under normal max-two policy. Inspect paused pill text/geometry and preserve current player name/location/appearance/items/coins/crops/jobs/NPC state. No editor wiring. Full measured proof/status in PROGRESS.

## Phase6.5e Main-owned placement overlay (D66)

Existing scene/tree/exports/pick_cell/cell_to_global/get_player_cell and Player/CameraRig/world sources remain unchanged. Main's new overlay uses world.pick_cell and grid.cell_to_screen, actual camera zoom and manifest pivot; it adds no world child/collision/second projection formula. New placements are restricted by Resource to the already reserved6x6 farm region and existing reach, cannot overlap Player or tilled/cropped cells. Legacy placements outside remain preserved. UiCoordinator locks Player/camera while placement is active and restores prior clock hold on close/interruption. ToolController suspends strokes and gates held confirm until release; only new hoe/seed on machine cells are blocked, retaining legacy crop care/harvest. See machine_build.md for overlay composition and F5 checks.

D62 restoration (2026-11-04): owner restored Player and its child Camera2D after withdrawing manager-only removal. WorldCanvas/Objects/Player, PlayerSpawn, typed world.player/get_player_cell and reach-based bed/shop/bin/NPC/tool behavior are restored from HEAD. Retain the new machine_shop_marker/machine_shop_interacted, placed-machine mouse selection and all supplied crop/machine presentation. Overlays/sleep lock Player; saved logical position coexists with machine save fields. CameraRig again targets Player, not a second manager camera. No crop/machine Resource or domain rollback.

ISO-8b/D45 preserves this scene, all world nodes/state/interaction APIs. WorldPresentation's existing configure_player_appearance applies the same normalized catalogue values to PlaceholderAvatar2D, now with shared six-style hair rendering matching the creation preview. NPC empty customization retains legacy arc; no game/collision/time/save changes. See character_creation.md.

## ISO-6b1 first/repeat cycle readout (D42)

No scene/node/export/input changes. FarmGridState owns growth_target/regrowing and get_growth_target(cell). FarmView asks the owner for the stage denominator, including historical first targets; CropInspector uses owner remaining days and a localized actual-repeat note. Main refreshes existing FarmView.configure after snapshot restore so all cells reflect their saved phase. Harvest retains repeating crop roots/cells and updates stages via existing plot_changed; withered and single-harvest semantics remain. Existing tool capacity/reach/lock/seed APIs apply; no second simulation path or UI-owned crop state.

## ISO-6a crop-care readout (D41)

No scene/tree/export/input changes. FarmGridState owns per-plot consecutive_dry_days and exposes get_dry_days_remaining(cell). Existing FarmView observes the withered flag; CropInspector's existing note_label reads the owner's counter and shows a localized warning after missed care. Its current Water/Harvest action_requested signal and Main's ToolActionController binding remain. Watering/harvesting a withered plant cannot mutate it. Ripe plants still need care. Main simulates the finished day's stored water/current rain once before preparing the new weather/rain. Data thresholds, domain persistence and view readouts remain separate.

## ISO-1 implemented tree (D33/D36)

ISO-4 adds local bed_requested() on the existing reachable/night bed interaction. Main's LifeDayEndFlow consumes it to open the reference-13 summary before rollover; standalone world keeps its previous try_sleep fallback. Existing player/camera/bed marker paths, reach data and sleep-started/finished handlers remain intact. No world scene node is added/moved/renamed. See day_end.md for the Main-owned summary and clock-hold contract.

Path remains `scenes/world/gray_box_world.tscn`, script `scripts/view/gray_box_world.gd`, class `GrayBoxWorld`; root is `Node2D`. Main (`scenes/main/main.tscn`, `scripts/view/main.gd`) is a `CanvasLayer` at layer 1, retaining the direct paths of existing UI Controls. WorldCanvas at layer 0 follows the viewport so Camera2D affects the world while UI remains fixed. Automated checks pass; human editor acceptance is pending.

```text
GrayBoxWorld (Node2D)
├─ WorldCanvas (CanvasLayer)                  layer 0; follow_viewport_enabled = true
│  ├─ Ground (TileMapLayer)                   %Ground; z -20; y-sort; 128×64 isometric Diamond Down; Camera2D zoom0.5
│  ├─ Farmland (TileMapLayer)                 %Farmland; z -10; y-sort; shared TileSet/origin
│  │  └─ Cell_<x>_<y> (Polygon2D, runtime)    furrows/moisture only
│  ├─ Objects (Node2D)                       %Objects; y-sort; grounded roots
│  │  ├─ Player (instance of player.tscn)     %Player; CharacterBody2D, child Camera2D
│  │  ├─ House (Node2D)                      runtime Placeholder child
│  │  │  └─ HouseLight (PointLight2D)        %HouseLight; night attachment hook
│  │  ├─ ShippingBin (Node2D)                runtime Placeholder child
│  │  ├─ SeedShop (Node2D)                   runtime Placeholder child
│  │  ├─ Obstacle_<index> (StaticBody2D)      runtime; world_static layer; obstacle group
│  │  │  └─ CollisionPolygon2D               convex footprint from existing navigation solids
│  │  ├─ Crop_<x>_<y> (Sprite2D, runtime)    stable foot-level crop picking root
│  │  ├─ minh / linh (NpcActor, runtime)     2D avatar + localized Label; domain route stays cells
│  │  ├─ Home_<npc_id> (runtime)             grounded non-colliding PlaceholderWorld2D
│  │  └─ WorldArt2D (Node2D, runtime)         nested y-sort; safe passive tree placeholders
│  ├─ Highlight (Polygon2D)                  %Highlight; z -5; view-only hovered cell
│  ├─ FarmView (Node2D)                      state-signal adapter, hidden localized crop Labels
│  ├─ FarmEffects (Node2D, runtime)           bounded transient effects after successful actions
│  ├─ WeatherFx (Node2D)                     z 10; rain and seasonal placeholder marks
│  ├─ WorldTint (CanvasModulate)              %WorldTint; world-only clock/weather tint
│  ├─ PlayerSpawn (Marker2D)                 %PlayerSpawn; data-owned logical spawn
│  ├─ BedMarker (Marker2D)                   %BedMarker; logical house interaction cell
│  ├─ ShippingBinMarker (Marker2D)           %ShippingBinMarker; logical sale cell
│  └─ SeedShopMarker (Marker2D)              %SeedShopMarker; logical shop cell
├─ CameraRig (Node)                          %CameraRig; nonvisual follow/zoom helper
└─ InteractionLayer (CanvasLayer)            layer 2; existing InteractionPrompt/Message UI
```

- Ground/Farmland share one generated four-tile atlas: grass, dry soil, wet soil and a shaded unworked-farm patch. Objects and WorldArt2D enable nested y-sort; tall visual offsets never move the foot-level sort root. The Player foot shape is defined in player.md. Obstacle_<index> bodies use the existing world_static layer and convex CollisionPolygon2D footprints; the farm navigation rectangle is deliberately excluded from player blockers.
- Use the same TileSet shape/layout for every grid layer. `map_to_local` gives cell centers in layer space; use local/global transforms when converting. Mouse targeting uses `get_global_mouse_position` followed by the layer's `to_local` and `local_to_map`; do not duplicate projection math.
- FarmGridState owns plots `(0..5, 0..5)` as logical Vector2i keys. FarmView owns only presentation; it may not infer growth, moisture, coins or quantity from tiles. CropInspector and drag tools must continue to select the correct crop/cell at camera zoom and near UI.
- IsometricWorldConfig defines spawn `(3,3)`, house/bed `(11,10)`, shipping bin `(5,10)` (flooring the legacy 5.2/10 position), shop `(-2,7)` (legacy -2/7.5), and reach 2.5 logical cells. Marker/visual anchors use the same view adapter; legacy metre coordinates are never used as pixels. NPC location Resources retain Vector3 as pure legacy logical data; scheduler/domain interfaces remain unchanged. Main's v4 wire adapter saves legacy centers of logical cells, never canvas pixels.
- Existing `shipping_bin_interacted()` / `seed_shop_interacted()` signals stay compatible. World exports typed player/camera/ground/farmland/objects/marker references and grid: IsometricGrid. `cell_to_global(cell)`, `get_player_cell()` and `pick_cell(screen_position)` bridge views. FarmView.setup(world) precedes configure(farm_state); its typed view/picking returns are in API_INDEX. NpcSystem is a nonvisual Main child; actors/homes are accessed through its lookup dictionaries after reparenting under Objects.
- All art is replaceable placeholder code or standalone sprites. Reference mockup PNGs must never be loaded as world/UI assets. Existing archived C0–C3 generated 3D scenes stay intact and outside the active gameplay tree.
- ISO-14 adds imported `assets/rocks/` and `assets/grass_clumps/` under `WorldArt2D`. Placement uses stable logical-cell hashing outside farm and interaction exclusion cells. Only large rock roots contain passive `world_static` collision; cleanup interactions remain deferred.
- WorldTint/WeatherFx observe current GameClock/WeatherState. Preserve functional rainy-day watering and NPC schedules. Detailed night/rain art is later work, not an excuse to invent domain data or remove existing functionality.
- Verify negative-cell picking, y-sort, zoom/pan, eight 2D layers, collision, modal suppression, farm loop, shop/bin/NPC interactions, sleep and v4 load round trip. No active gameplay descendant may be Node3D after ISO-1.

## Historical C4 implementation below (read-only migration reference)

ISO-3 Main HUD addition: direct Main paths (ClockHud, WeatherHud, WalletHud, QuestPanel, HotbarPanel, HudButtonBar, Toast, FeedbackPopup) remain queryable. A runtime HudRoot (Control) supplies RightColumn/ClockCard, WalletFrame/CoinLabel and ToastStack; typed LifeHudPresenter binds it to existing state. The old three Label readouts remain hidden text adapters. QuestPanel/HotbarPanel/HudButtonBar embed the modular views described in `hud.md`; their public configure/request APIs remain compatible. No world child, marker, camera, interaction layer or domain coordinate is changed.

The following describes the old C4 runtime before ISO-1. Its 3D types/transforms are historical migration references, not active node paths. D33/D36 and the implemented tree above supersede those presentation constraints.

Path: `scenes/world/gray_box_world.tscn`
Root: `GrayBoxWorld` (`Node3D`)   Script: (none at first; `scripts/view/gray_box_world.gd` may be added by a task)

Purpose: a flat test world for camera, grid picking, movement and collision. No art.

## Node tree
```
GrayBoxWorld (Node3D)
├─ WorldEnvironment                     (default environment; lighting is tuned later)
├─ Sun (DirectionalLight3D)             (shadows ON; adjust bias/distance for the ortho camera)
├─ Ground (StaticBody3D)                layer: world_static
│  ├─ GroundMesh (MeshInstance3D)       PlaneMesh 48 x 48 m (or a large BoxMesh), grey material
│  └─ GroundShape (CollisionShape3D)    matching box/plane shape
├─ Obstacles (Node3D)                   group "obstacles"
│  └─ Box_* (StaticBody3D)              layer: world_static; a few 1x1x1 and 2x2x1 boxes, a wall
├─ CameraRig (Node3D)                   %CameraRig  (scripts/view/camera_rig.gd; follows the player)
│  └─ Camera3D                          %Camera  projection = Orthogonal, yaw 45°, pitch per D13, `size` tuned so ~14–18 cells fit the screen height
├─ GridDebug (Node3D)                   %GridDebug  (draws the grid lines / hovered cell highlight; added by task 0.4)
└─ PlayerSpawn (Marker3D)               %PlayerSpawn at cell (0,0) center = (0.5, 0, 0.5)
```

## Farming gray-box placement

- `FarmPlot` is a 6 m × 6 m placeholder centered at `(3, 0.04, 3)`.
- `FarmView` owns cells `(0,0)` through `(5,5)`; their centers are `(0.5..5.5, 0, 0.5..5.5)`.
- `House` and `%BedMarker` are at `(11, 0, 10)`, outside the farm footprint, so the initial farm view is not blocked by the house.
- `ShippingBin` and `%ShippingBinMarker` are both at `(5.2, 0, 10)`. They deliberately move together so sale interaction remains correct while the bin reads as a separate destination from the player cottage.

## Runtime presentation additions (view-only)

- `WorldPresentation` is added by `Main` at runtime. It may replace the visible meshes attached to existing `House`, `SeedShop` and `ShippingBin` anchors and add non-colliding scenery children (decorative cottages, grass tufts and path stones). It does not move scene anchors or marker nodes at runtime.
- `FarmView` retains one `MeshInstance3D` crop root per logical cell. `CropPresentation` builds visual child meshes beneath that root; no new scene child path is a gameplay dependency.
- NPC homes are constructed beneath `Main/NpcSystem` from the Phase 8 location data. They are visual only and do not alter NPC schedule/navigation cells.
- `WorldEnvironment`, `Sun` and `HouseLight` remain scene-owned nodes. Runtime presentation may tune their materials/post-processing/shadow parameters, but `GrayBoxWorld` remains responsible for applying DayNightProfile and weather values.

## @export variables
| Variable | Type | Notes |
|---|---|---|
| (none yet) | | |

## Groups
`obstacles` — static blockers used for collision tests.

## Notes
- Cell (0,0) occupies world X 0..1, Z 0..1; its center is (0.5, 0, 0.5) (see `GridMath`).
- The `Player` scene is instanced as a child in this gray-box scene and assigned to the camera rig at runtime.
- The player is clamped to the playable map bounds; the camera rig follows smoothly and clamps its center so the view stays within the map.
- Lighting/shadows are placeholders. Do not tune shadow cascades until the camera angle (D13) is locked.

## C2 farming presentation additions (view-only)

- `FarmView` still owns the 6×6 logical cell roots. Each occupied cell retains one transparent `MeshInstance3D` crop root for the existing picking path; C2 instantiates a `CropVisual` child below it. The child has no collision, state or gameplay ownership.
- `CropPresentation` maps existing growth/wither values to generated C2 scenes under `assets/generated/models/farming/`. It may use a readable runtime material override under current world lighting, but the art catalogue remains the source of crop family/color intent.
- `FarmEffects` is a runtime child of `FarmView`. It owns only bounded transient meshes after a successful existing tool action and has no marker, collision, cell, save or input contract.
- Soil furrows/moisture, dew and mature bob are display details below the current crop inspector and must not move farm cells, plot bounds, camera targets or scene anchors.

## C3 chibi world presentation additions (view-only)

- `WorldPresentation` owns one runtime `C3WorldArt` child and one bounded `WorldSeasonFx` child. They load only generated C3 scenes listed by `data/art/world/chibi_world_catalog.tres`; neither node owns a collision object, marker, farm cell, input action, saved value, weather value or time value.
- `House`, `SeedShop`, `ShippingBin`, `%BedMarker`, `%SeedShopMarker` and `%ShippingBinMarker` keep their scene-authored transforms exactly. C3 may replace the visible mesh/mesh children under the three existing anchors but may not move, rename or reparent the anchors or their markers.
- `Main/NpcSystem/Home_minh` and `Home_linh` remain Phase 8 home anchors. C3 may replace their visible mesh children after the NPC system has configured them; their global positions, labels, navigation destinations and indoor visibility contract remain unchanged.
- C3 paths, water, bridge, forest/cliff border and village props are non-colliding decoration. They must remain outside the FarmView cells `(0..5, 0..5)`, the player spawn/route cells and the documented interaction-reach areas around the house, seed shop and shipping bin.
- `GrayBoxWorld` continues to apply `DayNightProfile` and `WeatherState`. `WorldSeasonFx` only observes their existing signals to select presentation: spring petals, summer day butterflies/birds and night fireflies, autumn leaves, winter snow, and rain-water ripples. Its effect count is catalogue-bounded and it never calls gameplay random, changes weather/time, or serializes state.
- C3 may use a local readable material override for instantiated C0 toon pieces because the established world-light pipeline otherwise renders those parts nearly black. Source scenes, DayNightProfile values, weather values and shared palette assets remain untouched; foliage/water shaders keep their view-only motion treatment.

## Phase6.4b generated land presentation (D69)

No existing scene/node path/Inspector edit. Main configures authoritative land before WorldPresentation. refresh_land(regions:Array[Rect2i]) rebuilds only generated children of its existing WorldArt2D root; remove children from tree immediately then queue their deletion, including large-rock StaticBody2D WorldStaticCollision layer1. Passive tree/rock/grass generation excludes owned cells and preserves source art. Identical region snapshots avoid rebuilding. Anchors, NPC homes/routes, weather, crops/machines and Player remain outside this rebuild. New Game/load refresh the appropriate geometry. linh_stream remains at(7,4); no new navigation wall or movement bound.

## D72-C1 camera/presentation handoff completion (D73)

No old scene/node/Inspector edit. Existing CameraRig/player Camera2D handles the inherited five zoom levels and RMB/MMB pan, now clamped by camera_pan_min/max Resource data. Native Shift/GUI-hover wheel yields to qualified hotbar/control input. Existing cell_to_screen/map picking/projection remain; native pan/zoom tests assert logical cells round-trip. Modal/sleep/placement retain authority. Machine work rows read actual state refs and switch to idle when ready; no job/day/save mutation. See isometric_visuals.md.
