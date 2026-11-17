# Phase6.5h2a water-source world contract

## D78 runtime refill integration on the unchanged D77 sites

Phase6.5h2b now authorizes refill at the existing sites; this supersedes only the historical "no runtime refill/savev9" boundary below. Geometry, source IDs/paths/labels/collisions/WaterSourceView and WorldPresentation remain unchanged.

New pure WaterRefillService shares source/WorldLocations data and existing can, rejects playable-bound/static/water interiors, and recognizes only dry shores via SourceRules. Main's WateringRuntime reads actual Player/selected tool and existing gameplay locks. With watering can selected, dry bank + E refills current capacity; already full is unchanged and shows full feedback. Ordinary tool selection retains old nearby interactions, including bin by well. No caller-supplied source, cost, timer, new input action/marker/global signal or geometry copy.

GrayBoxWorld delegates query/request via configure_water_refill; existing InteractionPrompt/Message displays localized refill/full state. New watering contract documents the can owner/local signal/HUD/lifecycle/savev10. F5 dry cells remain well(7,9), stream(-14,6), pond(15,9). GUI/modal/locked/sleep/interior/far must not refill. Native tests cover three real E paths; human F5 remains separate.

Owner approved the map/source foundation, not can consumption/refill/HUD/save-v10 integration. No `.tscn`, InputMap, Main or Player script changes. Watering and save-v9 remain as before.

DATA: `data/water_sources.tres` contains `home_well`, `forest_stream`, `east_pond`, their rectangular blocked cells, label cells and orthogonal dry access waypoints. It references IsometricWorldConfig. WorldLocations optionally references the same source config; `get_solid_regions()` deduplicates original solids and source rectangles. World collision, clipped NPC AStar routing and land exclusion checks use this combined data. The well reuses the existing `(8,9)` solid.

Generated nodes (owned by WorldPresentation; no gameplay state):

```text
GrayBoxWorld/WorldCanvas
├─ WaterSources (Node2D, runtime, z=-15)
│  ├─ home_well (WaterSourceView, floor_only=true; approach/bank only)
│  ├─ forest_stream (WaterSourceView, floor_only=true; bank/water/approach)
│  │  └─ NameLabel (Label, local z=16; ignores pointer)
│  └─ east_pond (WaterSourceView, floor_only=true; bank/water/approach)
│     └─ NameLabel (Label, local z=16; ignores pointer)
└─ Objects (existing y-sorted Node2D)
   ├─ WaterSource_home_well (WaterSourceView, floor_only=false; well art)
   │  └─ NameLabel (Label; ignores pointer)
   └─ Obstacle_<index> (existing generator; original indexes retained)
```

Floor sources anchor at the data label cell; polygon vertices use the actual Ground TileMapLayer local/global transform and shared diamond helper, not a copied projection formula. Well's sort origin is its data ground cell. Floor z sits above Ground(-20), below Farmland(-10); stream/pond labels can rise above their floor. Existing world-static layer1/group `obstacles` remain; source views add no duplicate collision or physics layer.

`WaterSourceView.configure(data:WaterSourceData, grid:IsometricGrid, config:WaterSourceConfig, floor_only:bool=true)->void` creates its optional NameLabel, uses the shared world-label Theme and current translation key, and updates it on translation notification. `source`, `label` and transient `_phase` describe presentation only. Only water-floor views animate; GameClock.paused freezes phase. No saved fields, signals, interaction prompt or refill command.

WorldPresentation caches source/corridor clearance once. Generated trees/rocks/grass stay in scenery_region and avoid source/walkway clearance and owned farmland. Existing anchors, NPC data targets and crop/machine roots remain. Labels/cosmetics do not mutate source Resources or any owner. Runtime land refresh rebuilds only generated passive scenery, leaving source nodes and physics stable.

Map/player/scenery regions become85x85/39x39/43x43; camera center/pan values remain Resource-owned. Ground is deliberately larger than roaming/decor, keeping background cost separate from node count. A larger map grants no new owned farmland. Finite terrain can still end at extreme overview/pan.

Manual setup: none. F5 after code reload: walk to the well via `(7,9)`, stream via `(-14,6)`, pond via `(15,9)`; water/stone cells block movement while dry routes stay open. Inspect names in vi/en, paused water, zoom/pan/tile selection, unchanged old farming/land/machines/save. No refill prompt is advertised in this foundation; can/HUD/refill/save integration follows under its own scope.
