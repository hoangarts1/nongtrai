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

## Phase8.5f implemented boundary

﻿Step6/10 after8.5e pushed6c0fb32/full922. Main retains stable DogState and one LifeDogRuntime/DogActor2D under actual world.objects. DogNavigationContext snapshots actual owned land regions, MachinePlacementState.MACHINE_SIZE footprints and owned coop Resource footprint (placement occupancy is currently one cell irrespective of art). Static world water/buildings/farm use original Resource. Polls sparse sources at configured0.25s and immediately before adjacent arrival; navigation rebuild only on canonical change. DogMotionFlow quotes before pixels, rechecks on arrival then resets display from sole owner; stale/blocked arrivals cannot commit. Only newly covered origin uses bounded repair; one actor/two child display nodes reused. Lifecycle reconfigures existing visual references after silent owner reset, keeps name/cell display coherent.

Paused clock, all UiCoordinator modals including DebugMenu, sleeping/day-end and title stop advance; title hides and cancels route. New/load reset derived routes; actual owner publication prevents save/load/new/title reentry. No new collision/input/Player/camera/NPC/scene/save14 fields or economic mutation. Live dog not persisted until approvedg. Native walking/sprint feel and final art remain human F5 acceptance.

Import1 clean except inherited duplicate assetUID warnings. Focused1 3scripts/7/7/54assert/2.663s PASS; native1 same7/7/54assert/2.740s PASS, no errors/leaks. Real Main follow to far negative grid cells, hysteresis stop, pause/modal/title, stable cache, owned water/buildings/coop, actual machine place/move/remove and land grant, covered-origin/name preservation, stable owner/actor across lifecycle and publication reentry all verified. Existing tests and20real saves protected; full follows.

Manual: approved original contract above; no old scene/Inspector/InputMap edits. New code composes only approved modules. Automated evidence in PROGRESS does not replace human F5/art/tone review.

## Phase8.5g implemented boundary

﻿Step7/10 after8.5f pushed8fc035c/full929. SaveService.CURRENT_VERSION15 adds only dog{name,cell_x,cell_y}; 14-to15 baseline and all earlier migrations preserve prior systems and do not simulate days. Independent DogSaveCodec canonicalizes nativeJSON integers/name, preserves a valid Unicode name on bad/missing position and supplies bounded safe Resource baseline. DogLifecycle prepares against current actual nav before silent replacement of the same DogState; runtime refreshes sparse obstacles and reuses actor/children after load. Good current cells preserved; blocked positions repair locally with good name retained. No saved route/timer/nav cache/Nodes; dirty-save observes actual dog commands. Root busy guard remains across publication. Director intent/default-off, weather three forecasts, ecology/coop/can/land/jobs/progress unchanged.

Import1 clean except inherited assetUID warnings. Focused1 2scripts/4/4/94assert/1.404s PASS; native1 1script/2/2/71assert/1.384s PASS. All fourteen historical golden inputs tested, prior files untouched. Actual SaveService._migrate produced new golden15 from tracked golden14 (never a human save). Independent32-dependency no-autoload project:1000nativeJSON/Unicode/safe-cell/restore steps PASS. Current save/load/Continue/new/title and bad dog-only fallback retain other real owners. Exact approved38row/33oldtest compatibility verified byte-for-byte; remaining455prior tests/fixtures and20real saves SHA unchanged. Full follows; no assertion removal/fixture/golden1..14 changes or timeout extension.

Manual: approved original contract above; no old scene/Inspector/InputMap edits. New code composes only approved modules. Automated evidence in PROGRESS does not replace human F5/art/tone review.

## Phase8.5h implemented boundary

﻿Step8/10 after8.5g pushed4e5c471/full933. Companion card below Character identity uses detached DogSnapshot and localized DogPresenter. New NameSheet/Form/Card scenes compose only shared Theme/native controls; Character retains public identity/skills/relationships/tabs aliases and left profile can scroll. NameFlow captures expected owner revision, native LineEdit has max_length0 (no silent24-character truncation), command goes through DogState validation and guarded publication. Successful save and explicit Cancel/Back return to Character; Esc/coordinator/lifecycle close only hide and never reopen. Owner remains authoritative, default world caption follows locale and named caption remains actual name. UiCoordinator alone owns holds/focus/input, native text/Tab/Enter preserved without world shortcuts; new/load/title close naming. No new actions/autoload/old scene/Player/save15 wire or other domain changes.

Import1 clean except inherited assetUID warnings. Focused1 3scripts/4/4/46assert/2.284s PASS. Native1 adds original Character layout/screen regressions:5scripts/12/12/1099assert/13.780s PASS; warnings only expected missing legacy crop/coop fallbacks. Native mouse open, Unicode key events M+U00E2+y, Enter/Tab/Esc, cancel/invalid/25char/control/stale quote/lifecycle close all pass. vi/en x1152/1280/1920 long24codepoint names produced12fresh name/card captures, vi1152 card and modal visually inspected. Forty read-only open/cancel/render refreshes preserve owners and save bytes; locale default caption verified. All old tests/goldens and20real saves protected. Human OS IME composition/art/tone/F5 remain pending, not inferred from synthetic native key events. Full follows.

Manual: approved original contract above; no old scene/Inspector/InputMap edits. New code composes only approved modules. Automated evidence in PROGRESS does not replace human F5/art/tone review.
