# Ecology runtime and presentation contract

## Phase7.4c final verification and manual handoff (D117)

No new scene/node/Inspector/InputMap configuration. Tool only runs isolated: pinned Godot --headless --path . --script tools/sim_ecology.gd -- --days=1000 --chunk=17 (exit0 PASS; invalid/mismatch1). Never attach/run its static scenarios beside a live Main because it temporarily uses actual GameClock. It writes no save files and restores previous serialized clock/pause. Native GUT final suite exercises actual sleep/review/forced-review restore/autosave/morning/J-Ecology/Back/Esc/load/Continue and bounded effects, two languages/three sizes with18fresh captures/read-only owner+save proofs.

Manual F5: new/load, care owned mature fruit/variety, sleep-confirm, compare saved day/current estimates and targets/counts in morning/J, Back/Esc and native scroll; observe threshold rise/fall and low-level load with historical triggered; pan/zoom, expansion, pause/night/rain, title/reset/Continue. No extra scene work. Measured water/cleanup/clear-water visuals remain unavailable, silhouettes provisional; human tone/art/editor acceptance is pending. Existing turnip/pea placeholder warnings are retained, not fixed by this scope. Full raw evidence/diffs/files/manuals/commit/push ledger in PROGRESS and external batch DELIVERY.

## Phase7.4b live native2D feedback (D116)

No .tscn/Inspector/InputMap edit. Main dynamically adds LifeEcologyEffectsFlow; it adds up to14 childless LifeEcologyCritter2D roots directly under existing world.objects. Metadata cell/effect_id; position=objects.to_local(world.grid.cell_to_global(cell)). Same y-sort/tint/camera, no layer/group/collision/input/3D. Bounded stable effect:index keys reuse identities; downward/ineligible/title/exit removes roots synchronously. Flow snapshots dirty actual owner/farm, checks silent state/ownership at Resource interval; no garden scan per frame. Main successful load/NewGame/title calls refresh. Pause/sleep/day-end hold freeze animation; actual night/rain dims by profile, historical history never keeps old critters active.

Manual F5: compare healthy tree/diversity thresholds, J/morning readouts versus current effects, sleep and downward change; save/load below thresholds with past history, NewGame/title, farm expansion, RMB/MMB pan/zoom, pause and night/rain, both locales. No extra wiring. Native captures and node/read-only tests are automation; these silhouettes are provisional art, water feedback and human acceptance remain deferred.

## Phase7.4a feedback definitions only (D115)

No scene/tree/Inspector change. data/ecology_feedback_profile.tres owns provisional2D polygons and bounded8butterfly/6bird definitions plus cosmetic animation/refresh/lighting. EcologyFeedbackSelector uses current actual metrics/availability and profile threshold equality, never history; water effects unsupported. No world nodes until7.4b. Existing3D env_bird/env_butterfly remain historical, not dependencies. Manual profile edits require validator; final art/human F5 separate.

## Phase7.3i morning consumer (D114)

Existing morning sheet adds one separate LifeMorningEcologyStrip from ui/morning/ecology_strip.tscn/.gd. MorningSnapshot carries actual ecology snapshot after committed rollover; presenter displays current estimates, current garden counts/goals, target/ease/action tooltips and water unmeasured. Invalid/busy/stale view has waiting/empty counts. No fake yesterday delta/event/history, no render-time simulation/save. Existing morning queue/modal/dismissal/reset rules remain; exact fields in morning_bulletin.md.

## Phase7.3h journal controls (D113)

Existing Main/NpcJournal modal and3common tabs/4quest filters remain. LifeQuestBook exposes navigation:HBoxContainer (Ecology entry button followed by existing tabs so Close stays far right), paper:VBoxContainer, body:HBoxContainer, ecology_button:Button and nullable ecology_sheet:LifeEcologySheet. Original tabs/filters/list/people/detail/hint fields remain. No new input action or external path. Quest mode has no ProgressBar descendants: sheet is instantiated lazily on explicit entry and detached/queue_freed on Back/reset/close, preserving old no-fake-XP contract.

New simple scene pairs under ui/ecology:
- ecology_sheet / LifeEcologySheet, VBoxContainer: title/scope/waiting Labels, scroll:ScrollContainer, rows_column:VBoxContainer, metric_rows:Array[LifeEcologyMetricRow], back_button:Button; back_requested(); display(model:Dictionary).
- metric_row / LifeEcologyMetricRow, VBoxContainer: title/value Label, bar:LifeProgressBar, summary:LifeEcologySourceSummary; display(row:Dictionary). Native Range step0 permits actual float display; min/max/value come from validated model, water bar hidden with no numeric reads.
- source_summary / LifeEcologySourceSummary, VBoxContainer: labels:Dictionary of target/source/ease/threshold/status/hint Labels; display(row:Dictionary) clears/hides absent values.

LifeEcologyController (Node child of existing book_controller) configure(panel:NpcPanel,main:Node), open(), close(), reset(), queue_render(), is_open()->bool. Owns only transient view mode/queue; no save/domain state. Open requires actual visible active journal/started idle game. Entry/Back are native Buttons; Esc and Q/E use existing journal/modal routes. Uses existing theme/fonts, no per-node StyleBox overrides. Deferred state/farm/wallet/locale refresh captures7.3g actual data; hidden/reset/free drops stale work. Existing book_controller.reset and NpcPanel.show_quest_book reset ecology view, preserving quest selection/filter semantics and close/load/title behavior. No Main/UiCoordinator/InputMap/old .tscn changes.

Manual J->Ecology->Back/Esc/QE; verify actual counts/targets/eased values, water unmeasured/no bar, native focus/scroll, live locale,3sizes/long text, NewGame/load/title and day-end precedence. No Inspector/tree setup; new scene children are script-built. Human tone/art/playtest acceptance remains separate.

## Phase7.3f daily reservation adapter (D111)

No scene/tree/Inspector change. Main._on_day_started validates ecology adjacent-day quote along existing weather/coop guards, reserves weather then runtime.begin_day(day,farm,land). Runtime freezes config/catalog/regions and reserves sole EcologyState before farm callbacks. Existing DaySimulator accepts optional final zero-argument ecology callback; Main binds actual day. Farm callback applies outgoing rain/growth and existing season withering; then animals/machines/ecology finish. Main verifies both completed days before weather/new rain/ledger/autosave/bulletin. Empty/unchanged ecology still commits day once. Runtime begin/finish/abort APIs and state token methods in API_INDEX; no token/copy saved. Invalid preflight gives explicit warning/no simulation/save; existing clock-first index policy remains. Late inconsistency stays locked without claiming completion. User lifecycle commands are guarded through callbacks; no new global clock API or alternative simulation path.

Manual: compare sleep/review-confirm/02:00 and direct existing morning route; one ecology update and matching saved day, no duplicate effects after repeated signal/load. Check watered mature/regrowing/withered and season-boundary crops, outgoing rain versus incoming sun/rain, actual owned land counts, held water placeholder. Reentry attempts cannot save/load/NewGame/title or mutate reserved ecology from farm/ecology notifications. Closest threshold JSON cases and arbitrary float rounding limits are in DATA_SCHEMA. UI/VFX still arrive in later approved substeps.

## Phase7.3e Main ownership and save13 (D110)

No existing .tscn/InputMap/autoload/Player/world geometry edit. Main keeps one ecology_state:EcologyState and ecology_runtime:LifeEcologyRuntime (RefCounted adapter, not a scene child). Runtime.configure(state,day)->bool configures the passed sole owner. prepare(payload:Dictionary)->Dictionary is read-only candidate validation via canonical farm/land context. begin_restore(payload)->Dictionary captures a detached validated candidate and sets busy; finish_restore(day:int,farm:FarmGridState,land:LandOwnershipState)->bool restores silently from actual final owners then releases busy. last_restore_reason is transient diagnostic; no saved UI/runtime flags or second owner. Methods reject reentrant entry. Main purchase/save/load/NewGame/title routes respect this busy guard through synchronous callbacks.

NewGame validates empty-farm/day0 candidate before resetting other owners. Load validates ecology context before changing live owners; actual restore follows farm/land/clock and existing day-end/coop/watering restoration. Main's private _restore_land_for_lifecycle uses existing public LandRuntime.close, LandOwnershipState.deserialize and WorldPresentation.refresh_land: LandRuntime.restore deliberately rejects the global busy lock, so only the owning lifecycle performs these same internal steps under its lock. No LandRuntime public API or separate file change.

SaveService13 adds ecology{day_index,metrics,triggered} with full-precision JSON. Pre-v13 unknown ecology keys cannot smuggle history; migration calibrates current canonical owned farm at saved clock day, no replay/reward. Valid13 matching-day state stays exact; corrupt/missing/mismatched component has explicit calibration reason. Invalid context blocks writing and rejects runtime preflight. Raw SaveService reads may retain ecology{} as explicit runtime-fallback marker if context is malformed; Main rejects that malformed context before mutating owners. Water remains unmeasured regardless of stored numeric placeholder. Existing v1-v12 golden bytes unchanged; v13 is additive.

This substep has no daily ecology callback yet. Direct saves after a changed clock normalize mismatched ecology to the current-garden baseline without replay;7.3f adds the once-per-day reserved simulation before this becomes a complete live ecology feature. No journal/VFX until their approved steps. Human editor acceptance is separate.

Manual: NewGame/Continue/slot save-load/title, compare inventory/wallet/crops/jobs/watering/coop/land/forecasts/Player; loaded ecology day equals clock, exact floats/history survive, no load signal/reward/bulletin. Callback attempts at Main save/load/NewGame/title must be blocked while restore runs. No node-tree or Inspector setup.

## Phase7.5j read-only explanations (D127)

LifeEcologySheet.director_history:LifeDirectorHistory is instantiated only with existing lazy ecology branch, inside rows_column after actual metrics; existing scroll handles history128/long text, Back fixed. Controller refreshes from actual aligned owners, no simulation. Back/hide/reset detaches all; ordinary quest branch has zero ProgressBar descendants. No editor setup.

## Phase8.6h notebook branch

LifeQuestBook adds story_button:Button and nullable story_sheet:LifeStoryNotebook. Book controller owns LifeStoryNotebookController; configure/open/close/reset/is_open/queue_render are transient VIEW APIs. Ecology open closes story; story open closes ecology; existing ecology reset also drops story so NpcPanel.show_quest_book always returns to quests. New/load/title book reset and deferred hidden cleanup free the lazy branch. Native J/Q/E/Esc and all three existing tabs/quest counts remain. Six small shared-theme scenes compose a header, independently scrolling objective and milestone lists/rows, and fixed Back. No new InputMap or editor setup.
