# Dog companion — approved Phase8.5a–j contract

## Current boundary: Phase8.5a DATA only

Approved one cosmetic dog, existing Player retained. Only DogConfig/data/validator are
live at this step. No dog actor, owner, UI, save field or input binding yet. References
are actual isometric_world_config.tres and npcs/phase8_world.tres. Config exports
world/npc_world, name_max_length24, follow_start_distance3/stop1, move_speed3cells/s,
context_interval0.25s, idle_wait_seconds3, idle_radius2, reaction_seconds0.8.
validation_errors() returns explicit errors; frozen_copy() detaches the full Resource
DATA graph, including external Resources, preserving internal shared references.
Source Script references are immutable and shared; no runtime Nodes are copied.

## Approved composition reserved for later steps (not implemented by this contract)

- DOMAIN DogState owns only name/cell, exact3field wire{name,cell_x,cell_y}; configure,
  serialize/deserialize, guarded typed changes. Empty saved name means locale default;
  rename accepts1–24printable Unicode codepoints after trim, no controls/newline.
  DogNameRules and DogSnapshotCodec are independent pure helpers (8.5b).
- DogNavigation owns a derived AStarGrid2D/context; serialize/deserialize context but
  do not place this cache into game saves. Region comes from world.player_region,
  obstacles from actual WorldLocations plus supplied current footprints (8.5c).
- DogFollowRules chooses deterministic reachable goals; DogMovementService verifies
  adjacent steps/expected cell/navigation revision before changing sole owner (8.5d).
- DogVisualProfile defines provisional cream/brown polygons/shared-palette colors.
  DogAvatar2D draws; DogActor2D interpolates shared IsometricGrid coordinates with
  ground origin. No Node3D, collision/body/input region or gameplay mutation (8.5e).
- Main.dog_state:DogState and dog_runtime:LifeDogRuntime (8.5f) retain one actor under
  world.objects:Node2D, current world/grid/y-sort/tint. DogNavigationContext builds
  actual bounds/static+machine+coop obstacles; DogMotionFlow validates route arrivals.
  No direct hand-written isometric conversion. Existing APIs: Player.get_cell(),
  main.world.grid.cell_to_global(), machine_placements.get_all_placements(), actual
  coop footprint/ownership and WorldLocations.get_solid_regions(). Source polling
  is bounded; grid only rebuilds when context changes, never every render frame.
- Modal/pause/sleep/day-end/title freeze motion. Closed route waits/reroutes; opening
  a route resumes. A newly covered invalid origin may be repaired to nearest valid
  cell; never snap to Player to cross a wall. Spawn/load resolve a valid cell from
  actual Resource/player context; no new world anchor. The dog never blocks tools,
  construction, NPCs or camera. No money/items/stamina/affection/food/death system.
- Save15 (8.5g) adds only dog. DogSaveCodec/DogLifecycle validate matching snapshots,
  prepare before replacing owner, retain good names while repairing bad locations.
  All14older goldens stay unchanged. No saved route/timer/actor/nav cache or replay.
- LifeDogNameFlow/NameSheet/NameForm/CompanionCard and snapshot/presenter (8.5h) use
  shared Theme and existing Character entry; small companion card below left profile,
  native LineEdit/Save/Cancel. UiCoordinator owns pause/modal/focus/Esc; cancellation
  does not rename, stale quotes/reentry blocked. No new action/hotkey or story beat.
- DogReactionFlow (8.5i) reacts cosmetically to existing rain/successful harvest,
  bounded tail animation/idle routes, frozen during holds and cleared on restore.
  No new sound/reward/production/activity counter or random gameplay stream.

## Verification/manual handoff

Each step records actual tests in PROGRESS; this contract alone is not completion.
Existing scenes/Player/InputMap/assets/old tests stay outside scope except the exact
approved save15 version patch at8.5g. No editor setup for DATA. Later runtime creates
only the new approved scenes/components in code. Human F5/art/tone review is separate.
After8.5h: open Bag→Character, compare dog name, edit with Vietnamese input, cancel,
save/load/Continue, resize/locale/Back/Esc; compare all existing progress. After8.5i:
walk/sprint across the39×39playable map, watch water/buildings/farm/machines/coop,
pause/title/overnight, reroute after placement, rain/harvest reaction and one actor.
The1000step/native final proof belongs to8.5j; ChapterI/M2.4 remain separate.

## Phase8.5b implemented owner only (D130)

DogState and name/snapshot rules above are now implemented; exact APIs in API_INDEX. No actor/UI/Main owner yet. try_set_cell bounds-checks identity storage; caller must use approved future DogMovementService for route/adjacency. Commands return explicit ok/reason/revision/changed; stale revisions and publication reentry blocked. No editor setup. Native decoder NUL normalization and current full evidence recorded in PROGRESS.

## Phase8.5c implemented derived navigation only (D131)

DogNavigation/Codec APIs above now implemented. Native routes include origin and only orthogonal walkable neighbors. Configuration captures existing Resource geometry once; dirty dynamic DTO changes use set_dynamic_obstacles, equivalent context does not rebuild. Player region39x39, no NPC/map/physics edits. No live dog, scene or Inspector work yet; route-to-owner bridge belongs to8.5d/f. Cache serialization stays outside game saves.

## Phase8.5d implemented follow/command boundary (D132)

Follow rules/movement service above now implemented, no actor or Main composition yet. A future motion flow must quote adjacent target, interpolate read-only visuals, then call step(quote); stale/blocked arrival cancels and resyncs owner. Invalid origin repair is explicit and cannot move a currently valid dog. Mode/route are transient, no saved timer/progress/reward. No scene/Inspector steps in this slice.

## Phase8.5e implemented boundary

﻿Step5/10 after8.5d pushedc0cfe8f/full918. DogVisualProfile supplies shared ArtPalette cream/brown/outline/ground shadow, finite polygon geometry and cosmetic timing. Avatar owns only phase/facing; actor reads sole DogState, interpolates real IsometricGrid ground points and emits arrived without mutating domain. Exactly avatar+non-interactive name Label, no physics/input/3D. Actor is not spawned by Main until approvedf. configure/reset_position/begin_step/advance and set_unnamed_caption are the composition API; unnamed caption empty until localized UI integrationh. External Resource palette and shape arrays detached by frozen_copy.

Import1 clean except inherited duplicate artUID warnings. Focused1 2scripts/4/4/86assert/1.766s PASS, native1 1script/2/2/86assert/2.954s PASS. Native actual Main grid vi/en x1152/1280/1920 x5zooms rendered, six fresh PNGs archived; manually inspected vi1152 silhouette/ground/name/shadow. Ground invariant, pause pose/position freeze, no owner mutation, finite validator negative cases pass. No scene/InputMap/Player/assets/economy/day/RNG/save14 changes. Main spawn followsf; provisional art still needs human acceptance.

Manual: approved original contract above; no old scene/Inspector/InputMap edits. New code composes only approved modules. Automated evidence in PROGRESS does not replace human F5/art/tone review.
