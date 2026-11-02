# gray_box_world.tscn — ISO-1 implemented and historical C4 contract

## ISO-1 implemented tree (D33/D36)

Path remains `scenes/world/gray_box_world.tscn`, script `scripts/view/gray_box_world.gd`, class `GrayBoxWorld`; root is `Node2D`. Main (`scenes/main/main.tscn`, `scripts/view/main.gd`) is a `CanvasLayer` at layer 1, retaining the direct paths of existing UI Controls. WorldCanvas at layer 0 follows the viewport so Camera2D affects the world while UI remains fixed. Automated checks pass; human editor acceptance is pending.

```text
GrayBoxWorld (Node2D)
├─ WorldCanvas (CanvasLayer)                  layer 0; follow_viewport_enabled = true
│  ├─ Ground (TileMapLayer)                   %Ground; z -20; y-sort; 64×32 isometric Diamond Down
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
- WorldTint/WeatherFx observe current GameClock/WeatherState. Preserve functional rainy-day watering and NPC schedules. Detailed night/rain art is later work, not an excuse to invent domain data or remove existing functionality.
- Verify negative-cell picking, y-sort, zoom/pan, eight 2D layers, collision, modal suppression, farm loop, shop/bin/NPC interactions, sleep and v4 load round trip. No active gameplay descendant may be Node3D after ISO-1.

## Historical C4 implementation below (read-only migration reference)

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
