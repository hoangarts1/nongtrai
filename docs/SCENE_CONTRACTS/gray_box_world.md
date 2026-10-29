# gray_box_world.tscn  (DRAFT — used from roadmap task 0.4)

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
