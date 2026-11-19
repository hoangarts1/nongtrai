# API INDEX — THE LIFE

## Phase8.6j implemented API

Step10/10 final verification after i pushedc4ca2a5/full1003. tools/sim_story.gd runs1000 explicit verification-fixture commands through actual StoryConfig/ReceiptRules/StoryState, comparing single/grouped/nativeJSON continuation traces. Sources/read acknowledgment/reset/stale/planned/unknown-page cases are exercised;231invalid commands reject per trace. No fixture is described as observed gameplay or extra simulated days. CLI valid exits0; invalid/unknown fixture exits1. Native integration executes real existing tool-controller sow/water/completed-day growth/harvest, shipping confirmation, QuestManager payout and native land purchase, then native J/notebook/Cancel/confirm/night review/autosave/slot load/title/Continue/NewGame. Supported5/10 and one dog remain; planned repairs/new NPCs/M2.4 and production Director remain unavailable. Existing forecasts/Minh and all prior sources/tests remain. Only verification tool/tests/docs change in this final step; save16/production code unchanged.

Import1 PASS with inherited duplicate artUID warnings. Native1:4/5; all1000-command CLI and16golden continuation cases passed. New journey owner-equality test exposed a stale companion context in the manually ticked fixture: buying east land makes the old dog cell(6,3) an owned-farm obstacle; load correctly repairs it to(6,6). A diagnostic logged only the changed owner. Calling existing DogRuntime.refresh_context after the actual land purchase performs the same live sparse-poll repair before capture, with an added walkable assertion. All original equality/night-autosave/dog assertions retained; no production/old-test change. Native2:3scripts/5/5/240assert/8.813s PASS/no errors/leaks, including all16goldens read/hash-checked, stable story owner/collector, actual5goal journey and six fresh vi/en1152x648/1280x720/1920x1080 PNGs. Inspected English1152journey: actual5/10, introRead/otherUnread, planned milestones, all native tabs and fixed Back fit. Current-source independent42dependency no-autoload/core/view/world-node project imports0; CLI positive0 reports1000commands, grouped/json match,231rejections in1603ms; deliberate invalid fixture1 with no script errors/leaks.

Original final full launcher/source/prior-test/20real-save SHA gates follow before this step's commit/push. The external delivery ledger records each actual scoped commit and raw logs/diffs/captures: D:/godot/game-godot-backups/next10-story-run-20261120-011237/DELIVERY.md. Final cumulative audit after push will verify10consecutive scoped commits, remote HEAD, all historical15goldens,20real saves and the two preserved/excluded prompt changes. Only f has the exact approved40output-version rows/34old tests; every later old-test byte is protected. All four renderer groups keep180seconds each; no skip/bounds change.

No editor tree/Inspector/project-setting setup. Run tools/run_tests.bat; independent probe uses the pinned Godot with --headless --path . --script tools/sim_story.gd (invalid diagnostic: -- --fixture=invalid). Manual F5: New/Continue -> J -> Sổ tay của bà, inspect actual progress, scroll both columns and Q/E/Tab/Enter/Esc; read intro, Cancel remainsUnread, confirm becomesRead, save/load/Continue preserves flags, NewGame clears them. Check all five real actions, paused world, night review and one companion, vi/en/three sizes. Human F5/tone/OS IME/FPS/final-art acceptance remains pending. This completes only approved8.6a-j foundation automation, not the full playable Chapter I/station milestone. Repair costs/resources/rewards, An/Bác Lâm content/locations/art, irrigation/bread/bridge/station gameplay and production prototype gating need later scope/decisions.

## Phase8.6i implemented API

Step9/10 after h pushed40fcf63/full997. Six optional page links live in the existing notebook objective scroll; locked links disable and expose no body. Four small shared-theme scene/script pairs compose page_link and moment_sheet/body/actions. Main owns one LifeStoryMomentFlow; UiCoordinator registers its panel and alone owns backdrop/pause/focus/Esc/native GUI routing and resize. UiLayout is unchanged/outside scope; coordinator applies the new panel rectangle after its existing reflow. Opening a page captures actual StoryState revision and closes journal through the existing coordinator. Cancel/Esc returns to a fresh notebook without acknowledgments. Explicit native confirm alone calls guarded acknowledge_page; stale quote shows localized Back/reopen guidance, duplicate acknowledgment does not republish. State/flow busy guards reject callback lifecycle/reentry; new/load/title closes without reopening/replay. No new save field/version, input action, audio/art/reward/production unlock. Intro body preserves the fixed original STYLE_GUIDE quotation; other grandmother text is a draft for tone review.

Import1 PASS with inherited duplicate artUID warnings. Native1:19/20; all layout/old regressions passed, new native Enter revealed a real new modal input bug: pressed ui_accept passed to GUI but key release was consumed, so the native Button never committed. Production UiCoordinator new-branch fix passes both halves via documented event.is_action; all assertions unchanged. Native2:6scripts/20/20/791assert/26.466s PASS/no errors/leaks, including all14prior notebook/quest/ecology tests unchanged. Tests cover native page-link/mouse/Tab/Enter/Esc, held Q/E/J while reading, locked/hidden/stale/reentrant/duplicate requests, save/load read persistence, no other-owner mutation, load/new/title/Continue close without replay, and night-review precedence without acknowledgment/extra day. Fresh12letter plus24notebook PNGs cover vi/en1152x648/1280x720/1920x1080, short/long scrollable letters, actual page availability and fixed actions. Inspected Vietnamese1152intro: fixed quotation readable, buttons within paper and clear optional acknowledgment. Native OS IME/tone/FPS/human F5 remain separate. No Inspector/editor setup. Original full/source/prior-test/20real-save SHA gates follow.

`ui/story/page_link.gd`:
```gdscript

signal page_requested(page_id: StringName)
func display(page: Dictionary) -> void:

```

`ui/story/moment_sheet.gd`:
```gdscript

func display(model: Dictionary, failed: bool = false) -> void:

```

`ui/story/moment_body.gd`:
```gdscript

func display(model: Dictionary) -> void:

```

`ui/story/moment_actions.gd`:
```gdscript

func refresh() -> void:

```

`ui/story/story_moment_flow.gd`:
```gdscript

func configure(main: Node) -> void:
func open(page_id: StringName) -> bool:
func close() -> void:
func back() -> void:
func confirm() -> void:

```

`ui/story/notebook.gd`:
```gdscript

signal page_requested(page_id: StringName)

```

## Phase8.6h implemented API

Step8/10 after g pushed7cfa509/full992. Six small shared-theme scene/script pairs compose LifeStoryNotebook, chapter header, independently scrolling objective/milestone lists and rows, plus fixed Back. A compact Story Button beside Ecology uses the existing J journal and all three enabled common tabs; QuestBookSnapshot entry counts unchanged. Book controller owns transient LifeStoryNotebookController; both branches close each other, existing Ecology.reset also drops story so NpcPanel.show_quest_book returns to quests without editing NpcPanel. Hide/new/load/title detaches and frees lazy scene nodes; repeat-open child counts are stable. Back restores native entry focus. No save/domain/InputMap/old .tscn/Player/dog/art changes; no editor setup.

Import1 PASS with inherited duplicate artUID warnings. Native1:13/14, new wheel+Back case failed while old quests5/5 and ecology4/4 passed. Motion-only fixture correction in native2 did not resolve it. Two read-only pointer diagnostics proved the hovered native Button was the enabled Back, no gameplay lock; they changed no assertions/production semantics. The NEW synthetic wheel stream had presses without release, leaving GUI mouse capture; complete press/release pairs fixed it. Native3:4scripts/14/14/614assert/19.009s PASS/no errors/leaks; all original quest/ecology sources unchanged. Fresh24 PNG captures cover vi/en1152x648/1280x720/1920x1080, empty/full-supported display fixtures, long text, top/bottom and independent scrolls. Inspected English1152initial and Vietnamese1152long-bottom: readable actual0/10 or5/10, Coming later milestones, fixed native Back, all original tabs fit. Native J/mouse/Tab/wheel/Enter/Q/E/Esc, readonly owners/save bytes/live locale, invalid hidden entry, load/new/title and repeated-free cases pass. Original journal-open save guard retained/tested before closing journal and returning title. Full gate/source/old-test/real-save SHA checks follow. Optional page links/letters are only approved step i, not implemented here.

`ui/story/notebook.gd`:
```gdscript

signal back_requested()
func display(model: Dictionary) -> void:

```

`ui/story/chapter_header.gd`:
```gdscript

func display(model: Dictionary) -> void:

```

`ui/story/objective_list.gd`:
```gdscript

func display(values: Array) -> void:

```

`ui/story/objective_row.gd`:
```gdscript

func display(row: Dictionary) -> void:

```

`ui/story/milestone_list.gd`:
```gdscript

func display(values: Array) -> void:

```

`ui/story/milestone_row.gd`:
```gdscript

func display(row: Dictionary) -> void:

```

`ui/story/notebook_controller.gd`:
```gdscript

func configure(panel: NpcPanel, main: Node) -> void:
func is_open() -> bool:
func open() -> void:
func close() -> void:
func reset() -> void:
func queue_render() -> void:

```

## Phase8.6g implemented API

Step7/10 after f pushed14699d4/full987. LifeStorySnapshot captures a detached validated wire/readout from the sole StoryState; from_wire is also a pure display-fixture projection. LifeStoryPresenter formats current vi/en without state, source actions or save calls. Actual supported completion is at most5/10; five planned objectives and four M2 milestones remain Coming later, chapter_complete stays false. Six pages expose actual availability/read markers; locked bodies are empty. Missing/busy/unconfigured owners show a waiting readout. No fake rewards/XP/deadlines, new NPCs or repairs. Goal descriptions now give pending instructions instead of claiming progress before it happens. Draft grandmother prose remains for human tone review.

Import1 PASS with inherited duplicate artUID warnings. Focused1 honestly failed one NEW legacy-display fixture because it supplied a dictionary instead of the documented tutorial boolean array; fixed the fixture shape without changing the expected three observations or production semantics. Focused2:2scripts/5/5/69assert/2.002s PASS, empty/partial/legacy/all-supported, planned boundaries, detached nested rows, invalid wire, vi/en key coverage and negative missing-key test, repeated locale reads preserving all owners/save bytes. DataValidator.validate_story_text and deferred validate_data presenter key gate cover the new keys. No scene/Inspector/InputMap setup. Native journal presentation comes only in approved h/i; original full gate and SHA checks follow.

`ui/story/story_snapshot.gd`:
```gdscript

static func capture(main: Node) -> Dictionary:
static func from_wire(wire: Dictionary, revision: int = 0) -> Dictionary:

```

`ui/story/story_presenter.gd`:
```gdscript

static func text(key: StringName) -> String:
static func describe(snapshot: Dictionary) -> Dictionary:

```

`scripts/core/data_validator.gd`:
```gdscript

static func validate_story_text(locales: Array[String], keys: PackedStringArray) -> PackedStringArray:

```

## Phase8.6f implemented API

Step6/10 after8.6e pushed1fac368/full977. Main owns stable StoryState/LifeStoryRuntime. Actual command receipt adapter LifeStoryObserverFlow extends unchanged LifeDirectorActivityCollector, calls inherited finish first, emits typed command_committed only on TRUE return, holds inherited busy through extra dispatch and rejects fake emissions outside dispatch. Original collector publishes counters before proven check: merely watching activity_changed would falsely credit unproven commands. Existing DirectorRuntime creates collector outside this scope; new StoryRuntime replaces that idle node once at startup with same-name/base-compatible subtype, rebinds three documented cached tool/shop/bin references, frees original; all other adapters query Main field. One live collector and owner persist across new/load/title, counters/base semantics untouched. No second simulation/counting path or queued-save gap. QuestManager gains only is_busy getter; actual quest completion and typed LandRuntime.purchased under its existing guard provide other proven sources. Lifecycle suppresses observation through existing ecology/director busy flags; no raw Events/possession/proven=false credit.

SaveService.CURRENT_VERSION16 adds only story{completed_objectives,read_pages}; migrate15to16 ignores injected earlier story/read history and calibrates only verifiable old progress. Current valid story preserved; bad component fallback preserves other owners and removes fabricated read history. Dog15/director14/can10 introduction behavior and all historical fixtures remain. Main preflights full story candidate before core restore and commits silent same-owner restore after core success; Root save/new/load/title/publication and source-dispatch reentry protected. NewGame clears story, Continue/slots retain exact read flags. No new scene/input/Player/dog removal, prices/rewards, chapter completion or Director entitlement.

Import1 clean except inherited duplicate artUID warnings. Actual deferred SaveService migration of tracked golden15 produced golden16; write/readback exit0, never human save. Focused1:3scripts/10/10/142assert/3.978s PASS; native1 same10/10/142assert/4.140s PASS, no script errors/leaks. Includes real sow/water/completed-day growth/harvest/shipping, quest payout/land purchase, wrong-token/cancel, unproven published counts, forged producer/notice, inactive backend, exact save/load/Continue, corrupt-only fallback,15historical goldens/actual16, one collector/owner/dog over3new-load cycles, and rejected Main/command callback reentry. Known legacy turnip visual fallback warnings retained. Exact approved40row/34old-file patch verified byte-for-byte (493other prior tests/fixtures unchanged),20real saves SHA unchanged. Full gate follows. No editor setup; visible story notebook/pages are later g-i, not implemented here.

`scripts/view/story/story_runtime.gd`:
```gdscript

func configure(main: Node) -> bool:
func is_busy() -> bool:
func prepare(payload: Dictionary) -> Dictionary:
func restore(candidate: Dictionary) -> bool:
func reset() -> bool:
func suspend() -> void:

```

`scripts/view/story/story_observer_flow.gd`:
```gdscript

signal command_committed(day: int, source: StringName, counts: Dictionary)
func is_dispatching() -> bool: return _dispatching
func begin_command(source: StringName) -> Dictionary:
func finish_command(token: RefCounted, counts: Dictionary, proven: bool = true) -> bool:
func reset_receipt() -> bool:

```

`scripts/core/save_service.gd`:
```gdscript

func migrate_15_to_16(data: Dictionary) -> Dictionary:

```

`scripts/domain/quests/quest_manager.gd`:
```gdscript

func is_busy() -> bool:

```

`scripts/view/land_runtime.gd`:
```gdscript

signal purchased(parcel_id: StringName)

```

## Phase8.6e implemented API

Step5/10 after8.6d pushed9860caf/full971. StorySaveContext prepares a canonical baseline from strict verifiable old owner evidence. StorySaveCodec preserves valid current progress/read pages exactly; legacy or malformed component falls back only story with verified supported progress and no read markers, chronology or reward replay. Other input payload fields never mutate. StoryLifecycle holds only refs/transient guard, validates complete candidate before replacing the same StoryState, restores silently, resets through original owner and rejects reentrant/busy/bad candidates. No game-save wiring yet: current version remains15 until approved f.

Import1 passes with inherited duplicate artUID warnings. Focused1:2scripts/6/6/148assert/0.493s PASS/no errors/leaks, all15tracked goldens read/hash-checked unchanged, exact current preservation, corrupt/legacy fallback and busy/reset/quote cases. Current-source independent40dependency no-autoload/core/view/world-node project imported and passed1000legacy restores,1000exact nativeJSON restores,1000corrupt fallbacks and1000forged-M2rejections in2096ms, exit0/no leaks. Probe contexts are explicit fixtures, not gameplay observations/days. Original full and old-test/golden/20real-save SHA proofs follow; no scene/Inspector/InputMap changes. Read-only pages/UI and actual runtime follow only their approved scopes.

`scripts/domain/story/story_save_codec.gd`:
```gdscript

static func normalize(config: StoryConfig, raw: Variant, payload: Dictionary, legacy: bool = false) -> Dictionary:

```

`scripts/domain/story/story_save_context.gd`:
```gdscript

static func capture(config: StoryConfig, payload: Dictionary) -> Dictionary:

```

`scripts/domain/story/story_lifecycle.gd`:
```gdscript

func is_busy() -> bool:
func configure(config: StoryConfig, state: StoryState) -> bool:
func prepare(payload: Dictionary, legacy: bool = false) -> Dictionary:
func restore(candidate: Dictionary) -> bool:
func reset() -> bool:

```

## Phase8.6d implemented API

Step4/10 after8.6c pushedaeb3fad/full963. Pure StoryObservationSampler imports only strict stored tutorial bools1/4/5, actual registered completed turnip_delivery and ordered valid first parcel prefix. Missing/malformed/coerced/possession/active-only fields do not invent evidence; no dates, talks, repairs, receipt counts or rewards inferred. StoryReceiptRules maps native positive integer command counts with valid source identity and explicit committed context, verified delivery completion and first-parcel ownership. Unknown/source-mismatched/unproven/zero/negative/bool/fraction/extra counters rejected; planned/M2 goals have no source. Detached DTO output, no owner/Node/autoload mutation or live subscription.

Import1 passes with inherited duplicate artUID warnings. Focused1:2scripts/8/8/51assert/0.418s PASS/no errors/leaks. Independent current-source38dependency no-autoload/core/view/world-node project:1000projections,1000unproven and1000possession rejections,359ms, exit0/PASS. Verification snapshots explicitly are fixtures, not observed gameplay. Old tests/goldens/20real saves protected; original full follows. save15 unchanged; no editor scene/Inspector/InputMap steps.

Runtime preparation found the original collector publishes counters BEFORE testing proven, so a busy counter signal alone is insufficient to credit story. In approved f, use the already-allowed new StoryObserverFlow script as a thin subclass/completion adapter around the unchanged LifeDirectorActivityCollector: inherited finish_command must return true before emitting a guarded story receipt. Main may instantiate that subtype while preserving the original public collector type/APIs. Original collector file stays untouched; no second counting/simulation path or queued-save gap. Quest/land use actual guarded completion/ownership as planned. This note is the chosen integration design, not a claim runtime is implemented in d.

`scripts/domain/story/story_observation_sampler.gd`:
```gdscript

static func legacy(config: StoryConfig, payload: Dictionary) -> Dictionary:
static func section(raw: Variant) -> Dictionary:
static func string_ids(raw: Variant) -> Array[String]:
static func first_parcel(config: StoryConfig, ownership: Dictionary) -> bool:

```

`scripts/domain/story/story_receipt_rules.gd`:
```gdscript

static func from_command(config: StoryConfig, source: StringName, counts: Dictionary, committed: bool) -> Dictionary:
static func delivery(config: StoryConfig, id: StringName, quests: Dictionary, committed: bool) -> Dictionary:
static func parcel(config: StoryConfig, id: StringName, ownership: Dictionary, committed: bool) -> Dictionary:

```

## Phase8.6c implemented API

Step3/10 after8.6b pusheda1ed122/full958. StoryState is the sole pure RefCounted owner of the two-field wire; configured immutable DATA, canonical guarded observations, page availability/acknowledge with expected revision, idempotence, serialize/deep detached return values and silent validated deserialize from this first commit. Revision is derived/transient and increments on reset/restore; stale requests cannot cross lifecycle. Only known supported objective IDs can be observed; planned goals/M2 cannot be written and5/10 supported progress is never full ChapterI. StoryRules queries do not grant entitlements. No Node/autoload/events/game-save/economy/runtime connection yet; save15 remains.

Import1 passes with inherited duplicate assetUID warnings. Focused1 had5/5/42assert but new test closure captured the RefCounted emitter, retaining69objects/19resources at exit; NOT accepted as clean. Fixture now explicitly disconnects that callback, every assertion retained. Final focused2:2scripts/5/5/42assert/0.439s PASS, no errors/leaks. Tests cover once-only/locked/unknown/duplicate/stale, commit-before-publish, mutation/configure/restore reentry, silent JSON restore, data/output detachment and quote invalidation. Current-source independent36dependency no-autoload/core/view/world-node project:1000mixed steps,1000JSON restores,1000stale rejections and1000planned rejections,462actual publications,710ms, exit0/PASS/no leaks. These are verification commands, not observed gameplay or simulated days. Full gate and old-test/golden/20real-save SHA proof follow. No editor tree/Inspector/InputMap steps; actual evidence sampler and lifecycle/runtime are later approved steps.

`scripts/domain/story/story_state.gd`:
```gdscript

signal changed()
func is_busy() -> bool: return _busy
func get_revision() -> int: return _revision
func configure(config: StoryConfig) -> bool:
func serialize() -> Dictionary:
func deserialize(raw: Dictionary) -> bool:
func can_read_page(page_id: StringName) -> bool:
func is_complete() -> bool:
func observe(objective_ids: PackedStringArray, expected_revision: int = -1) -> Dictionary:
func acknowledge_page(page_id: StringName, expected_revision: int = -1) -> Dictionary:

```

`scripts/domain/story/story_rules.gd`:
```gdscript

static func can_read(config: StoryConfig, wire: Dictionary, page_id: StringName) -> bool:
static func chapter_complete(config: StoryConfig, wire: Dictionary) -> bool:

```

## Phase8.6b implemented API

Step2/10 after8.6a pushed700cbd7/full954. Pure StorySnapshotCodec defines only {completed_objectives:Array[String],read_pages:Array[String]}, canonical Resource order. Strict native string/array/key types, no extra fields, duplicate/unknown/planned IDs, missing objective/page prerequisites or invalid config. Empty snapshot independent; decode returns detached output and never mutates input. No persistent owner/Node/autoload/game save or runtime integration at this step; save15 unchanged.

Import1 clean except inherited assetUID warnings. Focused1:1script/4/4/27assert/0.402s PASS/no errors/leaks. Current-source isolated34dependency no-autoload/core/view/world-node project imported and ran1000nativeJSON roundtrips plus1000locked-M2rejections in407ms, exit0/PASS; pure probe explicitly uses verification snapshots, not observed gameplay. Unit cases include booleans/fractions/StringName values, bad field types/extra keys, duplicates, unknown/locked pages, prerequisite chains and canonical/detached data. Old tests/goldens/20real saves protected; full gate follows. No scene/Inspector/InputMap steps. Owner/revision/publication follows only in approved8.6c.

`scripts/domain/story/story_snapshot_codec.gd`:
```gdscript

static func empty() -> Dictionary:
static func decode(config: StoryConfig, raw: Variant) -> Dictionary:

```

## Phase8.6a implemented API

Step1/10 approved8.6a-j on2026-11-20; base b808308/full948. DATA StoryConfig/Objective/Page catalogue only: five supported objective IDs, five planned-only chapter tasks, four planned-only M2 repairs, six optional grandmother pages. Actual QuestData turnip_delivery and first land parcel are referenced; no new NPC/price/reward/world object/owner/UI/forecast or Director gate. All42localized catalogue keys present in vi/en; wording remains a draft for human tone acceptance.

Pure StoryCatalogValidator checks sources/first-occurrence targets, duplicate/empty IDs, exact existing references, planned milestones, page prerequisites and objective/page cycles. DataValidator delegates to it and the original validate_data gate includes the actual catalogue. StoryConfig.freeze detaches full Resource graphs with shared-copy memo and packed arrays; the first focused run5/6 caught packed-array aliasing, production copy now duplicates all packed arrays and original assertion retained plus nested NPC weekday check added. Final focused2:2scripts/6/6/29assert/2.519s PASS, no errors/leaks. Import1 passes with inherited duplicate artUID warnings. CLI positive/invalid-cycle/unknown fixture tested through real child processes. Current-source isolated34-dependency project has no autoload/core/view/world nodes: import0, positive0/PASS, deliberate cloned cycle1/rejected. No source resource changed by invalid fixture. Old tests/goldens/20real saves protected; final full follows. No editor scene/Inspector/InputMap setup for this DATA-only step. Runtime story/save16 and notebook are later approved steps, not delivered here.

`scripts/data/story_config.gd`:
```gdscript

func get_objective(id: StringName) -> StoryObjectiveData:
func get_page(id: StringName) -> StoryPageData:
func supported_ids() -> PackedStringArray:
func translation_keys() -> PackedStringArray:
func frozen_copy() -> StoryConfig:

```

`scripts/domain/story/story_catalog_validator.gd`:
```gdscript

static func validate(config: StoryConfig) -> PackedStringArray:

```

`scripts/core/data_validator.gd`:
```gdscript

static func validate_story_config(config: StoryConfig, locales: Array[String] = []) -> PackedStringArray:

```

## Phase8.5j implemented API

Full1 final launcher exit0:240scripts/948/948/99865assert; four sequential groups 140.385/98.237/99.243/121.706s, each<180. Parse/data/headless63/Main PASS. Complete native/source/old-test/real-save/commit proof is recorded in PROGRESS and batch delivery; human F5/art/IME/FPS is still required. This is automation delivery of the approved8.5a-j batch, not final human acceptance of roadmap8.5.

Step10/10 after8.5i pushed ab757756f9ba2c8b9a6c7d1bda7f37a478f427c4 with full942 and user-approved four sequential graphics groups,180s each. This step adds only tools/sim_dog.gd and three new test scripts, plus authorized documentation; runtime/Resources/save15/InputMap/old scenes and all prior tests/goldens remain unchanged.

CLI uses actual DogConfig, DogState, DogNavigation and DogMovementService for1000 successful adjacent commits per trace, changes actual bounded obstacle contexts/targets, validates every route cell/edge and name, and separately counts19 explicit invalid-origin repairs (not disguised as adjacent movement). Three traces (single/group13/group17 with nativeJSON checkpoint500) and final state agree;59 navigation rebuilds, identical context repolls never rebuild. Original-project CLI positive exit0:1000steps/10.252s; negative unknown fixture exit1. Independent31-dependency current-source project has no autoload/view/core/world-node dependencies: import/CLI exit0, same1000steps/19repairs/59rebuilds/name and trace equality,9.948s measured. Timing is this CLI workload, no FPS/no-perf-impact promise.

Import1 passes with inherited duplicate assetUID warnings. Initial focused1 was5/6 because the NEW test parsed engine banners as JSON; corrected new report-line extraction and nativeJSON numeric expectation, retaining every assertion and adding unique-report verification. Final focused2:3scripts/6/6/74assert/14.636s; final native1:3scripts/6/6/86assert/15.852s, no errors/leaks. Real native mouse/Enter traverses name, follow, title/Continue, cancel, new-game profile submission, land purchase, machine placement confirmation, coop purchase, night review/confirmation/autosave/morning dismissal. Actual golden14 and15 load/save/load preserve other owners and dog; one actor, restored view/nav, no moving route, no farm-click leak,50unchanged-context refreshes without rebuild. vi/en x1152/1280/1920 yields6fresh PNGs with verified dimensions; vi1152 and en1920 visually inspected. Legacy turnip visual fallback warnings remain inherited.

Tool entry: pinned Godot --headless --path . --script res://tools/sim_dog.gd; success prints one JSON report with status,steps,adjacent_commits,repairs,rebuilds,name,cell_x/cell_y,grouped_match,json_match,elapsed_ms and exits0; unknown user arguments or failed checks exit1. This diagnostic trace/cache is never added to the game save. Human F5/art/tone/OS IME/FPS acceptance stays separate; no Inspector, scene tree or InputMap setup is required. Full launcher and SHA proofs follow.

## Phase8.5i approved runner amendment

User-approved runner correction is applied: exact two-file patch, four sequential graphics groups, full coverage and unchanged180000ms per child. Real repository runner contract:279checks PASS. Full3 launcher exit0:237scripts/942/942/99779assert; groups122.076/131.580/95.773/108.048s. Parse/data/headless63/Main PASS. Source2589/prior499test-fixture files/20real saves verified; prior two3group timeouts retained as failed evidence, no assertion/test/image removal. Commit/push verification follows this successful run.

## Phase8.5i implemented API

﻿Step9/10 after8.5h pushedcd3a3b9/full937 (initial GitHub connection reset; retry and exact remote verification completed before this step). Runtime idle waits configured3s, chooses bounded deterministic walkable candidates within2Manhattan cells of actual Player, moves through original guarded adjacent quote flow; follow interrupts idle when Player leaves. Idle cursor/timing derived only, reset on lifecycle. DogReactionFlow reads actual rainy state and existing DirectorActivityState crop_harvested deltas only while real command collector publishes; raw producer signals cannot fabricate a reaction/observed action. This is read-only cosmetic feedback, does not record activity or create rewards. Happy tail lasts configured0.8s; pause freezes, new/load/title reset reaction/latches and reuse the same actor/two child nodes. Natural new-day rain can react after gameplay resumes; restored current rain does not replay. No hunger/feed/affinity/economy/sounds/new events/inputs/save15 fields.

Import1 clean except inherited duplicate assetUID warnings. Focused1 before adding render-pose case:2scripts/4/4/27assert/1.963s PASS. Final native1:2scripts/5/5/40assert/2.581s PASS with3fresh rain/happy/normal PNGs archived, first visually inspected. Tests cover idle/local bounds/follow interruption, actual harvest/inventory receipt once, repeat/producer spoof ignored, rain once and expiry, pause pose/owner freeze, save/load/title clear without actor/node growth. Known legacy starter turnip uses existing visual fallback warning; no crop data/art changed. Old tests/goldens/20real saves protected; final full follows.

`scripts/view/dog/dog_reaction_flow.gd`:
```gdscript

func configure(main: Node, runtime: LifeDogRuntime) -> void:
func reset() -> void:
func advance(delta: float, playing: bool) -> void:
func dispose() -> void:

```

`scripts/view/dog/dog_avatar_2d.gd`:
```gdscript

func configure(profile: DogVisualProfile) -> bool:
func set_motion(walking: bool, direction: Vector2 = Vector2.ZERO) -> void:
func advance(delta: float, playing: bool = true) -> void:
func set_happy(value: bool) -> void:
func is_happy() -> bool: return _happy
func get_phase() -> float: return _phase

```

`scripts/view/dog/dog_actor_2d.gd`:
```gdscript

signal arrived(cell: Vector2i)
func configure(state: DogState, grid: IsometricGrid, config: DogConfig, profile: DogVisualProfile) -> bool:
func set_unnamed_caption(text: String) -> void:
func reset_position() -> void:
func begin_step(cell: Vector2i) -> bool:
func is_moving() -> bool: return _moving
func advance(delta: float, playing: bool = true) -> void:

```

`scripts/view/dog/dog_runtime.gd`:
```gdscript

func configure(main: Node) -> bool:
func is_busy() -> bool:
func can_play() -> bool:
func advance(delta: float) -> void:
func refresh_context() -> void:
func reset() -> bool:
func suspend() -> void:
func restore(raw: Variant) -> bool:

```

`scripts/domain/pets/dog_follow_rules.gd`:
```gdscript

static func distance(a: Vector2i, b: Vector2i) -> int:
static func decide(config: DogConfig, navigation: DogNavigation, origin: Vector2i, player: Vector2i, following: bool = false) -> Dictionary:
static func nearest_walkable(config: DogConfig, navigation: DogNavigation, desired: Vector2i) -> Dictionary:
static func idle(config: DogConfig, navigation: DogNavigation, origin: Vector2i, player: Vector2i, sequence: int = 0) -> Dictionary:

```

## Phase8.5h implemented API

﻿Step8/10 after8.5g pushed4e5c471/full933. Companion card below Character identity uses detached DogSnapshot and localized DogPresenter. New NameSheet/Form/Card scenes compose only shared Theme/native controls; Character retains public identity/skills/relationships/tabs aliases and left profile can scroll. NameFlow captures expected owner revision, native LineEdit has max_length0 (no silent24-character truncation), command goes through DogState validation and guarded publication. Successful save and explicit Cancel/Back return to Character; Esc/coordinator/lifecycle close only hide and never reopen. Owner remains authoritative, default world caption follows locale and named caption remains actual name. UiCoordinator alone owns holds/focus/input, native text/Tab/Enter preserved without world shortcuts; new/load/title close naming. No new actions/autoload/old scene/Player/save15 wire or other domain changes.

Import1 clean except inherited assetUID warnings. Focused1 3scripts/4/4/46assert/2.284s PASS. Native1 adds original Character layout/screen regressions:5scripts/12/12/1099assert/13.780s PASS; warnings only expected missing legacy crop/coop fallbacks. Native mouse open, Unicode key events M+U00E2+y, Enter/Tab/Esc, cancel/invalid/25char/control/stale quote/lifecycle close all pass. vi/en x1152/1280/1920 long24codepoint names produced12fresh name/card captures, vi1152 card and modal visually inspected. Forty read-only open/cancel/render refreshes preserve owners and save bytes; locale default caption verified. All old tests/goldens and20real saves protected. Human OS IME composition/art/tone/F5 remain pending, not inferred from synthetic native key events. Full follows.

`ui/pet/dog_companion_card.gd`:
```gdscript

signal rename_requested()

```

`ui/pet/dog_name_flow.gd`:
```gdscript

func configure(main: Node) -> void:
func open() -> void:
func close() -> void:
func back() -> void:
func save() -> void:

```

`ui/pet/dog_snapshot.gd`:
```gdscript

static func capture(main: Node) -> Dictionary:

```

`ui/pet/dog_presenter.gd`:
```gdscript

static func name_text(snapshot: Dictionary) -> String:
static func card(panel: LifeDogCompanionCard, snapshot: Dictionary) -> void:
static func form(panel: LifeDogNameSheet, result: Dictionary = {}) -> void:

```

`ui/character/character_snapshot.gd`:
```gdscript

static func capture(main: Node) -> Dictionary:

```

`ui/character/character_presenter.gd`:
```gdscript

static func render(panel: LifeCharacterSheet, snapshot: Dictionary) -> void:

```

`ui/character/character_flow.gd`:
```gdscript

func configure(main: Node) -> void:
func open() -> void:
func close() -> void:
func refresh() -> void:

```

`scripts/view/ui_coordinator.gd`:
```gdscript

func configure(main: Node) -> void:
func get_active_panel() -> Control:
func close_active() -> void:

```

`scripts/view/ui_layout.gd`:
```gdscript

static func apply(main: Node) -> void:
static func reflow(main: Node) -> void:

```

`scripts/core/data_validator.gd`:
```gdscript

static func validate_dog_config(config: DogConfig) -> PackedStringArray:
static func validate_director_profile(profile: DirectorProfile, locales: Array[String]) -> PackedStringArray:
static func validate_director_debug_text(locales: Array[String], keys: PackedStringArray) -> PackedStringArray:
static func validate_director_activity(config: DirectorActivityConfig) -> PackedStringArray:
static func validate_ecology_feedback(config: EcologyFeedbackProfile, profile: EcologyProfile) -> PackedStringArray:
static func validate_ecology_journal(config: EcologyJournalConfig, profile: EcologyProfile, locales: Array[String]) -> PackedStringArray:
static func validate_ecology_sampling(config: EcologySamplingConfig, crops: Array[Resource]) -> PackedStringArray:
static func validate_ecology_profile(profile: EcologyProfile) -> PackedStringArray:
static func validate_scenery_catalog(catalog: SceneryArtCatalog) -> PackedStringArray:
static func validate_crop_stage_config(config: CropStageConfig) -> PackedStringArray:
static func validate_crop_economy(config: CropEconomyConfig, crops: Array[Resource], items: Array[Resource]) -> PackedStringArray:
static func validate_crop_migration(config: CropMigrationConfig, crops: Array[Resource]) -> PackedStringArray:
static func validate_inventory_config(config: InventoryConfig) -> PackedStringArray:
static func validate_machine_build_config(config: MachineBuildConfig, world: IsometricWorldConfig) -> PackedStringArray:
static func validate_watering_can_config(config: WateringCanConfig) -> PackedStringArray:
static func validate_bag_upgrade_config(config: BagUpgradeConfig) -> PackedStringArray:
static func validate_land_expansion_config(config: LandExpansionConfig) -> PackedStringArray:
static func validate_water_source_config(config: WaterSourceConfig, locations: WorldLocations, land: LandExpansionConfig) -> PackedStringArray:
static func validate_isometric_2d_assets(asset_root: String = "res://assets") -> PackedStringArray:
static func validate_isometric_world_config(config: IsometricWorldConfig) -> PackedStringArray:
static func validate_item_resources(resources: Array[Resource]) -> PackedStringArray:
static func validate_item_paths(paths: Array[String]) -> PackedStringArray:
static func validate_crop_references(crops: Array[Resource], items: Array[Resource]) -> PackedStringArray:
static func validate_crop_paths(crop_paths: Array[String], item_paths: Array[String]) -> PackedStringArray:
static func validate_translation_keys(paths: Array[String], required_keys: PackedStringArray) -> PackedStringArray:
static func validate_weather_profile(path: String) -> PackedStringArray:
static func validate_weather_resource(profile: WeatherProfile) -> PackedStringArray:
static func validate_art_palette_path(path: String) -> PackedStringArray:
static func validate_character_catalog_path(path: String) -> PackedStringArray:
static func validate_farming_art_catalog_path(path: String) -> PackedStringArray:
static func validate_world_art_catalog_path(path: String) -> PackedStringArray:
static func validate_item_visual_assets(resources: Array[Resource]) -> PackedStringArray:
static func validate_quest_resources(quests: Array[Resource], items: Array[Resource]) -> PackedStringArray:
static func validate_quest_paths(quest_paths: Array[String], item_paths: Array[String]) -> PackedStringArray:
static func validate_npc_world(data: NpcWorldData, items: Array[Resource], quests: Array[Resource], locale_paths: Array[String]) -> PackedStringArray:
static func validate_vietnamese_values(english_path: String, vietnamese_path: String) -> PackedStringArray:
static func validate_recipe_catalog(recipes: Array[Resource], machines: Array[Resource], items: Array[Resource]) -> PackedStringArray:
static func validate_recipe_economy(config: RecipeEconomyConfig, recipes: Array[Resource], machines: Array[Resource], items: Array[Resource]) -> PackedStringArray:
static func validate_dog_visual(profile: DogVisualProfile) -> PackedStringArray:
static func validate_dog_text(locales: Array[String], keys: PackedStringArray) -> PackedStringArray:

```

## Phase8.5g implemented API

﻿Step7/10 after8.5f pushed8fc035c/full929. SaveService.CURRENT_VERSION15 adds only dog{name,cell_x,cell_y}; 14-to15 baseline and all earlier migrations preserve prior systems and do not simulate days. Independent DogSaveCodec canonicalizes nativeJSON integers/name, preserves a valid Unicode name on bad/missing position and supplies bounded safe Resource baseline. DogLifecycle prepares against current actual nav before silent replacement of the same DogState; runtime refreshes sparse obstacles and reuses actor/children after load. Good current cells preserved; blocked positions repair locally with good name retained. No saved route/timer/nav cache/Nodes; dirty-save observes actual dog commands. Root busy guard remains across publication. Director intent/default-off, weather three forecasts, ecology/coop/can/land/jobs/progress unchanged.

Import1 clean except inherited assetUID warnings. Focused1 2scripts/4/4/94assert/1.404s PASS; native1 1script/2/2/71assert/1.384s PASS. All fourteen historical golden inputs tested, prior files untouched. Actual SaveService._migrate produced new golden15 from tracked golden14 (never a human save). Independent32-dependency no-autoload project:1000nativeJSON/Unicode/safe-cell/restore steps PASS. Current save/load/Continue/new/title and bad dog-only fallback retain other real owners. Exact approved38row/33oldtest compatibility verified byte-for-byte; remaining455prior tests/fixtures and20real saves SHA unchanged. Full follows; no assertion removal/fixture/golden1..14 changes or timeout extension.

`scripts/domain/pets/dog_save_codec.gd`:
```gdscript

static func normalize(config: DogConfig, raw: Variant, desired: Vector2i) -> Dictionary:

```

`scripts/domain/pets/dog_lifecycle.gd`:
```gdscript

func configure(config: DogConfig, state: DogState) -> bool:
func prepare(raw: Variant, desired: Vector2i, navigation: DogNavigation) -> Dictionary:
func restore(prepared: Dictionary) -> bool:

```

`scripts/core/save_service.gd`:
```gdscript

func save_game(payload: Dictionary, slot: int = 1) -> bool:
func get_write_report() -> Dictionary:
func load_game(slot: int = 1) -> Dictionary:
func inspect_slot(slot: int = 1) -> Dictionary:
func get_load_report(slot: int = -1) -> Dictionary:
func has_save(slot: int = 1) -> bool:
func load_latest() -> Dictionary:
func inspect_latest() -> Dictionary:
func get_latest_summary() -> Dictionary:
func delete_save(slot: int = 1) -> void:
func migrate_3_to_4(data: Dictionary) -> Dictionary:
func migrate_4_to_5(data: Dictionary) -> Dictionary:
func migrate_5_to_6(data: Dictionary) -> Dictionary:
func migrate_6_to_7(data: Dictionary) -> Dictionary:
func migrate_7_to_8(data: Dictionary) -> Dictionary:
func migrate_8_to_9(data: Dictionary) -> Dictionary:
func migrate_9_to_10(data: Dictionary) -> Dictionary:
func migrate_10_to_11(data: Dictionary) -> Dictionary:
func migrate_11_to_12(data: Dictionary) -> Dictionary:
func migrate_12_to_13(data: Dictionary) -> Dictionary:
func migrate_13_to_14(data: Dictionary) -> Dictionary:
func migrate_14_to_15(data: Dictionary) -> Dictionary:

```

`scripts/view/dog/dog_runtime.gd`:
```gdscript

func configure(main: Node) -> bool:
func is_busy() -> bool:
func can_play() -> bool:
func advance(delta: float) -> void:
func refresh_context() -> void:
func reset() -> bool:
func suspend() -> void:
func restore(raw: Variant) -> bool:

```

## Phase8.5f implemented API

﻿Step6/10 after8.5e pushed6c0fb32/full922. Main retains stable DogState and one LifeDogRuntime/DogActor2D under actual world.objects. DogNavigationContext snapshots actual owned land regions, MachinePlacementState.MACHINE_SIZE footprints and owned coop Resource footprint (placement occupancy is currently one cell irrespective of art). Static world water/buildings/farm use original Resource. Polls sparse sources at configured0.25s and immediately before adjacent arrival; navigation rebuild only on canonical change. DogMotionFlow quotes before pixels, rechecks on arrival then resets display from sole owner; stale/blocked arrivals cannot commit. Only newly covered origin uses bounded repair; one actor/two child display nodes reused. Lifecycle reconfigures existing visual references after silent owner reset, keeps name/cell display coherent.

Paused clock, all UiCoordinator modals including DebugMenu, sleeping/day-end and title stop advance; title hides and cancels route. New/load reset derived routes; actual owner publication prevents save/load/new/title reentry. No new collision/input/Player/camera/NPC/scene/save14 fields or economic mutation. Live dog not persisted until approvedg. Native walking/sprint feel and final art remain human F5 acceptance.

Import1 clean except inherited duplicate assetUID warnings. Focused1 3scripts/7/7/54assert/2.663s PASS; native1 same7/7/54assert/2.740s PASS, no errors/leaks. Real Main follow to far negative grid cells, hysteresis stop, pause/modal/title, stable cache, owned water/buildings/coop, actual machine place/move/remove and land grant, covered-origin/name preservation, stable owner/actor across lifecycle and publication reentry all verified. Existing tests and20real saves protected; full follows.

`scripts/view/dog/dog_runtime.gd`:
```gdscript

func configure(main: Node) -> bool:
func is_busy() -> bool:
func can_play() -> bool:
func advance(delta: float) -> void:
func refresh_context() -> void:
func reset() -> bool:
func suspend() -> void:

```

`scripts/view/dog/dog_navigation_context.gd`:
```gdscript

static func capture(main: Node) -> Array[Rect2i]:

```

`scripts/view/dog/dog_motion_flow.gd`:
```gdscript

func configure(actor: DogActor2D, service: DogMovementService, refresh: Callable) -> void:
func cancel() -> void:
func advance(delta: float, player: Vector2i, playing: bool) -> void:
func begin_step(target: Vector2i) -> bool:

```

## Phase8.5e implemented API

﻿Step5/10 after8.5d pushedc0cfe8f/full918. DogVisualProfile supplies shared ArtPalette cream/brown/outline/ground shadow, finite polygon geometry and cosmetic timing. Avatar owns only phase/facing; actor reads sole DogState, interpolates real IsometricGrid ground points and emits arrived without mutating domain. Exactly avatar+non-interactive name Label, no physics/input/3D. Actor is not spawned by Main until approvedf. configure/reset_position/begin_step/advance and set_unnamed_caption are the composition API; unnamed caption empty until localized UI integrationh. External Resource palette and shape arrays detached by frozen_copy.

Import1 clean except inherited duplicate artUID warnings. Focused1 2scripts/4/4/86assert/1.766s PASS, native1 1script/2/2/86assert/2.954s PASS. Native actual Main grid vi/en x1152/1280/1920 x5zooms rendered, six fresh PNGs archived; manually inspected vi1152 silhouette/ground/name/shadow. Ground invariant, pause pose/position freeze, no owner mutation, finite validator negative cases pass. No scene/InputMap/Player/assets/economy/day/RNG/save14 changes. Main spawn followsf; provisional art still needs human acceptance.

`scripts/data/dog_visual_profile.gd`:
```gdscript

func validation_errors() -> PackedStringArray:
func frozen_copy() -> DogVisualProfile:
func color(role: String) -> Color:

```

`scripts/view/dog/dog_avatar_2d.gd`:
```gdscript

func configure(profile: DogVisualProfile) -> bool:
func set_motion(walking: bool, direction: Vector2 = Vector2.ZERO) -> void:
func advance(delta: float, playing: bool = true) -> void:
func get_phase() -> float: return _phase

```

`scripts/view/dog/dog_actor_2d.gd`:
```gdscript

signal arrived(cell: Vector2i)
func configure(state: DogState, grid: IsometricGrid, config: DogConfig, profile: DogVisualProfile) -> bool:
func set_unnamed_caption(text: String) -> void:
func reset_position() -> void:
func begin_step(cell: Vector2i) -> bool:
func is_moving() -> bool: return _moving
func advance(delta: float, playing: bool = true) -> void:

```

`scripts/core/data_validator.gd`:
```gdscript

static func validate_dog_config(config: DogConfig) -> PackedStringArray:
static func validate_director_profile(profile: DirectorProfile, locales: Array[String]) -> PackedStringArray:
static func validate_director_debug_text(locales: Array[String], keys: PackedStringArray) -> PackedStringArray:
static func validate_director_activity(config: DirectorActivityConfig) -> PackedStringArray:
static func validate_ecology_feedback(config: EcologyFeedbackProfile, profile: EcologyProfile) -> PackedStringArray:
static func validate_ecology_journal(config: EcologyJournalConfig, profile: EcologyProfile, locales: Array[String]) -> PackedStringArray:
static func validate_ecology_sampling(config: EcologySamplingConfig, crops: Array[Resource]) -> PackedStringArray:
static func validate_ecology_profile(profile: EcologyProfile) -> PackedStringArray:
static func validate_scenery_catalog(catalog: SceneryArtCatalog) -> PackedStringArray:
static func validate_crop_stage_config(config: CropStageConfig) -> PackedStringArray:
static func validate_crop_economy(config: CropEconomyConfig, crops: Array[Resource], items: Array[Resource]) -> PackedStringArray:
static func validate_crop_migration(config: CropMigrationConfig, crops: Array[Resource]) -> PackedStringArray:
static func validate_inventory_config(config: InventoryConfig) -> PackedStringArray:
static func validate_machine_build_config(config: MachineBuildConfig, world: IsometricWorldConfig) -> PackedStringArray:
static func validate_watering_can_config(config: WateringCanConfig) -> PackedStringArray:
static func validate_bag_upgrade_config(config: BagUpgradeConfig) -> PackedStringArray:
static func validate_land_expansion_config(config: LandExpansionConfig) -> PackedStringArray:
static func validate_water_source_config(config: WaterSourceConfig, locations: WorldLocations, land: LandExpansionConfig) -> PackedStringArray:
static func validate_isometric_2d_assets(asset_root: String = "res://assets") -> PackedStringArray:
static func validate_isometric_world_config(config: IsometricWorldConfig) -> PackedStringArray:
static func validate_item_resources(resources: Array[Resource]) -> PackedStringArray:
static func validate_item_paths(paths: Array[String]) -> PackedStringArray:
static func validate_crop_references(crops: Array[Resource], items: Array[Resource]) -> PackedStringArray:
static func validate_crop_paths(crop_paths: Array[String], item_paths: Array[String]) -> PackedStringArray:
static func validate_translation_keys(paths: Array[String], required_keys: PackedStringArray) -> PackedStringArray:
static func validate_weather_profile(path: String) -> PackedStringArray:
static func validate_weather_resource(profile: WeatherProfile) -> PackedStringArray:
static func validate_art_palette_path(path: String) -> PackedStringArray:
static func validate_character_catalog_path(path: String) -> PackedStringArray:
static func validate_farming_art_catalog_path(path: String) -> PackedStringArray:
static func validate_world_art_catalog_path(path: String) -> PackedStringArray:
static func validate_item_visual_assets(resources: Array[Resource]) -> PackedStringArray:
static func validate_quest_resources(quests: Array[Resource], items: Array[Resource]) -> PackedStringArray:
static func validate_quest_paths(quest_paths: Array[String], item_paths: Array[String]) -> PackedStringArray:
static func validate_npc_world(data: NpcWorldData, items: Array[Resource], quests: Array[Resource], locale_paths: Array[String]) -> PackedStringArray:
static func validate_vietnamese_values(english_path: String, vietnamese_path: String) -> PackedStringArray:
static func validate_recipe_catalog(recipes: Array[Resource], machines: Array[Resource], items: Array[Resource]) -> PackedStringArray:
static func validate_recipe_economy(config: RecipeEconomyConfig, recipes: Array[Resource], machines: Array[Resource], items: Array[Resource]) -> PackedStringArray:
static func validate_dog_visual(profile: DogVisualProfile) -> PackedStringArray:

```

## Phase8.5d dog follow commands (D132)

DogFollowRules static distance(a,b),decide(config,navigation,origin,player,following=false)->{ok,mode,following,goal,path}|failure,nearest_walkable(config,navigation,desired)->{ok,cell}|failure. Deterministic Manhattan hysteresis/reachable goal, path includes origin. No state/Node/clock/RNG. DogMovementService.configure(config,state,navigation)->bool,is_busy(),plan(player,following=false),quote_step(target),step(quote),repair_invalid_origin(). Holds references/transient guard only; DogState remains sole serialized name/cell owner. Quote exact5fields ok/origin/target/owner_revision/navigation_revision, local Vector2i values, never persisted. Changed owner/nav/adjacency/blocked cells reject before mutation. Repair is only for current invalid cell; valid cells unchanged. Future motion flow interpolates but cannot commit stale arrival.

## Phase8.5c derived dog navigation (D131)

DogNavigation(RefCounted): configure(config,dynamic:Array[Rect2i]=[])->bool captures static DATA/builds once; set_dynamic_obstacles(regions)->bool,serialize()->Dictionary,deserialize(raw)->bool,get_revision()/get_rebuild_count()->int,is_walkable(cell)->bool,route(origin,target)->Array[Vector2i] includes origin,reachable(origin)->{ok,cells,distances}|failure. Full configured player_region, immutable WorldLocations solids always included, no diagonals. Equivalent dynamic context/JSON restore does not rebuild. Runtime should configure only lifecycle/static changes and use set_dynamic_obstacles for dirty dynamics; never reconfigure every frame.

DogNavigationCodec.rectangle(Rect2i)->Dictionary,from_regions(config,regions)->{ok,context}|failure,decode(config,raw)->same. Exact context{bounds:{x,y,w,h},dynamic:[{x,y,w,h}...]}, canonical clip/order/dedupe, strict integer/bounds/shape/overflow, Resource statics not overwritten. Context is derived, not game-save state. No Main/actor/input integration yet.

## Phase8.5b dog identity owner (D130)

DogState(RefCounted): configure(config:DogConfig,cell:Vector2i)->bool,serialize()->Dictionary,deserialize(raw:Dictionary)->bool,get_name()->String,get_cell()->Vector2i,get_revision()->int,is_busy()->bool,try_set_name(value:String,expected_revision:int=-1)->Dictionary,try_set_cell(cell:Vector2i,expected_revision:int=-1)->Dictionary. changed(cell:Vector2i,dog_name:String) publishes coherent committed state under mutation lock. Restore/configure silent; success increments transient revision. Queries detached; serialized fields exactlyname/cell_x/cell_y. Cell setter enforces bounds only; planned movement service alone validates navigation/adjacency.

DogNameRules.normalize(config,value:Variant,allow_empty=false)->{ok,name}|{ok:false,reason}. Reject control/line/format/replacement/noncharacter/surrogate scalars; no truncation/normalization of Vietnamese combining sequences. DogSnapshotCodec.decode(config,raw)->{ok,snapshot}|failure,integer(value)->bool for signed32exact nativeJSON cells, no Node/clock. No caller/runtime/save schema change until later approved steps.

## Phase8.5a Dog DATA foundation (D129)

DogConfig(Resource), data/dog_config.tres: world:IsometricWorldConfig,npc_world:NpcWorldData,name_max_length,follow_start_distance,follow_stop_distance,move_speed,context_interval,idle_wait_seconds,idle_radius,reaction_seconds. validation_errors()->PackedStringArray; frozen_copy()->DogConfig fully detaches DATA Resource graph with internal shared-reference memo. No owner/actor/UI yet. DataValidator.validate_dog_config(config)->PackedStringArray; null rejected. tools/validate_data always runs it; optional --dog-fixture=invalid-distance mutates only detached memory for negative CLI verification. Default CLI unchanged; localized UI key catalogues deferred-load after autoload startup. Scene contract dog.md reserves approved future API names; read current PROGRESS before treating them as implemented.

## Phase7.5k isolated verification tool (D128)

tools/sim_director.gd extends SceneTree, deferred CLI initialization, dynamic load of autoload-dependent real farm/services after actual autoload readiness. static run_scenario(days=1000,chunk_size=17,style="balanced",seed=731,checkpoint={},budget_days=0)->Dictionary restores prior clock/pause, writes no saves. Styles gardener/trader/balanced/inactive. Result ok/complete/days/target_days/stats/decision_sha256/actual final owners/checkpoint. Invalid arguments/envelope/codec/day/provenance fail explicitly. Budget must end on actual Resource season boundary unless final target; resume validates known style/seed/target/group/day and real v14 world codecs.

CLI --days/--chunk/--profile/--seed plus --budget=224 and --resume=<JSON verification checkpoint>. New checkpoint is a verification envelope, not game save schema. Large CLI JSON prints4096character [sim_director_json] chunks then [sim_director] PASS_CHUNKS <character_count>; join chunks exactly, validate length/JSON, persist only external verification checkpoint, resume until complete. This avoids existing PowerShell giant-line post-processing cost while retaining bounded180s child. External run_k_checkpoints.py in delivery batch implements complete four-profile/1000day chain with SHA. Standard tools/run_tests.bat unchanged. No new public gameplay API/owner/autoload/input or save migration.

## Phase7.5j player readouts (D127)

LifeDirectorSnapshot.capture(main)->Dictionary actual aligned committed pending/active/history/current charge_cost/dust_reason/effective gate. Invalid/busy/title returns okfalse; detached. LifeDirectorPresenter.KEYS/status/event_text/water_text/describe returns localized values; no selector/simulation/save. describe history is immutable decisions/planned dates, not execution log. LifeMorningDirectorStrip.display(snapshot) heading/summary/full tooltip, separate scene between ecology/tasks. MorningSnapshot.director and MorningPresenter delegate.

LifeDirectorHistory.display(snapshot) heading/current/water/note/records inside existing lazy LifeEcologySheet.scroll after metric rows. EcologyController coalesces Director/activity/weather signals; same Back/hide/reset drops branch. LifeHudWaterMeter.set_cost_detail(value) retains display(charges,capacity) and amount; HudPresenter queues actual current description after owners/locale, meter pointer PASS/child-ignore for native tooltip. Validation tool includes all new key names. Existing public commands and schemas unchanged.

## Phase7.5i debug modal (D126)

Main.director_debug_flow:LifeDirectorDebugFlow nullable (only constructed OS debug). configure(main),open()->bool,close(),reset(),set_enabled(value)->bool,queue_force(id)->bool,refresh(),queue_refresh(value=null); panel/model/result/busy. No new input. LifeDirectorDebugSnapshot.capture(main)->detached actual data, no EventDirector call. LifeDirectorDebugPresenter.translation_keys/reason/event_name/metric/trace_text/render; strict key-presence validation from tools/validate_data via DataValidator.validate_director_debug_text(locales,keys). Domain never imports UI.

LifeDirectorDebugSheet owns native toggle/clear/Close/Scroll and candidate rows, forwards requests only. LifeDirectorCandidateRow.display(view), forced(id). LifeDirectorTracePanel.display(title,body). LifeMachineHeader.director_button/director_requested forwarded by screen/controller deferred open; hidden in operations and outside debug. DebugMenu.register_action(label,callback,translation_key=&"") is backward-compatible, keyed action relocalizes. Shared coordinator includes debug modal; supported lifecycle clears stale panel. See contract and PROGRESS/full evidence.

## Phase7.5h Main runtime / save14 (D125)

Main owns director_activity:DirectorActivityState,director_state:DirectorState and six small nonvisual children documented in SCENE_CONTRACTS/director.md. Main._purchase_in_progress includes lifecycle/day/source/domain busy; normal save/load/NewGame/title/review and duplicate day calls cannot interleave command receipts. Existing one-argument injectable farm simulator kept; same Main morning handler reserves/seals/chooses after completed core/forecast before ledger/save/bulletin. No new clock listener/global producer subscriber.

DirectorActivityState compatible record_many(day,counts)->Dictionary atomically validates all known positive exact quantities before commit; record remains same API. mark_partial(day)->Dictionary marks only current open coverage unknown. begin_day(next)->{ok,token?},finish_day(token)->Dictionary,abort_day(token)->bool hold opaque identity through guarded local publication; advance_day delegates, existing wire5fields unchanged, tokens transient.

LifeDirectorRuntime(Node): configure(main),is_busy(),authorization_allowed(),capture_observation(internal=false),get_projection(force=false),prepare_restore(payload,new_game=false),begin_restore(prepared),finish_restore(),refresh_effects(),set_enabled(value),queue_force(id),invalidate(value=null); constants PROFILE/ACTIVITY. debug_preview_allowed can only restrict OS debug gate; story source false until real implementation. Read projections detached/cached transiently, no RNG/world mutation. Internal observation only after core owners agree during reserved morning. New game observes actual full initial day; legacy partial, silent same-identity restore.

LifeDirectorActivityCollector.begin_command(source)->{ok,token?},finish_command(token,counts,proven=true)->bool,cancel_command(token)->bool; busy/last_reason. Explicit registered source receipts only. LifeDirectorDailyFlow.begin(day),finish(day),abort(),busy. LifeDirectorWaterBridge.apply supplies fresh known terms; WateringRuntime.set_director_terms(terms)->bool,get_charge_cost()->int with old command APIs unchanged. ToolActionController/SeedShopPanel/ShippingBinPanel.configure_director(collector) attach optional adapter, standalone old consumers remain.

LifeDirectorNpcBridge.override()/apply; NpcSystem.refresh_director_schedule(); NpcSocialState.update_schedule(...,extra_visit:Dictionary={}),NpcSchedule.destination(...,extra_visit:Dictionary={}) retain old calls. Three-field known current-day merchant hint only extends existing entry weekday; original rain/night/hours/nav first. LifeDirectorEffectsFlow.refresh delegates existing bridges/ecology refresh. LifeEcologyCritter2D.set_director_accent(accent:Array) affects modulate only for eligible existing butterflies; old presentation snapshot shape unchanged.

SaveService.CURRENT_VERSION14,DIRECTOR_INTRODUCED_VERSION14; migrate_13_to_14(data)->Dictionary, pure paired normalization at actual saved day. Only two new root fields, actual golden14, old1..13 immutable. Source receipts for Minh use captured successful actual offer kind/quantity once; feed UI uses unchanged shop and original entry/lock before notifying, not count coop structure/debug grants. Contract/manual/current proof in PROGRESS.

## Phase7.5g paired persistence libraries (D124)

DirectorSaveContext.capture(profile:DirectorProfile,payload:Variant,crops:Array[Resource])->Dictionary; valid(profile,context)->bool. Uses shipped LAND/LEGACY/SAMPLING Resources and existing EcologySaveContext/Codec, WeatherSaveCodec. Success exact11fields{ok,reason,day_index,calendar,calendar_aligned,catalog_ids,weather,weather_available,ecology,available,regions}. Day defaults to existing origin0 only if absent, invalid explicit day rejected. Known typed actual crop catalogue/migration/garden/owned regions validated; calendar mismatch diagnostic cannot rewrite clock; unknown weather stays{} / availablefalse. Water clarity always unavailable. Context is transient, regions Rect2i; never a game-save field.

DirectorSaveCodec.normalize(profile,config:DirectorActivityConfig,activity:Variant,director:Variant,context:Dictionary,legacy:bool=false)->{ok,reason,used_fallback,director_activity,director}|failure. Strict valid pair at context day restores exactly; legacy explicitly ignores any untrusted future fields. Any bad/missing/mismatched member resets pair together at actual day to partial open activity/no closed history and defaultoff/no decision history, with diagnostic reason. Does not mutate unrelated root progress.

DirectorActivityLifecycle.baseline(config,day),resolve(config,raw,day),restore(state,config,raw,day) return explicit result/snapshot; standalone missing/mismatched observations begin partial, never reconstructed zeros. DirectorLifecycle.restore(activity_owner:DirectorActivityState,director_owner:DirectorState,profile,config,activity,director,context,legacy=false)->Dictionary prevalidates pair/configuration and busy guards before silent callback-free replacement. No signals/replay/RNG/time advancement/storage/Nodes. Callers retain same owner identities; Main/SaveService integration is following scope.

## Phase7.5f reversible effect terms and water costs (D123)

DirectorEffectProjector.project(profile:DirectorProfile,owner:Variant,observation:Dictionary)->Dictionary validates strict current-day owner/DTO and returns{ok,day_index,enabled,water:{day_index,event:{}|capturedDust},visitor:{}|{day_index,npc_id,location_id},accent:RGBA[]|[],event_ids:[],dust_reason}. Effective enabled requires actual caller story/debug authorization as well as saved gate. Rain/measured-canopy threshold waive dust extra; missing canopy is explicit unavailable/neutral. Open observation incompleteness affects future choice, not previously committed effects. Does not alter nodes/counts/stock/owners.

DirectorEffectTermsCodec.active(profile,raw,day)->{ok,event?|reason?}; water(config:WateringCanConfig,raw:Variant)->{ok,charge_cost,extra_charge,day_index,event_id}|failure. Water raw{} gives DATA basecost; otherwise exact{day_index,event}, known actually active dust terms only. Cost derived from captured DATA, supplied cost cannot override. WateringCanState.try_consume_charges(amount,expected_charges,expected_revision=-1),refund_charges(amount,expected_refill_revision=-1) are atomic checked integer primitives; existing try_consume_one/refund_one unchanged logical units. No save fields added.

WateringService.set_effect_terms(terms:Dictionary)->bool validates/copies transient terms (busy rejects); get_charge_cost()->int. configure resets projection for new refs; active command retains captured refs/cost. can_water quote adds charge_cost/refill_revision/terms_revision; water(cell,expected_quote:Dictionary={})->Dictionary keeps old single-argument API and optionally refuses stale quotes. Zero charges retains water_empty; positive but insufficient uses water_insufficient. Successful result adds charge_cost. Caller must supply fresh actual-day projection before live commands; runtime not wired in this slice.

## Phase7.5e Director owner and captured schedules (D122)

DirectorState(RefCounted): configure(profile,day)->bool; is_busy(),get_day_index(),is_enabled(); set_enabled(value:bool,authorized:bool=false)->bool; queue_force(id:StringName,authorized:bool=false)->bool; begin_day(day)->{ok,token?}; finish_day(token:RefCounted,snapshot:Dictionary={})->{ok,decision?,reason?}; abort_day(token)->bool; get_context(); serialize(); deserialize(raw:Dictionary)->bool. Local director_changed(day_index:int) emits after atomic validated commit with all mutation paths busy. Matching exact-next-day token only; invalid observation retains reservation, decline force consumes intent without lottery fallback. Restore/configure silent. Defaultoff may advance without observation and records explicit disabled/no-RNG; enabled requires actual validated matching-day/gate DTO. Disabling clears active/pending/force but keeps already booked conservative cooldown/quota and immutable past decisions.

DirectorSnapshotCodec.baseline(day),decode(profile,raw)->{ok,snapshot?|errors?}: strict13field wire, ordered bounded history, current/future schedules, known captured Resource terms, counter reservations, history cooldown/negative spacing/grace, no injected schedule. DirectorScheduleRules.valid_terms/advance/context/book are pure detached transformations (book mutates only caller-owned candidate), no RNG. DirectorHistoryRules.empty_decision/valid_decision/json_value/copy_json/append validate bounded primitives and preserve canonical signed-int64 RNG text. Candidate terms in this catalogue version must exactly match known DATA fields/day offsets; no reroll. StringName->String and integral JSON numeric normalization are exact, fractional values preserved.

## Phase7.5d seeded chooser (D121)

DirectorCandidateRules(RefCounted stateless): fresh_context(enabled_day:int)->Dictionary; valid_context(profile,day,raw)->bool; evaluate(profile,snapshot,context)->Dictionary. Context exactly enabled_day,last_positive_day,last_negative_start,cooldowns,season_usage,event_usage,scheduled. Scheduled rows exactly event_id,start_day,end_day,is_negative,mutex_group. Per-candidate actual exclusion reason/checks/conditions/base_weight/activity_bonus/score/start/end/target season. Partial/off DTO yields no score/draw; malformed ready context rejected. Positive pity removes negative pool and zeroes no-event weight only when positive eligible; otherwise waits.

EventDirector(RefCounted stateless): decide(profile:DirectorProfile,snapshot:Dictionary,context:Variant,force_id:StringName=&"")->Dictionary; event_terms(event,decision_day)->Dictionary. Result contains actual seed_used (or null), lossless signed-int64 rng_state string, chosen ID or empty, captured terms and detached trace. Force requires eligible ID, bypasses lottery only. No state/Node/clock/global RNG mutation. DetRandom.TAG_DIRECTOR=2; old mixer/TAG_WEATHER1/TAG_MERCHANT8 unchanged.

## Phase7.5c Director observations and conditions (D120)

DirectorSnapshot(RefCounted stateless), static capture(profile:DirectorProfile,clock:Variant,ecology:Variant,activity:Variant,weather:Variant,gates:Variant)->Dictionary. ACTIVITY preloads the actual director_activity_config.tres. Clock exactly4fields(day_index/minute/season/year), ecology exactly{state,available}, activity exact5field owner wire, weather current4field codec, gates exactly4bools{enabled,story_unlocked,debug_preview,busy}. Failure {ok:false,reason:StringName}; success carries ready/reason/day_index/world_seed/clock/calendar/metrics/available/activity/weather/merchant_regular and detached canonical source{clock,ecology,activity,weather,gates}. Partial activity is valid but readyfalse with no totals/frequencies; disabled/locked explicit. No real story flag is granted. valid(profile,snapshot)->bool rebuilds canonical source and compares exact values, tolerating only JSON integer/double and string/name representations, never bool/fraction/epsilon or forged derived fields.

DirectorSnapshot.calendar(profile,day:int)->Dictionary uses exact integer division/actual ordered SeasonData; returns {ok,season_id,start_day,end_day,year,ordinal}. Source clock must agree; captured windows require JSON-safe calendar/forecast headroom. Merchant weekday metadata uses existing typed schedule definitions and week length. ACTIVITY totals/frequencies use closed complete rows, active-day fraction per source over configured window; open day excluded. No Node/GameClock/registry/RNG mutation.

DirectorConditionRules(RefCounted stateless), static evaluate(profile:DirectorProfile,event:DirectorEventData,snapshot:Dictionary)->Dictionary {eligible:bool,reason:StringName,details:Array[Dictionary]}. Validates snapshot/event; incomplete/disabled/locked/invalid observations cannot pass. Conditions evaluate current measured metric min/below threshold, actual proposed-start saved weather (today or forecast[telegraph-1]), and whether an ordinary Minh visit already exists. Details contain kind/passed/reason primitives; no candidate weights/lottery/state or side effects yet.

## Phase7.5b Director DATA catalogue (D119)

DirectorConditionData(Resource): kind:StringName in metric_min/metric_below/dry_start/extra_visit; metric_id/threshold_id:StringName; validation_errors(ecology)->PackedStringArray, static threshold_matches(ecology,metric,threshold)->bool and text_key(key)->bool. Metric predicates require a known measured threshold, water_clarity is unavailable. DirectorEffectData(Resource): kind extra_water_charge/merchant_visit/butterfly_accent, extra_charge:int, exempt_metric_id/exempt_threshold_id, waive_rain:bool, npc_id/location_id, accent_color:Color; validation_errors(ecology,npcs), terms()->Dictionary of detached primitives/accent RGBA array. Actual merchant and existing schedule destination required; no executor.

DirectorEventData(Resource): id/mutex_group/title_key/explanation_key/counter_hint_key:StringName; tags/activity_affinities:PackedStringArray, conditions/effects:Array[Resource], weight:float, cooldown_days/max_per_season/telegraph_days/duration_days:int,is_negative:bool; validation_errors(ecology,npcs,weather), get_translation_keys(). Prototype exactly one typed effect; negative telegraph/cap/counter required, cooldown>=duration, positive affinities only actual activity IDs. Positive season cap0 means unlimited.

DirectorProfile(Resource): enabled:bool defaultfalse; grace_days/pity_days/max_negative_per_season/min_negative_gap/history_limit:int; no_event_weight/activity_bonus_max:float; ecology/weather/npc_world typed DATA refs, seasons/events:Array[Resource]. validation_errors(), get_event(id)->DirectorEventData nullable, get_translation_keys(), frozen_copy()->DirectorProfile. Complete spring/summer/autumn/winter order matches current clock; exactly three known event/effect bindings. Frozen copy explicitly duplicates all observation-relevant nested Resources/arrays/dictionaries. DataValidator.validate_director_profile(profile,locales)->PackedStringArray appends structural+both-locale-key gate to CLI. Shipped values/schema in DATA_SCHEMA. No EventDirector/DirectorState/runtime/save fields until later scopes.

## Phase7.5a director observation library (D118)

DirectorActivityConfig(Resource), scripts/data/director_activity_config.gd / data/director_activity_config.tres: window_days:int, activity_ids:PackedStringArray; validation_errors()->PackedStringArray and static valid_id(value:Variant)->bool. S14 range7-14, shipped7; complete six unique registered IDs plot_tilled/crop_planted/plot_watered/crop_harvested/item_purchased/item_sold. First three count actual successful actions, last three actual quantity; later collector is not implemented. DataValidator.validate_director_activity(config)->PackedStringArray is null-safe; CLI appends gate after all prior gates.

DirectorActivityState(RefCounted), scripts/domain/director/director_activity_state.gd: configure(config:DirectorActivityConfig,day:int,full_day:bool=false)->bool deep-freezes Resource and silently resets at explicit day; record(day:int,activity:StringName,quantity:int)->Dictionary; advance_day(next_day:int)->Dictionary; get_window_snapshot()->Dictionary; serialize()->Dictionary; deserialize(raw:Dictionary)->bool; is_busy()->bool. Commands return {ok,reason:StringName}, refused commands preserve state; only current-day positive quantities and exact next-day close. signal activity_changed(day_index:int) after atomic record/advance, busy through observer callbacks; configure/restore silent. Getters detached and safe during notification. No Nodes/autoload/clock/RNG or runtime subscriptions. Query {ok,day_index,window_days,observed_days,complete_days,available,totals}; unavailable totals={}, current open day excluded. Full window requires all configured consecutive completed observations complete. Initial configure safe default partial; configure(day,true) only for explicitly known whole-day observation.

DirectorActivityCodec pure stateless RefCounted: static decode(config:DirectorActivityConfig,raw:Variant)->Dictionary -> {ok:true,snapshot} or {ok:false,errors:PackedStringArray}; valid_integer(value:Variant)->bool accepts exact finite nonnegative JSON-safe int/float excluding bool; empty_counts(config)->Dictionary creates configured zeros (structural helper for a validated config). Strict5-field wire/3-field history rows and complete six-counter dictionaries; bounds/order/span/coverage/overflow validation before detached canonical int result. Exact schema in DATA_SCHEMA. MAX_JSON_INTEGER=9007199254740991 is a serialization guard. No game-save field/version migration or live Director yet.

## Phase7.4c isolated verification entry point (D117)

tools/sim_ecology.gd extends SceneTree; static run_scenario(days:int=1000,chunk_size:int=17)->Dictionary. Intended ONLY isolated CLI/GUT without a live Main. Temporarily snapshots/restores actual GameClock serialized state/pause; returns {ok,days,chunk_size,stats,crossings,snapshot,reference,farm,land,water_available:false} or {ok:false,reason:String}. Actual farm/simulator runtime Scripts load after autoload startup, avoiding pre-autoload Events compile errors. No save files/Main/world nodes/new owner/schema/RNG. CLI --days/--chunk positive ints, exit0 PASS/1 invalid or mismatch. Counters and invariants in DATA_SCHEMA; care/neglect/checkpoint grouping is verification input, not gameplay settings. New GUT test_ecology_simulation and test_ecology_end_to_end cover deterministic1000day and native complete lifecycle/read-only/modal/locale/capture paths. Existing public game APIs unchanged.

## Phase7.4b live bounded2D ecology flow (D116)

Main.ecology_effects_flow:LifeEcologyEffectsFlow is a child Node outside world, configure(main:Node,source:EcologyFeedbackProfile=PROFILE)->bool deep-freezes validated profile. refresh()->void captures actual current EcologySnapshot then pure selector, maps normalized anchors to deduplicated owned cells clipped to existing map, uses world.grid.cell_to_global and objects.to_local. Stable effect:index keys preserve roots; no-op refresh retains instance/phase. clear()->void frees owned roots; _exit_tree calls clear. get_presentation_snapshot()->Array[Dictionary] returns detached {key,id,cell,instance_id,global_position,phase:Vector2,opacity}. Dirty state/farm notifications coalesce next process; Resource refresh interval checks state/day/ownership for silent changes, no per-frame sampler. Unavailable/busy/title clears; Main successful restore/NewGame/title explicitly refresh. Existing clock/weather update cosmetic opacity only.

LifeEcologyCritter2D extends Node2D, configure(definition:Dictionary,start_phase:float)->void, advance(delta:float)->void, get_phase()->Vector2. Root has cell/effect_id metadata, no children/collision/input/own processing. Native _draw polygons/flight offset only, bounded wrapped phases; flow freezes on pause/sleep/held day-end. It inherits world tint; profile night/rain multipliers affect self_modulate alpha. Neither class serializes presentation or changes owners/RNG. Scene contracts document placement/cleanup/manual checks.

## Phase7.4a bounded ecology feedback data (D115)

EcologyFeedbackProfile(Resource): total_cap:int, refresh_seconds/night_sun_energy/night_opacity/rain_opacity:float, effects:Array[Dictionary]; validation_errors(ecology:EcologyProfile)->PackedStringArray. Bindings only butterflies->biodiversity/butterflies and birds->tree_cover/birds. Native polygon/motion/anchors definitions and bounds in DATA_SCHEMA. DataValidator.validate_ecology_feedback(config,profile) is null-safe, appended CLI gate preserves all prior validators.

EcologyFeedbackSelector pure RefCounted: static select(profile:EcologyFeedbackProfile,ecology:EcologyProfile,metrics:Variant,available:Variant)->Dictionary. Success {ok:true,effects:Array[Dictionary],total:int}; failure {ok:false,reason:StringName}, no partial output. Validates complete metrics/availability (water must be false); available current values >= configured threshold select detached definitions in Resource order. No owner/history/Node/RNG/state retention, no serialize needed. Runtime/geometry drawing not introduced yet.

## Phase7.3i morning ecology component (D114)

LifeMorningEcologyStrip extends PanelContainer, ecology_strip.tscn: display(snapshot:Dictionary)->void uses EcologyPresenter.describe. Typed heading/summary/water_label/water_value/counts/trees/species controls. Count tooltips show current garden target/ease/action hint. Invalid/busy/stale clears counts and shows waiting; water always unmeasured. MorningSnapshot.capture adds detached ecology field; MorningPresenter renders it and LifeMorningSheet owns strip between columns and tasks. Short labels use no-wrap/shrink to preserve native small-window fit. Existing APIs/flow/input/save unchanged.

## Phase7.3h native ecology journal controls (D113)

LifeQuestBook adds navigation:HBoxContainer, paper:VBoxContainer, body:HBoxContainer, ecology_button:Button and nullable ecology_sheet:LifeEcologySheet. Original tabs/filters/list/people/detail/hint APIs remain. Existing3enabled common-tab indices/4quest filters and journal modal unchanged. Ecology entry does not expand across header; tabs/Close retain space. No new input action.

LifeEcologySheet (ui/ecology/ecology_sheet.tscn/.gd, VBoxContainer) back_requested(); display(model:Dictionary); fields title/scope/waiting:Label, scroll:ScrollContainer, rows_column:VBoxContainer, metric_rows:Array[LifeEcologyMetricRow], back_button:Button. LifeEcologyMetricRow (metric_row scene pair, VBoxContainer) display(row:Dictionary), title/value:Label, bar:LifeProgressBar, summary:LifeEcologySourceSummary. Uses inherited native Range min/max/value with step0 for actual floats; generic set_displayed_value(int,int) remains unchanged. Unmeasured water bar hidden without numeric reads. LifeEcologySourceSummary (source_summary scene pair, VBoxContainer) labels:Dictionary, display(row)->void clears/hides absent source/target/ease/threshold/status/hint lines. All shared Theme, no per-node StyleBox overrides or gameplay ownership.

LifeEcologyController (Node) configure(panel:NpcPanel,main:Node), open/close/reset/queue_render()->void, is_open()->bool. Owned by existing LifeQuestBookController.ecology_controller. Explicit entry lazily creates sheet; Back/reset/close immediately detaches then queue_frees it, preserving no ProgressBar descendants in quest mode. Requires visible active journal/started idle game; deferred real state/farm/wallet/locale refresh, guarded focus and stale-hidden reset. No saved mode, global signals, world actions or polling simulation. Existing book_controller.reset/NpcPanel.show_quest_book reset transient ecology pane. Esc/QE/J/native button routing uses existing modal. Exact tree/manual checks in SCENE_CONTRACTS/ecology.md/quest_book.md; human acceptance separate.

## Phase7.3g read-only ecology presentation data (D112)

EcologyJournalConfig Resource exports texts:Dictionary and rows:Array[Dictionary]; validation_errors(profile:EcologyProfile)->PackedStringArray validates complete text set, unique known three metrics, exact count bindings and owned threshold references; get_translation_keys()->PackedStringArray detached. Shipped data/ecology_journal_config.tres maps actual metrics/counts/thresholds to localization keys, no gameplay numbers or state. DataValidator.validate_ecology_journal(config,profile,locales:Array[String])->PackedStringArray null-safe combines schema and translation key checks; CLI appends after all prior gates.

EcologySnapshot static capture(main:Node)->Dictionary; valid(snapshot:Dictionary)->bool. Success {ok:true,state:{day_index,metrics,triggered},sample:{ok,targets,counts,available},goals:{mature_fruit_trees:int,species:int}} comes only from actual owner/sampler/Resources. Busy/stale/missing/invalid context returns ok=false/reason, no fake fallback values. Validate complete finite metric sets, nonnegative integer counts/positive goals, exact availability (water alwaysfalse), logical count bounds. Capture/formatter never owns or changes domain state, clock/RNG/save.

EcologyPresenter static describe(snapshot:Dictionary,config:EcologyJournalConfig=CONFIG)->Dictionary formats detached title/scope/back/news/rows for UI. Measured rows include actual value/minimum/maximum, target/source/ease/threshold/status/hint text and active side from actual profile. Unmeasured water row has label/hint/value_text only, no numeric value/max/target/source/threshold/active fields. Invalid data yields localized waiting message, invalid config gives explicit failure. text(config,field)->String resolves validated Resource key through TranslationServer. 25vi/en keys are draft product copy awaiting human tone acceptance; no visible UI until7.3h.

## Phase7.3f reserved daily ecology (D111)

EcologyState adds day_quote(day:int)->Dictionary{ok,reason}, begin_day(day:int)->Dictionary{ok,token?}, finish_day(token:int,targets:Dictionary)->Dictionary, abort_day(token:int)->bool. Quote requires configured adjacent JSON-safe day and idle owner; begin holds owner-scoped monotonic transient token. configure/deserialize/direct advance/new reservation reject while reserved or publishing. serialize/getters expose only committed wire, never token. Wrong token leaves lock/state; invalid finish targets retain reservation for retry/abort; successful finish delegates existing atomic ease/signals once. Tokens remain monotonic across same-owner configure/load, no replay from serialization. is_busy includes reserved/publication states; original unreserved methods remain compatible.

DaySimulator.simulate_day(farm_state,coop=null,machines=null,completed_day=-1,farm_step=Callable(),ecology_step:Callable=Callable())->void now appends optional zero-argument ecology callback after farm/animal/machine work. LifeEcologyRuntime adds begin_day(day:int,farm:FarmGridState,land:LandOwnershipState)->Dictionary, finish_day(day:int,farm:FarmGridState)->Dictionary, abort_day()->bool. Begin preflights and freezes config/primitive CropData sampling fields/owned regions before callbacks, then reserves owner; finish samples actual completed farm and commits held day, clears transient copies on success; failed late finish retains lock for explicit diagnosis. Main moves existing mark_out_of_season into farm-step completion, runs ecology before weather finish/ledger/autosave/bulletin; duplicate/stale/skipped callbacks change no owners. Application lifecycle commands stay guarded; direct clock-first adapter policy remains unchanged. Save13 wire unchanged. Float precision limits/tests in DATA_SCHEMA/PROGRESS.

## Phase7.3e Main/save13 integration (D110)

Main.ecology_state:EcologyState is the sole ecology owner; ecology_runtime:LifeEcologyRuntime is a small RefCounted view adapter (no new Node/autoload). LifeEcologyRuntime configure(state:EcologyState,day:int)->bool; prepare(payload:Dictionary)->Dictionary; begin_restore(payload)->Dictionary; finish_restore(day:int,farm:FarmGridState,land:LandOwnershipState)->bool; busy:bool and last_restore_reason:StringName are transient diagnostics/guard. Begin validates entire canonical context/candidate before live mutations and holds Main lifecycle commands through callbacks; finish uses actual restored clock/farm/land and silently restores the same state owner. Main private land lifecycle adapter reuses existing public close/deserialize/refresh_land under that lock. No direct saved runtime flags or UI.

SaveService.CURRENT_VERSION=13; new migrate_12_to_13(data:Dictionary)->Dictionary calibrates legacy garden and discards unknown pre13 ecology history; migration input is detached. save_game adds canonical ecology and full_precision JSON; malformed context returnsfalse/invalid_ecology_context without writing. Current13 valid matching-day metrics/history retain exact values, corrupt/mismatched component explicitly calibrates; failed read context retains ecology{} as explicit runtime-fallback marker, rejected by Main preflight. Existing methods/slots/backup/recovery/weather/water/coop APIs remain. No daily ecology callback until7.3f. Exact wire/limits in DATA_SCHEMA/SCENE_CONTRACTS/ecology.md; old tests change only approved40line version patch.

## Phase7.3d independent ecology component codecs (D109)

EcologySaveContext pure RefCounted static capture(payload:Variant,crops:Array[Resource],land:LandExpansionConfig,legacy:CropMigrationConfig)->Dictionary. Success {ok:true,reason:captured,farm:Dictionary,regions:Array[Rect2i]}; failure {ok:false,reason}. Validates catalog/land/migration before delegating FarmSaveCodec.decode/encode and temporary LandOwnershipState. Missing components normalize as existing owners do; malformed farm arrays/unsafe withered counter casts fail. Raw payload, goldens and existing owners are untouched. No Node/autoload/clock/RNG/filesystem.

EcologySaveCodec pure RefCounted static normalize(profile:EcologyProfile,config:EcologySamplingConfig,raw:Variant,day:int,crops:Array[Resource],context:Dictionary)->Dictionary. Validates success/typed regions shape, then EcologyLifecycle.resolve. Success snapshot remains existing {day_index,metrics,triggered}; reason/sample are transient diagnostics, never extra saved fields. Valid exact matching-day values/history preserve; missing/corrupt/mismatched component calibrates current garden with explicit reason, empty history/unavailable water. Invalid context/profile/day returns failure without partial snapshot or mutation. This step does not call SaveService/Main or bump12;7.3e integrates separately.

## Phase7.3c ecology lifecycle library (D108)

EcologyLifecycle, pure stateless RefCounted: static calibrate(profile:EcologyProfile,config:EcologySamplingConfig,farm:Variant,crops:Array[Resource],regions:Array[Rect2i],day:int)->Dictionary; resolve(profile,config,raw:Variant,day,farm,crops,regions)->Dictionary; restore(state:EcologyState,profile,config,raw,day,farm,crops,regions)->Dictionary; advance(state,config,day,farm,crops,regions)->Dictionary. Success contains ok/reason/snapshot/sample; failure ok=false/reason/detail. Calibrate initializes a temporary validated candidate then seeds current tree/species targets at loaded day, empty history, configured initial water unavailable. Resolve preserves valid matching-day state exactly; otherwise explicit calibrated_missing_or_invalid or calibrated_day_mismatch reason. Invalid context/profile/day fails without owner change. Restore validates entire candidate before silent configure/deserialize of caller's sole state; refuses busy owner. Advance samples actual context then existing adjacent-day ease/notifications; rejects duplicate/skipped/reentrant calls. No retained state, serialization or Main/save hook; pure functions require explicit inputs. Water availability stays false. Tests/status in PROGRESS.

## Phase7.3b stateless farm sampling (D107)

EcologySamplingConfig Resource (scripts/data/ecology_sampling_config.gd) exports mature_tree_goal:int, species_goal:int, fruit_tree_ids:PackedStringArray, species_aliases:Dictionary. validation_errors(crops:Array[Resource])->PackedStringArray validates positive int32 goals, nonempty unique valid CropData catalog/growth, known unique perennial repeat fruit IDs and terminal known species aliases (no self/chain/cycle). Goals8/8, orange/apple/banana and six legacy aliases live in data/ecology_sampling_config.tres. DataValidator.validate_ecology_sampling(config:EcologySamplingConfig,crops:Array[Resource])->PackedStringArray is null-safe; CLI appends this gate after all previous validation.

EcologySampler (scripts/domain/ecology/ecology_sampler.gd), pure stateless RefCounted: static sample(config:EcologySamplingConfig,farm_snapshot:Variant,crops:Array[Resource],owned_regions:Array[Rect2i],current_metrics:Dictionary)->Dictionary. Success {ok:true,targets:{tree_cover:float,biodiversity:float,water_clarity:float},counts:{mature_fruit_trees:int,healthy_plants:int,species:int},available:{tree_cover:true,biodiversity:true,water_clarity:false}}. Failure {ok:false,reason:String}, with no partial targets/counts. Binds shipped ecology_profile.tres for complete current-metric range validation; no new profile/baseline is invented. Farm input is FarmGridState.serialize() {plots:Array[Dictionary]}, not cell-keyed internal plots. Exact row fields, supported JSON integral numbers, ownership/counter/duplicate rules are in DATA_SCHEMA. Empty owned_regions means no owned cells; overlapping regions never duplicate counts. Sampling validates all rows, including unowned ones, then filters living owned crops. Counts and targets are detached primitives, no owner setters/events/RNG/autoload/Nodes. Pure sampler requires neither serialize nor deserialize because it retains no state. Water target always holds current valid value and is explicitly unavailable. No Main/DaySimulator/UI/save runtime consumer yet.

## Phase7.3a standalone ecology contract (D106)

EcologyMetricData static valid_id(value:Variant)->bool validates ASCII snake_case; number(value:Variant)->bool accepts finite int/float, excludes bool. EcologyMetricData (Resource) fields metric_id:StringName, minimum/maximum/initial_value/ease_percent:float, thresholds:Array[Dictionary] (id:String/StringName,value:finite number); validation_errors()->PackedStringArray. PERCENT_SCALE100 is unit conversion, actual limits/initial/ease/thresholds are in data/ecology_profile.tres. EcologyProfile metrics:Array[Resource]; validation_errors(), get_metric(id:StringName)->EcologyMetricData, get_thresholds()->Array[Dictionary] returns detached canonical metric_id/id/value rows. Reject empty/wrong-class/duplicate metric/threshold IDs before using fields.

EcologySnapshotCodec (pure RefCounted) static decode(profile:EcologyProfile,raw:Variant)->Dictionary{ok,snapshot?,errors?}; decode_metrics(profile,raw)->{ok,metrics?,errors?}; valid_day(value:Variant)->bool. Day must be an exact JSON-safe nonnegative integer; bool/string/fraction/nonfinite reject. Snapshot canonical day_index:int, metrics:Dictionary[String,float], triggered:Array[String] in profile threshold order; exact known metric set/ranges, known unique triggered IDs. Extra top-level metadata is dropped, no aliases or Resource/Node output. History is validated, not inferred/rewarded from metric levels.

EcologyState (pure RefCounted) configure(profile:EcologyProfile,start_day:int=0)->bool; advance_day(day:int,targets:Dictionary)->Dictionary{ok,reason,snapshot?}; serialize()->Dictionary; deserialize(raw:Dictionary)->bool; get_metrics()->Dictionary; get_triggered()->PackedStringArray; is_threshold_active(id:StringName)->bool; get_day_index()->int; is_busy()->bool. Fresh instance is unconfigured/serializes{}. Configure validates/deep-copies each metric/threshold, initializes without signals. Advance accepts only next adjacent exact day and complete finite in-range targets, eases each metric by its data percentage; commits whole state then ecology_changed(metrics:Dictionary) only if values changed, followed by threshold_crossed(threshold_id:StringName) in profile order for any side transition. Upward IDs enter persistent triggered set; downward never erases history. Busy spans preparation/publication, rejects mutation reentry while reads see committed detached state. Deserialize validates before commit and stays silent; invalid input keeps prior state. Ordinary signal arguments are detached from owner; receivers should read owner for their own fresh snapshot rather than trust another receiver's modified argument.

DataValidator.validate_ecology_profile(profile:EcologyProfile)->PackedStringArray null-safe delegates; CLI appends this after every previous gate. No runtime instance/Global Events hook/new save fields, or world counter/weight/target inference yet. Status/tests in PROGRESS; standalone wire in DATA_SCHEMA.

## Phase7.2c actual ambient/music runtime (D105)

AmbientAudioContext (scripts/view/ambient_audio_context.gd) static select(profile:AmbientAudioProfile,cell:Vector2i,minute:int,rainy:bool)->Dictionary yields detached zone/ambience/music; validates data, chooses rain>night>regionalday, morning/afternoon music or empty atnight. Cosmetic only, no clock/Node/autoload dependency.

LifeAmbientAudioFlow (scripts/view/ambient_audio_flow.gd) Node API configure(main:Node,source:AmbientAudioProfile=DEFAULT_PROFILE)->bool; get_playback_snapshot()->Dictionary. Main.ambient_audio_flow owns it; contract defines fixed four AudioStreamPlayer children. Deep-copied profile, one typed clock/weather listener, coalesced context and logicalcell polling, bounded per-layer crossfade, cloned loop WAVs and title/exit silence. Local gains contain only profile/fade; accepted gains stay in existing bus router. Pause audio continues for settings preview. Snapshot is detached native diagnostics, not game/save/UI state. Main adds only field/creation/configure; all transaction/simulation/restore logic remains. See SCENE_CONTRACTS/audio.md and PROGRESS.

## Phase7.2b original loop profile (D104)

AmbientAudioProfile (scripts/data/ambient_audio_profile.gd; data/ambient_audio_profile.tres) exposes validation_errors()->PackedStringArray and get_track(id:StringName)->Dictionary (detached). Tracks contain id/path/bus/gain/seconds, zones contain zone/region; day_by_zone plus night/rain/morning/afternoon references define actual audio selection inputs for7.2c. mix_rate/fade_seconds/day_start/afternoon_start/night_start are presentation data. Eight WAV placeholders generated offline by tools/build_ambient_audio.gd (--output required); no runtime loader/caller until7.2c. PCM/import/determinism checks in test_ambient_audio_assets; no DataRegistry/state/save ownership. Full fields, bounds and manual command in SCENE_CONTRACTS/audio.md.

## Phase7.2a audio routing (D103)

LifeAudioBusRouter (scripts/core/audio_bus_router.gd), transient core RefCounted: static is_layout_ready()->bool validates Master at0 and required child sends toMaster; apply_accepted()->bool reads accepted Settings, validates first, sets Music music gain, Ambience/UI effects gain and SFX unity, leaves Master unchanged. Missing/misrouted bus returnsfalse without gain writes. AudioService retains one listener and existing API/child-player behavior, owns a router and routes effects toSFX (fallbackMaster if unavailable). Active/new effects still use their own accepted effects_volume exactly once. default_bus_layout.tres is the native five-bus resource. Contract: SCENE_CONTRACTS/audio.md. No music/ambience playback until7.2c.

## AUDIT-F16 runtime dialogue adapter (D102)

NpcPanel.enable_dialogue(main:Node,system:NpcSystem)->void creates only the dialogue branch's LifeDialogueScreen/Controller. show_dialogue(snapshot:Dictionary)->void maps existing column/title_label/close_button onto real choices/speaker-name/stable Close; retained show_content and standalone legacy fields remain available. Journal/quest-book branch is unchanged. Main/NpcDialogue remains the existing root, with no existing .tscn changes.

LifeDialogueController is transient VIEW RefCounted, with configure(main,system,panel), displayed(snapshot), request(id:StringName)->bool, is_busy()->bool, queue_render(_slots:Array[Dictionary]=[])->void. It validates the current active visible nearby NPC, game/modal/clock/transaction context, displayed-vs-fresh npc/dialogue/quest IDs and the fresh action's enabled flag. Reentry is denied during dispatch; true means dispatched, not domain success. Hidden identities and deferred render epochs are invalidated; inventory/locale/social/schedule updates coalesce into read-only refreshes. No domain state or serialized owner is added.

NpcSystem adds get_dialogue_snapshot()->Dictionary, refresh_dialogue()->void, is_dialogue_context_valid()->bool, is_dialogue_busy()->bool, request_dialogue_action(id:StringName)->bool, execute_dialogue_action(id:StringName,quest_id:StringName)->void. Execute only routes from the active busy controller, rejects nested routing, and calls the original accept/deliver/trade handlers; existing domain services own results, items, money and ledger. UiCoordinator still owns modality, blocks shortcuts while dispatching and places actual HUD toast stack below dialogue to prevent covering text (restores82 elsewhere). UiLayout applies the wide viewport-bounded dialogue rectangle and preserves component styles; Screen reserves one pixel at the bottom during fractional scaled transitions. Contract: SCENE_CONTRACTS/dialogue.md and npc_navigation.md. Native old NPC/book/components plus4new runtime cases are verified in PROGRESS; no raw1–3 shortcuts or new InputMap.

## AUDIT-F15 standalone dialogue presentation (D101)

LifeDialogueSnapshot (VIEW RefCounted) static build(state:NpcSocialState,inventory:InventoryState,npc_id:StringName,day:int,season:StringName)->Dictionary reads registered actual NPC/dialogue/quest/offer/possession/friendship. Missing context returns{}. Result keys npc_id/name/color/body/details/friendship/friendship_max/quest_id/dialogue_id/actions; actions contain only id/text/enabled, never transaction callbacks. It never talks/accepts/delivers/trades or mutates owners; merchant selection is the existing stateless tagged day-seed function. Unknown roles/hearts/XP/story/options are not invented.

LifeDialogueScreen (new Control scene) exposes speaker:LifeDialogueSpeaker,body:LifeDialogueBody,choices:LifeDialogueChoices,close_button:Button; display(snapshot:Dictionary)->void, requested(id:StringName),closed(). Portrait/name left, actual choices right, scrollable dialogue/details and exact friendship at bottom. Speaker uses existing LifeCharacterPortrait.display_npc with registered ID/color. Body extends existing LifeHudFrame, text/details scroll and friendship stays fixed. Choices has stable close_button,revision:int, display(actions:Array[Dictionary])->void, requested/closed; direct action-button children preserve AcceptQuest/DeliverQuest/ConfirmOffer. Revision/visibility/enabled predicates reject stale/disabled requests but execute no command. Screen listens to its resize and deferred minimum changes to avoid stale large body height. Full tree and public fields in SCENE_CONTRACTS/dialogue.md. Four new root-only .tscn construct native nodes/signals in code; no existing runtime callers untilF16.

## AUDIT-F14 live accepted SFX gain (D100)

AudioService keeps play_sound/get_sound_path and the same four hoe/seed/water/harvest assets. _ready connects Settings.preferences_changed once; accepted changes update all current AudioStreamPlayer children through volume_linear. New players read the same accepted effects volume. Zero reaches exact mute instead of the old0.001 floor. The handler reads Settings, not a potentially modified detached signal argument. Finished-player cleanup is unchanged, freed receiver connections are automatically removed. No music/ambience/bus/autoload/asset/gameplay additions; volume_linear was verified on the pinned engine before implementation.

## AUDIT-F13 accepted preferences and transactional Apply (D99)

Settings keeps its existing getters/void setters, adds get_preferences()->Dictionary (fresh supported values), apply_preferences(patch:Dictionary)->Dictionary and typed preferences_changed(values:Dictionary). Result {ok,error}, plus accepted values/write_report on success or write_report on persistence failure. Unknown patch keys, bad types/nonfinite/out-ofrange values, unsupported locale and reentry are rejected before publication. Supported values: music_volume/effects_volume finite0..1, locale vi/en, tutorial_dismissed bool. A successful apply clones valid config, persists once, replaces accepted _config, publishes requested locale, then emits detached values only if supported values changed. Failure leaves accepted runtime/locale unchanged; the write report carries storage rollback/recovery details. Explicit unchanged Apply still persists but emits no value-change event. Legacy finite volume setters retain clamping; volume/tutorial-only patches do not switch the current TranslationServer locale. Full title/pause drafts include locale and use one apply result; failed apply shows PREFERENCES_APPLY_FAILED.

SettingsCodec is a stateless DOMAIN RefCounted: defaults()->Dictionary, decode(raw:Dictionary,strict:bool=false)->{ok,values,errors}. Load mode clamps finite numbers, defaults invalid supported types/locale; strict draft mode rejects them. No file/Node/locale mutation. Unknown config keys are preserved by the core ConfigFile clone, not returned as supported preferences. Settings._ready normalizes memory and locale without rewriting the loaded file; missing/malformed CFG uses defaults. Godot ConfigFile itself logs syntax errors, retained in the separate malformed-file probe evidence.

SettingsFileStore core RefCounted has backend:SaveFileStore (replaceable test adapter), persist(path:String,text:String)->Dictionary via SaveWriteTransaction count0. Single-file staging/rollback guarantees and recovery limits are inherited fromF11; no world save/bus/autoload addition. ConfigFile.encode_to_text/parse and future AudioStreamPlayer.volume_linear were verified by native reflection on the pinned binary before use.

## AUDIT-F12 truthful save/recovery presentation (D98)

LifeSaveNotice (ui/components/save_notice.gd/new.tscn) is a passive PanelContainer: label:Label, presentation_enabled:bool, display(report:Dictionary)->void, static message(report:Dictionary,include_primary:bool=false)->String. It keeps a detached report and translates only source/error codes; source1..3 must be a finite integer, no internal paths appear. Empty/missing/primary(default static) produce no error message. The instance can display a primary source caption. Translation notifications re-render without I/O; presentation_enabled keeps title-only notices hidden in other modes. Uses existing Theme with native inset margins.

LifeTitleScreen.notice:LifeSaveNotice and display_save_report(report:Dictionary)->void add localized source feedback, visible only in TITLE. TitlePresenter.refresh uses inspect_latest rather than actual load, so refresh cannot publish/overwrite the actual-load report. Continue revalidation remains. Main.get_load_feedback()->Dictionary returns a deep copy of its latest request feedback, cleared before blocked loads; only completed restore publishes a success report. Private _load_payload now returns bool (restore order unchanged). Continue shows one recovered toast after successful restore/title closure. PausePresenter.notice replaces the generic status region only for actual recovery/error feedback from the callback owner; generic callbacks/primary/missing/blocked retain existing result keys. Capture report before summary refresh. No extra pause-load toast, new modal, world/save ownership, or schema change.

## AUDIT-F11 checked save publication (D97)

SaveService.save_game(payload,slot)->bool keeps its wrapper/schema and safe caller API, now delegates bytes to SaveWriteTransaction. get_write_report()->Dictionary returns a deep copy of {ok,error,committed,rollback_ok,cleanup_pending,recovery_paths}. Invalid slot returns false/invalid_slot; concurrent reentry returns false without replacing an in-flight report. I/O failure warns with context; committed cleanup-pending also warns. No report is persisted.

SaveFileStore (core RefCounted): ensure_parent(path:String)->bool, exists(path:String)->bool, read_bytes(path:String)->{ok,bytes}, write_bytes(path:String,bytes:PackedByteArray)->bool, rename_file(source:String,target:String)->bool, remove_file(path:String)->bool, staging_prefix(path:String)->String. Write checks position/error after store/flush; close has no error return, so reopen/readback compares bytes. Rename refuses to overwrite an existing target. Adapter can be replaced by a test store; no Node references.

SaveWriteTransaction.static write(store:SaveFileStore,path:String,bytes:PackedByteArray,backup_count:int)->Dictionary stages restorable copies plus desired family before moving any original. Read history in primary/bak1..N order, keep the newest N existing entries as backup1..N (holes compacted; missing primary retains existing history). Unique-prefix .new*.tmp/.old*/.moved* files are checked for collisions, never overwritten. Publish via rename, retain original copies until all family paths commit. On failure roll touched paths back; rollback failure leaves recovery copies listed explicitly. Cleanup failures after commit return ok=true/committed=true/cleanup_pending=true; the new family is already published. rollback_ok=true means no rollback was needed or all touched paths restored. No multi-file power-loss guarantee.

## AUDIT-F10 read-only save resolution (D96)

SaveService.load_game(slot=1)->Dictionary and load_latest()->Dictionary preserve their payload APIs, now publish transient detached load reports. inspect_slot(slot=1)->{payload,report} and inspect_latest()->{payload,report} do the same reads/validation/migrations without publishing; has_save/get_latest_summary use these inspection APIs. get_load_report(slot=-1)->Dictionary returns a deep copy of last actual load for negative/default, or the recorded actual load for the specified slot. Report fields: slot:int,status:StringName(primary/recovered/missing/error),error:StringName,source_index:int(0primary/1..3backup/-1none),attempts:Array[Dictionary] with source_index/error. Inspection never changes actual-load reports.

SaveLoadResolver (core RefCounted) exposes static resolve(path:String,current_version:int,migrate:Callable,backup_count:int,reader:Callable=Callable())->Dictionary; caller supplies the backup count/migration, no autoload reference. Optional reader(path)->{exists,ok,text} supports deterministic I/O-fault tests; default read_file(path)->Dictionary uses FileAccess only. Each candidate uses the same JSON parse, SaveEnvelopeCodec and migration path. Existing corrupt/unreadable primary falls back in ascending backup order. Missing primary stops, preserving delete_save semantics. A future-version primary stops fallback for that slot; a future backup is skipped when looking for an older supported backup. No load/inspection writes files. Latest retains slots0/1 and timestamp/subsecond/day tie policy; error-only inspection prefers future-version feedback when nothing loads. All migrations and wirev12 stay unchanged.

## AUDIT-F9 SaveEnvelopeCodec (D95; standalone)

scripts/domain/save_envelope_codec.gd: stateless RefCounted. static decode(raw:Variant,current_version:int)->Dictionary returns {ok:bool,error:StringName,version:int,data:Dictionary}. Success data is a deep copy without migration/component repair. Missing meta/version means legacy0. Accept only nonnegative exact JSON integers (int or finite integral float), at most9007199254740991. Invalid root/meta/version/current boundary have distinct invalid_* codes; supported-shape future versions return unsupported_future and their version. Failure data is{}. This validates only the envelope, not every gameplay component. No runtime caller untilF10; all old migrations/goldens stay unchanged.

## AUDIT-F8 three sequential graphics groups (D94)

run_graphics_tests.ps1 retains Get-GraphicsInventory/Assert-GraphicsCoverage/Read-GraphicsSummary and adds Get-GraphicsGroups(Inventory)->three nested arrays. Sorted inventory is assigned round-robin index%3, with no empty group. Normal invocation always runs all three groups sequentially,180000ms each; manifest keeps all inventory hashes and nested groups, summary aggregates exact script/test/assert counts. Error/count/pending/leak/source-hash gates remain. tools/tests/test_graphics_runner.ps1 loads real function ASTs and exercises disposable-replica orchestration; no production bypass/test-mode switch is added.

## AUDIT-F7 engine gate (D93)

tools/engine_pin.ps1 exposes Test-PinnedEngineVersion(Version)->bool and Assert-PinnedGodotEngine(Godot,OutputPrefix,TimeoutMs=10000)->string (throws on failure). The bounded launcher checks the pinned stable version using a hidden bounded --version process before any requested target, including direct invocations. Probe stdout/stderr are retained at OutputPath.pin.*. GODOT may select another executable only if it satisfies the pin. check_parse.bat aborts at a failed version gate. Native test command: powershell -NoProfile -ExecutionPolicy Bypass -File tools/tests/test_engine_pin.ps1. No game API/input/state/save change.

## AUDIT-F6 supplied tall objects (D92; automation 625/625 verified)

SuppliedSceneryView.create_tall(entry:Dictionary,cell:Vector2i,index:int)->Node2D is the view factory for the preserved compatible Tree_i adapter with Visual child; returnsnull if texture configuration fails. WorldPresentation remains the coordinator (244lines), helper owns construction.
WorldPresentation keeps each legacy Tree_i PlaceholderWorld2D/cell anchor/count for eligible C3placements, with metadata passive_tree=true,asset_id and one Visual:SuppliedSceneryView child at localzero containing Sprite2D. Tall IDs alternate in catalogue order. Wrapper deliberately stays outside scattered scenery_kind metadata, so existing scatter consumers/order remain compatible; all presentation still shares the same helper. No public API rename/scene/physics/state. `_refresh_decor` additionally toggles only tall wrapper visibility against actual occupation; roots stay and return when free, no model/actor/crop removed. Native PNG colors stay, global WorldTint supplies time/weather lighting; season/locale do not mutate imported texture data. Generated house/shop/bin/Player/crop artwork unchanged. Actual root/sort/native capture and owner/save tests in PROGRESS.

The adapter retains kind/color for the unchanged C3season consumer; self_modulate alpha0 hides only its procedural drawing, child art stays opaque. Empty compiled config fails closed before tall selection.

## AUDIT-F5 supplied small scenery runtime (D91; automation 621/621 verified)

SuppliedSceneryView (scripts/view/supplied_scenery_view.gd) extends Node2D; configure(entry:Dictionary)->bool creates/reuses one Sprite2D (public sprite), sets native texture/nearest/position=-pivot*scale and asset_id/scenery_kind/scenery_size/variant metadata. Invalid/missing texture or geometry hides/clears it and returnsfalse. It creates no input/physics/process/state owner. Caller supplies ground cell origin and owns any existing physics.
WorldPresentation compiles SceneryArtCatalog once, selects same old rock/grass or optional new small decor, calls view helper and retains large-rock collision function unchanged. refresh_land public API/anchors/tree/locale/season behavior stay. Small-decor-only deferred reconciliation observes plot_changed, appearance/restore and same-region refresh; prevents view duplication and restores derived cells after plots clear. Additional exclusions use actual farm plots, complete2x2machine footprints, Player cell, NpcSocialState.cells/paths, plus existing static reserves. No world simulation/RNG/save data or API rename. Source selector's12-of18legacy output and all9new decor recorded separately; all29textures are supported by configure, tall objects remain for F6.

## AUDIT-F4 scenery data contract (D90; automation 616/616 verified)

SceneryArtCatalog (scripts/data/scenery_art_catalog.gd; data/art/world/isometric_scenery_catalog.tres) exports29canonical entries and five cosmetic bands. Entry: id/kind/size:StringName, variant:int, path:String, image_size:Vector2i, pivot/scale:Vector2, blocks:bool. required_ids()->PackedStringArray is the supplied schema; validation_errors()->PackedStringArray pure validates complete membership, canonical metadata, image geometry, large-rock-only blocking, numeric safe hash/bands and fixed size/tall order. get_entry(id:StringName)->Dictionary returns a deep copy, or{}.
SceneryPlacementRules is pure stateless RefCounted: compile(catalog:SceneryArtCatalog)->Dictionary returns{} on invalid, otherwise detached entries/groups/bands/hash/size terms for hot-path use; cell_hash(config:Dictionary,cell:Vector2i,offset:Vector2i=ZERO)->int uses int64 components before offset, returns-1 for unsafe/missing hash terms; select(config:Dictionary,cell:Vector2i,include_decor:bool=false)->Dictionary returns detached entry or{}. Default preserves legacy rock/grass choices. true adds flower/pebble/tuft only from remaining buckets; object IDs are explicit-placement only. No gameplay RNG/state/codec.
DataValidator.validate_scenery_catalog(catalog:SceneryArtCatalog)->PackedStringArray combines schema validation with actual ResourceLoader/Texture2D dimensions; null/missing/import mismatch fails. CLI appends this check after all prior gates. Resource still unused by runtime until separately approved F5/F6.

## AUDIT-F3 machine header/layout (D89; full 607/607 automation verified)

LifeMachineHeader (ui/machine/machine_header.gd + new .tscn) extends HBoxContainer; typed closed() and land_requested(), display(operation_mode:bool)->void, public banner:LifeBanner/land_button:Button/close_button:Button. Stateless view with native non-wrapping header buttons, existing red banner and Theme. LifeMachineScreen.header exposes this component; prior banner/land_button/close_button aliases and selected/requested/closed signals remain compatible. No new command/state owner. Catalogue wraps existing rows in a themed LifeGalleryMargin inset to keep existing focus/hover motion inside the scroll viewport. Detail/catalog scroll, fixed header/footer and all controller commands stay. Exact runtime geometry and tests in PROGRESS.

## AUDIT-F2 exact debug shortcut (D88; full 603/603 automation verified)

MachineShopShortcut (scripts/view/machine_shop_shortcut.gd) is stateless VIEW RefCounted: matches(event:InputEvent,debug_build:bool)->bool requires a nonnull pressed toggle_debug_menu with allow_echo=false/exact_match=true and a true build flag. It reads existing InputMap only, no bindings/raw-key mapping/state. Physical Ctrl+M matches; plainM/additional Shift/Alt/Meta/release/echo do not. Explicit InputEventAction(toggle_debug_menu) remains compatible in debug and is rejected when buildflagfalse.
Main, UiCoordinator's modal/title/day-end filters, DebugMenu and NpcSystem all pass OS.is_debug_build() into the same policy. Main also rejects not-started/title/transaction-busy/sleep/held-day-end/advancing contexts before opening; world entry can no longer bypass the coordinator's transaction guard when no modal is active. Existing E shop entry, native GUI precedence and single-modal owner stay. No new public owner/input action/save field. False-build policy tests do not claim an exported release executable was run; actual verification is in PROGRESS.

## AUDIT-F1 crop stage contract (D87; full596/596 automation verified)

- CropStageConfig (scripts/data/crop_stage_config.gd; data/crop_stage_config.tres) is DATA: stage_count4, repeat_stage3 (one-based), validation_errors()->PackedStringArray requires the supplied four-image contract and repeat before the last stage. DataValidator.validate_crop_stage_config(config:CropStageConfig)->PackedStringArray is the null-safe facade; tools/validate_data.gd includes this gate without removing prior checks.
- CropStageRules is a stateless DOMAIN RefCounted. stage_index(growth_days:int,target_days:int,regrowing:bool=false)->int returns0..3, or-1 for invalid negative days/nonpositive target/invalid config; integer rational boundaries avoid day*4 overflow. ratio_stage_index(progress:float,regrowing:bool=false)->int clamps finite view ratios, returns-1 for nonfinite/config errors. Both use quarters on first growth and stage3 until maturity on repeats. crosses_stage(current_days:int,next_days:int,target_days:int,regrowing:bool=false)->bool detects a forward image boundary OR actual maturity, including when the final image was already visible. No owner mutation, clock, RNG or wire state.
- FarmGridState.advance_day replaces only its old modulo-stage test with CropStageRules; retains initial current_days>0 grace, Resource dry-limit override, moisture/recovery/death/shovel/day path. At target5,growth2->3 is now a care boundary. A cared-for first/repeat harvest date and every yield/price/season remain unchanged.
- CropPresentation.render and get_stage_id add optional final regrowing:bool=false; previous callers remain valid. FarmView supplies the real plot flag. Normal art advances at25/50/75%; repeat keeps stage3 until100%. stage_id remains0..3 or withered, visual_stage stays1..4, visual_asset/pivot/picking APIs stay. mature is false for withered/nonfinite/sub100% progress; image4 alone never authorizes harvest. Actual tool requests continue through FarmGridState.can_harvest.
- No savev12 field/migration/autoload/event/InputMap change. Test/full-gate output and editor acceptance are separate; do not claim PASS from this API entry.

## Phase7.1b runtime weather and save12 (D86; full583/583 verified; supersedes runtime gaps recorded in7.1a)

- WeatherProfile.initial_weather_id:StringName is required to resolve in the validated profile, even at zero probability. Shipped initial ID sunny; horizon3 and all four ordered entries/55-25-15-5 weights/effects unchanged.
- DetRandom.TAG_WEATHER:int=1; TAG_MERCHANT8 and make_rng(world_seed:int,day:int,tag:int)->RandomNumberGenerator/mix bodies unchanged. WeatherRoller.roll_day(profile:WeatherProfile,seed:int,day:int)->StringName validates context and selects an integer-weighted ID from a fresh tagged per-absolute-day stream; invalid returns empty ID. initial_snapshot(profile,seed,day)->Dictionary supplies declared current initial weather and configured future horizon. Seed is signed exact-JSON, day is nonnegative exact-JSON with forecast headroom.
- WeatherSnapshotCodec.decode(profile,raw)->Dictionary retains its pure three-field API. decode_at_day(profile:WeatherProfile,raw:Variant,expected_day:int=-1)->Dictionary additionally requires day_index:int/integral finite float in[0,9007199254740991-horizon], canonicalizes int and optionally checks expected clock day; -1 means no expected-day comparison. Complete known zero-weight pre-rolls remain valid. No draw, mutation, signals or partial snapshot.
- WeatherSaveCodec.normalize(profile:WeatherProfile,raw:Variant,day:int,legacy:bool=false)->Dictionary is pure envelope normalization. Empty{} stays{}; valid four-field component must match clock. legacy=true binds a missing day to the saved clock without altering today/seed/forecast. Invalid component warns and becomes{}; other progress is outside this helper. pack(profile,raw,day)->Dictionary is trusted save_game compatibility with legacy3 enabled. No RNG or state owner.
- WeatherState.configure(profile:Resource,seed:int=0,start_day:int=0)->void silently initializes valid terms, retains prior owner on invalid/busy. get_day_index()->int; is_busy()->bool; day_quote(target_day:int)->Dictionary is no-draw preflight requiring exact current+1, validated owner and numeric headroom. begin_day(target_day:int)->Dictionary captures next today/forecast/day/seed and returns opaque token without changing committed state. finish_day(token:RefCounted)->bool commits once; abort_day(token)->bool releases without committing. Wrong/null/stale tokens fail; duplicate/skipped/past/reentrant days fail before mutation/roll. advance_day(day_index:int)->void remains the convenience exact-next-day wrapper.
- WeatherState.serialize()->Dictionary returns world_seed:int,today:String,forecast:Array[String],day_index:int, excludes transient reservations/notification guards. deserialize(data:Dictionary)->void atomically validates current4 or complete legacy3 bound to configured owner day; invalid/busy retains prior state and emits nothing. restore_for_day(raw:Variant,day:int,default_seed:int=0)->Dictionary is explicit Main load/new command: valid exact-day values publish unchanged without RNG; missing/corrupt component uses declared initial weather/default seed and future tagged draws at actual clock day. Corruption warns; invalid context fails. Existing is_rainy/is_stormy/get_entry/force_weather remain; replacement/force is blocked while busy. Existing local/global typed weather_changed/forecast_updated publish once; each forecast argument is detached and source remains busy through notifications. Public debug fields remain for compatibility; callers must use guarded methods for writes.
- Main configures against actual clock day, restores the same owner on New/Load/Continue, checks signal day equals actual clock and preflights animal/weather dates. Reserve weather before outgoing rain/farm callbacks, retain the one-argument farm spy seam and existing farm->animal->machine sequence; check completed animal day, finish captured weather, apply morning rain and reconcile ledger before safe autosave/bulletin. Weather busy joins _purchase_in_progress for save/load/new/title/sleep commands. Failed internal finish fails closed; no offline/skipped-day catch-up.
- SaveService.CURRENT_VERSION12; migrate_11_to_12(data:Dictionary)->Dictionary deep-copies and only adds/validates weather day at saved clock. Every older valid weather retains all choices/order; empty v1 remains{}. Current12 load requires four fields. No RNG in saving/migration. Water introduction10 and purchased coop11 rules remain; no free water/hens/history. New save_v12 golden adds only version12/weather.day_index to v11. weather_rng_v12.json pins30 genuine4.7.2 signed/large-seed/day vectors plus merchant draws; old goldens/codec fixture immutable.


## Phase7.1a weather contract / independent codec (D85; full557/557 verified)

- WeatherProfile.forecast_days:int is DATA metadata; shipped data/weather_profile.tres sets3. Existing entries/get_entry(weather_id:StringName)->Dictionary, IDs/order/55-25-15-5 weights/darkness/flags stay. MAX_WEIGHT_TOTAL2147483647 is numeric integrity, not a probability tune. validation_errors()->PackedStringArray is pure: positive bounded horizon, nonempty/unique ASCII snake_case IDs, nonnegative strict int weights/positive bounded total, finite numeric darkness0..1, boolean flags, storm requires rain. Current WeatherState still hardcodes3 until separate integration.
- DataValidator.validate_weather_resource(profile:WeatherProfile)->PackedStringArray delegates to profile checks; null fails. Existing validate_weather_profile(path:String) preserves missing/unloadable checks, rejects wrong Resource type and delegates. Existing official tools call that path facade unchanged; no runner/tool edits or skipped checks.
- WeatherSnapshotCodec.decode(profile:WeatherProfile,raw:Variant)->Dictionary is pure/static RefCounted. Validate profile before any get_entry lookup/cast. Require complete Dictionary/world_seed/today/forecast; world_seed int or finite integral float within signed exact-JSON range[-9007199254740991,+9007199254740991]. today/entries String or StringName must resolve in profile. Forecast Array or PackedStringArray must have exactly configured horizon; known zero-weight IDs remain valid saved choices. Missing/unknown/wrong-type/nonfinite/nonintegral/out-of-range data returns {ok:false,errors:PackedStringArray}, no partial/default snapshot. Valid result {ok:true,snapshot:{world_seed:int,today:String,forecast:Array[String]}} is detached/canonical, drops extras and preserves choices/order. No random draw, signal, Node/Resource reference in output, state, clock, fallback or file write.
- tests/fixtures/weather_snapshot_v11.json copies actual save_v11 weather object seed0/today sunny/forecast[cloudy,rain,sunny]. This is codec compatibility data, not an RNG-sequence golden. Existing state/saves/goldens untouched. The codec is NOT wired to WeatherState/Main/SaveService: current legacy RNG/unsafe restore/day-token gaps remain explicit follow-up. No runtime anti-corruption/RNG migration completion claim.


## Phase6.7 recipe validation APIs (D84; full535/535 verified)

- RecipeEconomyConfig (scripts/data/recipe_economy_config.gd, data/recipe_economy_config.tres): max_value_added_per_game_hour_by_unlock_level:Dictionary, approved integer1:15/2:40/3:120; game_hours_per_day:int=24 in Resource. validation_errors()->PackedStringArray requires exact schema tiers and positive bounded integer terms. MAX_RULE_INTEGER2147483647 is arithmetic integrity, not a gameplay price. Validation tier is recipe.unlock_house_level; no runtime player-stage/house behavior changes.
- RecipeCatalogRules.validate(recipes:Array[Resource],machines:Array[Resource],items:Array[Resource])->PackedStringArray, static pure RefCounted. Checks exact Resource types, nonempty/unique ASCII snake_case IDs, positive bounded integer quantities/duration, nonnegative bounded prices, reciprocal machine/recipe/item references, no duplicate rows/links, machine slot limits and exactly one runtime output. Invalid data returns errors without Node/registry calls or mutations. valid_id(value:Variant)->bool supports this identity check.
- RecipeEconomyRules.validate(config:RecipeEconomyConfig,recipes:Array[Resource],machines:Array[Resource],items:Array[Resource])->PackedStringArray, static pure. Validates config/catalog first; uses sum(input sell_price*quantity) as opportunity cost and sum(output sell_price*quantity) as output value. Exact comparison value_added <= cap*duration_days*game_hours_per_day, checked int64 sums/products. multiply(left:int,right:int)->int returns -1 on negative/overflow, no float/rounding. Missing tiers and unsafe arithmetic reject explicitly. Nonpositive added value/zero-sale outputs are permitted without pretending products are priced for sale.
- DataValidator.validate_recipe_catalog(recipes,machines,items) and validate_recipe_economy(config,recipes,machines,items) are public static typed facades to those rules. Every previous validator method remains unchanged.
- DataRegistry.get_all_machines()->Array[Resource], get_all_recipes()->Array[Resource]: detached enumeration arrays of the actual registered Resource references, following get_all_items/get_all_crops. No registration/price/order change; callers clone Resources for negative fixtures.
- tools/validate_data.gd defers its original body to _run after autoload initialization, obtains actual root DataRegistry and appends the same recipe gate after all prior checks. Missing registry or any recipe error exits1. Existing official runner automatically invokes it unchanged.
- tools/validate_recipe_economy.gd standalone CLI: normal real catalog exits0; --fixture=over-cap / --fixture=invalid-reference clone all catalog Resources in memory and exit1 with identified error. Unknown args/fixture or impossible fixture construction exits2. Prevalidate real catalog before fixture construction. No data/registry/save write. PASS reports seven zero-sale outputs as not priced for sale. Tests invoke unchanged hidden/isolated bounded Windows helper at15000ms per child. OS.execute signature verified against official https://docs.godotengine.org/en/stable/classes/class_os.html#class-os-method-execute and executed on pinned4.7.2.


## Phase6.6d playable coop and save v11 (D83; full516/516 verified; editor acceptance separate)

DATA ChickenCoopSiteConfig: site_id, purchase_price700, initial_hens4, footprint/entrance/access_route/clearance, world/land/coop_config exports; validation_errors()->PackedStringArray; reserved_cells()->Dictionary. Resource data/chicken_coop_site.tres owns the approved geometry south of house.
DOMAIN ChickenCoopHoldingState: stable coop:ChickenCoopState; configure(config:ChickenCoopConfig,day:int)->void, is_owned()->bool, begin_purchase(hens:int)->Dictionary, finish_purchase(token:RefCounted,paid:bool)->bool, serialize()->Dictionary, deserialize(data:Dictionary)->void. Source remains the sole day/herd/feed/egg owner, wrapper alone owns purchased flag.
ChickenCoopState additive APIs: day_quote(completed_day:int)->Dictionary, begin_day(completed_day:int)->Dictionary, finish_day(token:RefCounted)->bool, begin_shop(stock_hens:int=0)->Dictionary, finish_shop(token:RefCounted,paid:bool)->bool. Shared source lock rejects other transactions/reset/restore/raw operations. Day reservation captures production before farm callbacks; finish commits captured output once. Shop/day tokens never serialize; old four-field source codec stays.
ChickenCoopShopService: configure(config:ChickenCoopSiteConfig,holding:ChickenCoopHoldingState,inventory:InventoryState,wallet:WalletState)->void; quote(action:StringName,quantity:int,occupied:Array[Vector2i])->Dictionary; purchase(action:StringName,quantity:int,occupancy:Callable)->Dictionary. Actions buy_coop/buy_feed. Actual debit/grant, captured refs/terms and exact rollback; purchase_busy shared across facades. Unexpected partial/invalid inventory count reports settlement_failed and keeps the source reserved, without guessing a destructive owner rollback.
ChickenCoopPurchaseRules static clear_site(config,cells)->bool, feed_price(item,quantity)->int, failure(reason)->Dictionary. ChickenCoopSaveCodec static empty(day:int)->Dictionary, normalize(raw:Variant,day:int,config:ChickenCoopConfig)->Dictionary canonicalizes v11 component, fallback unowned/empty with warning.
DaySimulator.simulate_day(farm_state:FarmGridState,coop:ChickenCoopState=null,machines:Object=null,completed_day:int=-1,farm_step:Callable=Callable())->void: optional compatibility args, preflight/reserve before any owner; farm -> captured animal production -> machines. Main passes the morning signal day-1 and supplies its existing one-argument day_simulator farm delegate through _simulate_farm_day (including outgoing rain). Runtime.simulator is a stateless orchestrator; Main.day_simulator remains the injectable farm-step seam. Main busy spans outgoing/new rain, simulation, weather and ledger reconciliation, then releases before safe autosave. The former separate machine listener is removed.
NpcSchedule.set_dynamic_obstacles(regions:Array[Rect2i])->void clears/rebuilds derived grid with original solids. NpcSocialState.refresh_routes()->void recomputes current target routes without changing cells/targets/friendship. NpcSystem.set_dynamic_obstacles(regions:Array[Rect2i])->void delegates both.
VIEW Main.chicken_coop/chicken_coop_runtime/chicken_coop_flow. Runtime configure(main:Node), context()->Dictionary, occupied_cells()->Array[Vector2i], execute(action:StringName,quantity:int)->Dictionary, prepare_restore(), reset(), restore(payload:Dictionary), refresh_site(); signal changed(); transient busy. Flow configure(main), open/close/back_to_bag/refresh; command(action,quantity); transient model/result and lazy panel. SiteView configure(world,holding,config), refresh(): actual projected art/owned-only collision outside WorldArt2D. GrayBoxWorld.configure_chicken_coop(query:Callable,request:Callable)->void; E uses water first, coop next, then existing anchors.
UI LifeChickenCoopScreen signals closed(), backed(), commanded(action:StringName,quantity:int), ensure_built(); composes Summary/Controls scene classes. Snapshot.capture(main)->Dictionary is read-only. Presenter.render(panel,model,result), reason(value)->String localize without commands. UiCoordinator registers panel/native modal keys and blocks transaction-time input. Main lifecycle/day-end guards include source busy.
SaveService.CURRENT_VERSION=11, WATERING_INTRODUCED_VERSION=10, migrate_10_to_11(data:Dictionary)->Dictionary. New root chicken_coop only; all prior golden versions retained. Ledger reasons buy_chicken_coop/buy_chicken_feed plus *_rollback refunds. No input actions/autoload/global event/new .tscn wiring required. Contracts chicken_coop.md/npc_navigation.md; evidence/known limits in PROGRESS.


## Phase6.6c registered chicken feed and guarded feeding (D82; full492/492 verified)

- ChickenCoopConfig adds feed_item_id:StringName, required nonempty in pure validation; shipped data/chicken_coop_config.tres binds chicken_feed and keeps4/1/1. New ItemData chicken_feed/material, stack99, buy20/sell0, ITEM_CHICKEN_FEED_NAME/DESCRIPTION in vi/en and existing generic icon fallback. Owner explicitly chose separate feed buy20 with egg30 retained; autumn_wheat42 unchanged. DataRegistry registers food, validator checks logical referenced ID and translations while preserving the18 old visual members. SeedShop remains seed-only; no purchase UI is implied.
- ChickenCoopState.feeding_quote(day_index:int,hens_to_feed:int)->Dictionary validates current day/unfed count/config and returns ready/item_id/feed_units/hens_to_feed/day_index. begin_feeding(day_index:int,hens_to_feed:int)->Dictionary holds opaque token and reserved hens. finish_feeding(token:RefCounted,debited:bool)->bool commits captured hens iff actual whole debit succeeded, or aborts without feeding; valid settlement releases despite config changes. Wrong/null/reused/cross-operation tokens cannot settle.
- is_busy now covers feeding and collection; collection_busy remains exact during collection, feeding_busy during feeding. All raw feed/day/take/reset/restore and either new reservation respect the shared owner guard across facades. Legacy raw feed signature/result and collection behavior remain. Four-field wire shape unchanged, both transient tokens excluded; busy snapshots remain diagnostic, not safe saves.
- ChickenCoopFeedingService is a stateless RefCounted adapter: configure(state:ChickenCoopState,inventory:InventoryState), can_feed(day_index:int,hens_to_feed:int)->Dictionary, feed(day_index:int,hens_to_feed:int)->Dictionary. Validate actual registered matching food and sufficient whole quantity, capture original refs/terms, reserve hens, remove through existing InventoryState, then settle according to truthful bool. Debit precedes notification and fed-hen grant follows it; no wallet/new inventory authority/snapshot rollback or free food.
- Result reports ok/reason/item_id/feed_units/hens_fed/fed_hens. Success fed uses actual cost and committed hens. debit_rejected reports0 spent/0 new fed and preserves independent gifts. Preflight failure reasons invalid_state/wrong_day/invalid_feed/unknown_feed/missing_feed/busy change neither owner; impossible invalid token settlement reports settlement_failed rather than guessing. Callback ref/config changes cannot redirect current debit; future commands use current refs/data.
- Current inventory/savev10 persists food stacks/remaining amounts, not a new coop game-save field. Paid daily feed standalone JSON persists through existing fed_hens; no eggs until legitimate completed-day advance. Main/day simulation/animal purchase/placement/shop/UI/save wiring still deferred. Tests/evidence in PROGRESS; all old tests/goldens/runners remain.


## Phase6.6b registered egg and guarded collection (D81; full479/479 verified)

- data/items/egg.tres registers stable egg as ItemData/produce, max_stack99, buy0/sell30 (documented schema price), ITEM_EGG_NAME/DESCRIPTION in vi/en. Empty visual fields use the existing generic icon fallback. DataRegistry includes it in the ordinary item list; validator checks logical item data/keys. All18 historical C2 visual item paths remain identical and are checked separately; new fallback item does not require an invented historical3D model.
- ChickenCoopState adds collection_quote(expected_quantity:int)->Dictionary (pure current-state/busy/exact quantity quote), begin_collection(expected_quantity:int)->Dictionary (reserve/clear source and return token:RefCounted/item_id/quantity), finish_collection(token:RefCounted,remaining_quantity:int)->bool, is_busy()->bool. Reservation identity/quantity are transient within the same owner, shared across facades. Only matching token/valid remainder settles; config invalidation cannot prevent restoring legitimate reserved output.
- During reservation, feed/advance_day/take_eggs/quote/begin reject collection_busy; configure/deserialize warn and retain state. Existing signatures/wire shape/current_day/hen_count/fed_hens/pending_eggs stay. serialize while busy is diagnostic, not a safe game-save snapshot; future Main integration must check is_busy. Raw take remains trusted only, not a bag command.
- ChickenCoopCollectionService (stateless RefCounted) configure(state:ChickenCoopState,inventory:InventoryState), can_collect(expected_quantity:int)->Dictionary, collect(expected_quantity:int)->Dictionary. Query validates actual state, registered matching item and whole bag room. Command captures original owner refs, reserves source before any item notification, adds once through existing InventoryState and settles only untransferred remainder. No inventory/state snapshot rollback, new persistent owner, autoload/global signal or runtime grant.
- Normal success: ok=true/reason=collected/item_id=egg/quantity=actual added/remaining=0. Zero rejecting double: transfer_rejected with entire buffer restored. Valid partial-added-count fault: partial_transfer, actual granted count retained, only remainder restored; not partial-full-bag gameplay. Full/unknown/stale/busy fail before mutation. Failure reasons also invalid_state/unknown_item/inventory_full/stale_quantity; invalid added-count contract yields settlement_failed and keeps reservation fail-closed rather than guessing a duplicate payout. Existing InventoryState obeys the added-count contract.
- Callbacks may gift/consume bag items or configure a facade's future references without whole-owner rollback or redirecting the current transfer. State guard blocks same/second facade and raw day/feed/extract/reset/restore during callbacks. Four-field standalone codec and existingv10 bag item persistence remain. Main/day simulation/animal feed/purchase/placement/UI/animal save fields stay deferred; existing sale behavior can read documented30 from owned ItemData.


## Phase6.6a standalone chicken-coop foundation (D80; full466/466 verified)

- ChickenCoopConfig Resource at data/chicken_coop_config.tres: hen_capacity4, feed_per_hen1, eggs_per_fed_hen1; validation_errors()->PackedStringArray validates positive JSON-safe integers and full-herd product precision through checked integer division. MAX_JSON_INTEGER9007199254740991 is external numeric integrity, not a small gameplay buffer cap. No feed ItemData binding or egg registry/price.
- ChickenCoopState (pure RefCounted) configure(config:ChickenCoopConfig,start_day:int,hens:int)->void explicitly initializes0..capacity hens/day; invalid configuration initializes inert empty state. feed(day_index:int,hens_to_feed:int)->Dictionary is a trusted internal primitive: exact current day/positive unfed count, returns feed_units and cumulative fed_hens. It does not debit any bag and must not be exposed as player input without a future authorized inventory transaction.
- advance_day(completed_day:int)->Dictionary accepts exact current day once, adds fed_hens*configured yield to retained pending eggs, clears feed and increments day1. Unfed hens never die; no egg destruction or catch-up. Numeric overflow/invalid/stale/skipped commands return explicit failure without mutation. take_eggs(expected_quantity:int)->Dictionary requires exact positive current buffer, returns documented token egg/quantity once and clears; raw primitive is not bag-safe runtime collection.
- serialize()->Dictionary returns detached current_day/hen_count/fed_hens/pending_eggs integers only. deserialize(data:Dictionary)->void requires prior valid configuration; accepts complete valid integer/integral-JSON-float snapshots, ignores unknown extra keys, restores all fields together. Missing/malformed/nonintegral/out-of-range/overfed payload warns and retains entire existing snapshot. Invalid Resource later blocks commands without deleting stored fields. No config reference/runtime flag saved.
- Results have ok:bool and reason:StringName: fed/advanced/collected success, invalid_state/wrong_day/invalid_feed/numeric_overflow/stale_quantity failure. Success additionally reports feed_units/fed_hens, produced/day_index, or item_id/quantity respectively. Header/API contracts document the new internal interfaces before any runtime wiring.
- tools/validate_data.gd validates the new config directly; no DataRegistry/Main/DaySimulator/Inventory/Wallet/SaveService/UI/scene/autoload/input change. Savev10 and all old goldens/tests/runners remain. This is standalone serialization, not game-save integration; actual feed identity/current wheat economics and animal art/placement/purchase/collection are deferred.


## Phase6.5h3 first watering-can upgrade (D79; full457/457 verified)

- Main adds watering_upgrade_config:WateringCanConfig (existing data/watering_can_config.tres), watering_upgrade:WateringCanUpgradeService and watering_upgrade_flow:WateringUpgradeFlow. Existing domain service/can/Resource and savev10 codec remain unchanged; actual can/wallet references are shared. _purchase_in_progress also covers upgrade_flow.busy, guarding lifecycle/water/refill/other purchases during debit/grant/refund. Load/new/title close the panel; state persists through existing capacity/charges fields.
- WateringUpgradeFlow.configure(main:Node), open(), close(), back_to_bag(), purchase(expected_capacity:int), refresh()->void. Only active Bag/no discard/sleep/day advance/other transaction opens; model/result/busy are transient. Recheck displayed target/price and service expected capacity; notify existing Runtime only after actual completed can changes. Coalesced wallet/water/locale refresh. Explicit Back may return to Bag; generic close/lifecycle does not.
- LifeWateringUpgradeSnapshot.capture(main:Node)->Dictionary returns detached actual capacity/charges/coins plus configured target/price even when quote fails for funds/completion. LifeWateringUpgradePresenter.reason(code:StringName)->String and render(panel,model,result)->void only format views. Three small scene/script pairs: LifeWateringUpgradeScreen.ensure_built(), signals closed()/backed()/purchased(expected_capacity:int); Summary.display(model), Footer.display(model,result), signals confirmed()/backed(). See watering_upgrade contract for generated tree. Existing Theme/native GUI/modal authority reused.
- LifeInventoryFooter adds watering_upgrade_button:Button and watering_upgrade_requested() in a separate hints row, preserving capacity/sort/bag button. Controller.request_watering_upgrade()->void defers active-Bag opening; existing Runtime.water_changed refreshes entry eligibility. Insufficient funds may open; complete/invalid disables.
- DayLedgerState.REFUNDS adds existing buy_watering_upgrade_rollback metadata. Presenter maps purchase to WATER_UP_LEDGER and refund to END_REFUND. Rejected/refunded purchase has zero net income/expense; preserve signed entries, independent transactions and schema. No extra tier/free refill/new binding/global event/autoload.


## Phase6.5h2b runtime water/refill/HUD/save-v10 (D78; full446/446 verified)

- Main owns exactly one existing WateringCanState as watering_can, plus WateringRuntime application child. Existing WateringCanConfig/State/WateringService/UpgradeService remain unchanged. Runtime.configure(main), water(cell:Vector2i)->Dictionary, can_refill()/refill()->Dictionary, reset()/restore(payload:Dictionary)/refresh()->void. Local typed water_changed(charges:int,capacity:int) notifies HUD/save-dirty after completed commands; busy covers debit/refund and explicit Main reset/load batches, never serialized. Main's existing _purchase_in_progress guard also covers water busy; all existing entry APIs retain names.
- WaterRefillService (stateless RefCounted) configure(config:WateringCanConfig,state:WateringCanState,sources:WaterSourceConfig,locations:WorldLocations), can_refill(player_cell:Vector2i)->Dictionary, refill(player_cell:Vector2i)->Dictionary. Query checks actual config identity/validity, shared dry bank/playable bounds/combined solid exclusion. Results use ok/reason and, only on an actual bank, source_id/display_name_key/charges/capacity. Full has source context with already_full/ok=false, no mutation. No caller-supplied source ID, cost, clock or geometry copy.
- ToolActionController.configure_watering(runtime:WateringRuntime) routes its existing mouse/stroke/Space/Inspector water branch to the same actual can. Runtime validates actual Player/context/watering ToolData reach/placement-permission, uses existing WateringService reservation/refund, and reports empty/rejected failures. Raw ToolAction/FarmGridState/rain/DaySimulator remain unchanged and are not runtime authorization APIs. Existing domain wither recovery is preserved (older terminal-wither historical prose is not current code).
- GrayBoxWorld.configure_water_refill(query:Callable,request:Callable) adds delegated actual-bank source context to its existing E/prompt routing. Selected can + unlocked dry bank prioritizes refill over nearby bin; ordinary tool context retains existing interactions. Already-full feedback is honest and does not reset state/revision. GUI/NPC/menu E ownership remains; source shapes/markers/art/Player/InputMap untouched.
- LifeHudWaterMeter.display(charges:int,capacity:int) is a script-built read-only Theme caption component using existing watering_can icon. Toolbar adds centered StatusRow with original caption plus WaterMeter, retaining caption/buttons/request/display/slots and overall rectangle. LifeHudPresenter subscribes to local runtime change; the meter translates live. Existing right cards/HotbarPanel/UiCoordinator/scenes/Theme/fonts stay.
- SaveService.CURRENT_VERSION=10 and migrate_9_to_10(data:Dictionary)->Dictionary add watering_can:{capacity,charges}. Old formats get data-owned full base; forged old can data is overwritten, all old fields deep-copied. Current malformed/absent state uses existing conservative codec; known20/40 capacity is preserved. Main new game alone resets full base, restore/Continue/autosave/day-end/title retain actual values. Existing atomic backend/goldens1..9 stay. save_v10.json shows20/13 with old v9 sample progress; raw JSON numeric values are cast by existing domain codec.
- No upgrade UI/later tier/overnight refill/new autoload/global event/scene or resource-balance change. Exact scope,23 explicitly approved version assertions and real bounded tests/captures/manual acceptance are in PROGRESS and watering contract.

## Phase6.5h2a expanded map and source geometry (D77; full430/430 verified)

- WaterSourceData (Resource): source_id/kind/display_name_key:StringName, region:Rect2i, label_cell:Vector2i, access_waypoints:Array[Vector2i]. WaterSourceConfig: world:IsometricWorldConfig, sources:Array[WaterSourceData], clearance_cells:int and water/shore/path/well Color palette. validation_errors()->PackedStringArray validates structure without Nodes/domain; get_blocked_regions()->Array[Rect2i] returns detached deduplicated positive rectangles.
- WaterSourceRules (stateless RefCounted): static validate(config,solids:Array[Rect2i],protected_regions:Array[Rect2i])->PackedStringArray; access_cells(source)->Array[Vector2i]; source_at(config,cell)->StringName (empty outside); is_shore(config,source,cell)->bool; reserved_cells(config)->Dictionary (Vector2i keys, clipped to scenery). Geometry only, no runtime refill authority/state/serialize requirement. Validate against actual old static solids and base/planned farmland before use.
- WorldLocations adds optional water_sources:WaterSourceConfig and get_solid_regions()->Array[Rect2i]. Original solid_rects/IDs/API retained. GrayBoxWorld collision, NpcSchedule.configure and LandExpansionRules.validate read combined deduplicated regions; NPC rectangles clip to existing nav region. No existing schedule targets change.
- IsometricWorldConfig adds scenery_region:Rect2i. Actual map/player/scenery are85/39/43 cells, center(-2368,-1120)..(2496,1312), pan(-2600,-1400)..(2600,1400); inherited five zoom levels/follow/offset unchanged. DataValidator.validate_water_source_config(config,locations,land)->PackedStringArray adds overlap gate; tools/validate_data.gd requires three new translated names.
- WaterSourceView.configure(data:WaterSourceData,grid:IsometricGrid,config:WaterSourceConfig,floor_only:bool=true)->void generates ground art/optional label, using actual WorldCanvas and grid. WorldPresentation builds source floor views there and well art in Objects, caches reservation geometry and limits passive scenery to scenery_region. Source nodes survive owned-land scenery refresh and live vi/en updates; phase freezes on GameClock.paused.
- No new input/signal/autoload/can owner/save field or scene wiring. Runtime watering/refill/HUD/save integration remains deferred. See water_sources scene contract and PROGRESS for acceptance/evidence.

## D72-C4 live locale refresh (D76; full421/421 verified)

- WorldPresentation public APIs stay unchanged. Private created-anchor references refresh player House/SeedShop/ShippingBin labels on existing NOTIFICATION_TRANSLATION_CHANGED and appearance/profile setup; current player_name is not translated. Only text/visibility/cosmetic redraw change, including while paused. No scenery/physics/avatar rebuild or domain/save mutation.
- NpcSystem retains all public APIs and existing homes map. Translation notification refreshes home labels from actual NpcData display_name_key/UI_NPC_HOME and redraws the existing art. NpcActor name/hint processing, schedule/dialogue/quest/trade/friendship behavior are unchanged.
- LifeHudToastStack.show_message/clear and existing max-two/three-second view lifetime stay compatible. Actual locale switch hides old cards immediately, then removes their instance IDs after notification traversal; show_message first flushes only captured old IDs. Deferred timer callbacks also use IDs, so a removed card cannot remove replacement feedback. Same-locale apply preserves existing cards/lifetime. No formatted-message reconstruction/history replay/new metadata/API.
- New tests verify same-Main vi/en/back, supported pause Apply, paused draw signals/node identity/phase and owner/save preservation, lifecycle guards and stale timeout races. All old tests/C2 runners/GUT/scene/data/save-v9/Settings/localization sources stay unchanged. Exact evidence and failure history in PROGRESS; no editor wiring.

## D72-C3 toolbar selection (D75; full418/418 verified)

- LifeHudToolbar.display(slots,selected_inventory,active_tool,window_start) and request(index), tool_requested/item_requested retain signatures. Four tools use existing indexes0-3; populated visible items use TOOLS.size()+relative index. Invalid/absent/out-of-window item selections have active_index=-1, no selected style and localized UI_TOOL_SEED fallback; every render resets stale caption. Titles/tooltips/icons/quantities still read actual registered stacks.
- HotbarPanel.select_slot/remap_selection retain signatures and derive private pages from actual button count minus four tools. Pages0-3/4-7/8-11 keep selected item visible. Legacy key9 still selects bag index8, now visible slot5 (zero-based4); numeric5-8/click and qualified wheel use the same current page. Selection/remap does not own/mutate inventory.
- C1 map-vs-hotbar wheel arbitration/pan/placement/modal rules, C2 complete runner, all domain/gameplay/save-v9/art/scene/InputMap/Theme contracts remain unchanged. Corrected two specifically approved obsolete test expectations are documented in PROGRESS; new actual input/render/remap tests are additive. Manual scene setup: none.

## D72-C2 complete graphics runner (D74; complete415/415 verified)

- tools/run_tests.bat retains parse/data/headless/Main gates and delegates full graphics to tools/run_graphics_tests.ps1 -Godot <exe> [-OutputPrefix <absolute-prefix>]. Defaults to %TEMP%/the_life_gut. Existing command cmd /c tools\run_tests.bat remains the official entry point.
- Helper discovers/hash-counts actual root tests/unit/test_*.gd, alternates ordinal paths into two groups, invokes unchanged run_godot_bounded.ps1 sequentially with180000ms each, checks stdout/stderr/complete GUT totals and exact coverage, then rechecks test bytes. It never advances game/save state outside existing tests.
- Artifacts: <prefix>.manifest.json (inventory/hashes/group membership/timeout), <prefix>_1.log.stdout/.stderr, _2.log.stdout/.stderr, <prefix>.summary.json (running/failed/passed, combined and per-group counts/GUT/wall time). Exit0 only for complete verified coverage; otherwise exit1. Nonstandard/inner-only tests require explicit contract extension; C2 baseline110 scripts/415 tests, C3 inventory111/418 and current C4 inventory112/421 are discovered automatically. All test/assertion/capture sources remain unchanged. Actual outputs/limits are in PROGRESS.

## D72-C1 inherited visual completion (D73; complete415/415 verified via C2)

- CameraRig retains set_target/get_pan_offset/reset_pan/is_panning and the existing single player Camera2D. Its unhandled wheel path yields Shift and GUI-hover events; HotbarPanel handles native wheel explicitly because legacy tool_next/tool_prev have no physical bindings. Plain map wheel zooms; Shift/toolbar-hover cycles once using actual adapter selection and only populated visible item slots, including wrap in both directions; modal/sleep/movement gates remain authoritative. No InputMap action or scene dependency added.
- IsometricWorldConfig adds camera_pan_min:Vector2=(-1400,-800), camera_pan_max:Vector2=(1400,800). Existing inherited zoom_levels0.35/0.5/0.75/1/1.25 and default index1 remain. DataValidator validates finite ordered pan bounds containing zero. Existing map/player/camera center/follow values are unchanged. Walking recenters smoothly; reset_pan/double-right-click reset immediately, matching actual behavior.
- MachinePresentation.configure(main)/refresh() remain compatible. Internal working rows hold actual MachineState references and idle/work textures. Each process synchronizes real ready/idle state before pause gating, then only advances cosmetic frames while unpaused. Refresh resets frame/timer; no-working disables processing. It reads no new domain owner API per frame and does not progress jobs/collect/output or serialize a view.
- DataValidator.validate_isometric_2d_assets(asset_root:String="res://assets")->PackedStringArray checks the five offline PNG existence/canvas contracts with PNG byte decoding, independent of autoloads/export resource-image warnings. Normal tools/validate_data.gd includes this gate. Filenames/dimensions are detailed in DATA_SCHEMA/isometric_visuals contract.
- tools/build_isometric_2d_assets.gd preserves its existing pixel algorithms/default output and adds optional --output-root=<path> user argument. Directory/PNG write failures are errors with nonzero exit; success prints PASS only after all writes. Isolated regeneration/determinism/error checks do not overwrite source images.
- Active avatar/hair/world/crop/wood controls remain their inherited procedural renderers with current customization. The five PNGs are deterministic draft/offline outputs, not active sprite/Theme bindings. Existing real-time avatar action/emotion feedback expiry is preserved while world cosmetic phases pause. No Main/domain/save-v9/old-test change. Exact native/render/asset proof, inherited-vs-completion diffs and human status are in PROGRESS.

## Phase6.5h1 standalone watering foundation (D71; foundation407/407 delivered, runtime integration deferred)

- WateringCanConfig Resource exports base_capacity:int, upgrade_capacity:int, upgrade_price:int; data/watering_can_config.tres owns20/40/200. validation_errors()->PackedStringArray is pure data validation with JSON-safe integral bounds. DataValidator.validate_watering_can_config(config:WateringCanConfig)->PackedStringArray delegates directly to it, including the standalone --script gate; no service/autoload dependency there.
- WateringCanState.configure(config:WateringCanConfig)->void creates fresh full base20. is_ready_for(config)->bool checks actual config identity/validity, known capacity and bounded charges; get_capacity()/get_charges()->int return0 when invalid. try_consume_one(expected_charges:int)->bool, refund_one(expected_refill_revision:int=-1)->bool, refill()->bool and try_upgrade(expected_capacity:int,target_capacity:int)->bool are synchronous trusted state primitives with no external callbacks. Upgrade changes capacity only, preserving remaining water.
- get_refill_revision()->int exposes a transient replacement token. Real refill/configure/deserialize advances it; ordinary consume/refund/upgrade does not. WateringService supplies this token when refunding, so a refill/load/reset that subsumed the old debit cannot cause its refund to cancel a later independent consumption. Raw no-argument refund/refill are low-level trusted primitives, not player/source authorization or reusable transaction receipts.
- State.serialize()->Dictionary saves exactly capacity/charges ints. deserialize(data:Dictionary)->void recognizes only configured base/upgrade capacity and finite integral JSON values; missing/corrupt charges become0, excess clamps to actual capacity, unknown/malformed capacity becomes empty base. Invalid/unconfigured context stays unusable. No config/refill token/UI/Node is serialized.
- WateringService.configure(config:WateringCanConfig,state:WateringCanState,farm:FarmGridState)->void; can_water(cell:Vector2i)->Dictionary; water(cell:Vector2i)->Dictionary. Pure stateless manual command adapter: existing dry crop only, reserve one before actual water_cell, refund only its reservation on rejection, same-service reentry guard and captured original owners. Existing wither recovery/farm events are retained; rain/bulk/day paths are unchanged and do not reference this standalone can.
- WateringCanUpgradeService.configure(config:WateringCanConfig,state:WateringCanState,wallet:WalletState)->void; can_purchase(expected_capacity:int)->Dictionary; purchase(expected_capacity:int)->Dictionary. Single20->40/200 tier, actual wallet authority, no refill, duplicate/stale/insufficient/invalid/reentry rejection and own-debit refund on grant failure. Explicit reasons buy_watering_upgrade/buy_watering_upgrade_rollback; local captured owners preserve callback context changes and independent successful transactions.
- No Main instance, tool route, refill-source/reach logic, HUD/UI, new autoload/global signal or game-save field/version is connected. Existing runtime/save-v9/previous test sources remain unchanged. Standalone JSON is not a game-save migration. Actual tests/scope/diff and deferred integration are recorded in PROGRESS.

## Phase6.5g first bag upgrade (D70; automation394/394 delivered, human F5 pending)

- BagUpgradeConfig Resource: base:InventoryConfig, additional_slots:int, purchase_price:int; shipped data/bag_upgrade_config.tres references existing40-slot base and sets12/300. validation_errors() -> PackedStringArray checks pure Resource terms. MAX_CAPACITY=4096 is the shared unchanged external-save integrity bound; InventoryState.MAX_SAVED_SLOTS is its alias. It is not a purchasable capacity. DataValidator.validate_bag_upgrade_config(config:BagUpgradeConfig) delegates directly to the Resource without loading autoload-dependent services, so --script validation remains independent.
- InventoryState.try_expand_capacity(expected_capacity:int,target_capacity:int) -> bool rejects stale/non-expanding/unsafe requests, preserves every stack/index/order, and updates capacity/revision with one existing inventory_changed notification. Existing clear() retains capacity. Existing serialization/deserialization shape is unchanged.
- InventoryUpgradeService.configure(config:BagUpgradeConfig,inventory:InventoryState,wallet:WalletState), can_purchase(expected_capacity:int)->Dictionary, purchase(expected_capacity:int)->Dictionary; static validate_config(config)->PackedStringArray. Pure stateless adapter with transient reentry guard, actual wallet debit, exact current expected-capacity/price/target checks and debit-only refund after rejected grant. Local owner references preserve callback reconfiguration/independent transactions. No new persistent owner.
- Main owns bag_upgrade:InventoryUpgradeService and bag_upgrade_flow:BagUpgradeFlow. _purchase_in_progress()->bool shares callback safe-point checks between land and bag. New Game explicitly resets bag to configured40 plus starter seeds; load retains existing legitimate capacity/items. No save version/flag/golden change.
- BagUpgradeFlow.configure(main), open(), close(), back_to_bag(), purchase(expected_capacity:int), refresh() -> void. Transient busy/model/result only. Active inventory with no discard prompt opens lazy content; stale/hidden/busy/changed-quote requests cannot silently pay. Generic lifecycle close never reopens inventory; explicit Back may reopen only when safe. UiCoordinator retains sole modal/clock/Player authority.
- LifeBagUpgradeScreen.ensure_built(); closed(), backed(), purchased(expected_capacity:int). Summary/Footer are separate small scenes; footer confirmed()/backed(). LifeBagUpgradeSnapshot.capture(main)->Dictionary and Presenter.render/reason only format detached current/target/price/wallet/readiness. Existing footer adds upgrade_requested() and upgrade_button:Button; controller defers opening. Grid/slots/filter/sort/discard/toolbar source stays unchanged; it already reads actual capacity and scrolls extra rows.
- Ledger buy_bag_upgrade is a real expense; buy_bag_upgrade_rollback is reduced expense, not earnings. New17 vi/en keys are in the normal validator gate. Exact accepted scope, test output, diff and manual steps are in PROGRESS.

## Phase6.4b runtime land expansion (D69; automation384/384 delivered, human F5 pending)

- Main owns land_ownership:LandOwnershipState and land_expansion:LandExpansionService, configured from the D68 Resource before placement/presentation. land_runtime:LandRuntime is the transient application adapter; it does not own coins or parcels. Earlier standalone-only/v8 descriptions below are historical.
- ExpansionParcelData adds display_name_key:StringName; first_east.tres uses LAND_EAST_NAME. LandOwnershipState.get_owned_regions() -> Array[Rect2i] returns a detached validated base-plus-grants snapshot. Existing price/grant/service APIs remain unchanged.
- MachinePlacementRequest.configure(build:MachineBuildService, farm:FarmGridState, config:MachineBuildConfig, map_region:Rect2i, reach:float, land:LandOwnershipState=null) -> void adds an optional final dependency. Main always supplies it; omitted means historical fixed-region standalone policy. New placements/moves and hoe/seed on empty cells require ownership (land_locked). Existing tilled plots and in-place legacy rotation remain compatible.
- WorldPresentation.refresh_land(regions:Array[Rect2i]) -> void rebuilds only generated passive trees/rocks/grass/colliders outside owned cells. Identical snapshots skip rebuilding. Anchors/crops/machines/NPCs/weather remain outside this generated root.
- LandRuntime.configure(main:Node), open(), close(), purchase(parcel_id:StringName), restore(data:Dictionary), refresh() -> void. busy:bool is transient and gates Main save/load/reset/title operations during a purchase callback stack. Model/result/expected UI IDs are transient. Open requires the actual active shop, game/debug state and shop mode; close/reset/load clear stale UI. UiCoordinator registers the hidden shell before its contents exist and owns modal/clock/Player locks.
- LifeLandSnapshot.capture(main:Node) -> Dictionary and owned_cells(state:LandOwnershipState) -> int are read-only. LifeLandPresenter.render(panel,model,result) and reason(code) format translations. LifeLandScreen.ensure_built() lazily creates Summary/Footer; closed(), purchased(parcel_id:StringName). Footer confirmed()/cancelled() are local requests. Small .tscn roots and actual child construction are specified in SCENE_CONTRACTS/land_expansion.md.
- SaveService.CURRENT_VERSION=9; migrate_8_to_9(data:Dictionary) -> Dictionary deep-copies and initializes land_ownership={owned_parcels:[]}. Main restores guarded dictionaries before scenery/tools; the same state instance survives load/reset. DayLedgerState treats buy_land_rollback as a refund; presenter labels buy_land and its rollback. Existing historical gameplay payloads and v1-v8 goldens remain intact.

## Phase6.4a land foundation (D68; automated acceptance delivered)

- ExpansionParcelData exports parcel_id:StringName and region:Rect2i. LandExpansionConfig exports initial_region, parcels:Array[ExpansionParcelData], base_cost/growth_numerator/growth_denominator/rounding_step:int and existing world:IsometricWorldConfig/npc_world:NpcWorldData references. Data is standalone, not registered in Main/UI.
- LandExpansionRules.validate(config: LandExpansionConfig) -> PackedStringArray; quote_cost(config: LandExpansionConfig, order: int) -> Dictionary. Shared structural/bounds/static-solid checks and integer-only, overflow-checked pricing. DataValidator.validate_land_expansion_config(config: LandExpansionConfig) -> PackedStringArray delegates to it.
- LandOwnershipState.configure(config: LandExpansionConfig) -> void; is_ready_for(config: LandExpansionConfig) -> bool; can_use_cell(cell: Vector2i) -> bool; get_owned_ids() -> Array[StringName]; next_parcel_id() -> StringName; grant_next(parcel_id: StringName) -> bool; serialize() -> Dictionary; deserialize(data: Dictionary) -> void. Known ordered-prefix IDs only; no persistent UI/world owner introduced yet.
- LandExpansionService.configure(config: LandExpansionConfig, state: LandOwnershipState, wallet: WalletState) -> void; can_purchase(parcel_id: StringName) -> Dictionary; purchase(parcel_id: StringName) -> Dictionary. Transient reentry guard, real wallet authority, actual next-ID/price validation and debit-only refund on failed grant. No new autoload/global signal or game-save version change.
- Final focused8/8,288 assertions; after owner stopped F5, the unmodified official batch passed parse/data/headless63/63/graphics377/377 with18683 assertions at154.692s/Main. Earlier timeouts/pre-ID results remain historical logs. No runtime/UI/game-save integration is included; see PROGRESS for full diff/audit/status.

## Phase6.5f move APIs (D67; automated acceptance delivered)
- `MachineBuildService.can_move(cell: Vector2i, target_cell: Vector2i, rotation: int) -> Dictionary`: pure source/target/job/occupancy/rotation preview; shared by the existing move command. No reservation/temporary source release.
- `MachinePlacementRequest.can_begin_move(cell: Vector2i, player_cell: Vector2i) -> Dictionary` returns actual eligibility and a detached `source` dictionary on success. `preview_move(source: Dictionary, target_cell: Vector2i, rotation: int, player_cell: Vector2i) -> Dictionary`; `move(source: Dictionary, target_cell: Vector2i, rotation: int, player_cell: Vector2i) -> Dictionary`. Snapshot exact typed machine_id/cell/rotation must still match; UI always requires idle even for in-place rotation. Different targets use the existing region/Player/reach/plot policy. Results use ok/reason and moved/rotated or stale_source where applicable.
- `MachinePlacementFlow.begin_move(cell: Vector2i) -> void` owns only transient `source: Dictionary`; empty source means original Place mode. Existing begin/cancel/point/rotate/confirm and shared modal authority stay. Status adds `display_move(id, source_cell, cell, rotation, has_cell, preview, region) -> void`; actual typed signatures are defined in the scene contract. Shop adds native move action/readiness; no InputMap action/public adapter rename or saved field.
- Verification: new7 pure/3 native tests; focused24/24, clean renderer13/13, official369/369 with18395 assertions at155.38s, parse/data/headless63/63/Main PASS. All old test/P1 sources unchanged; human F5/explicit commit pending. Exact diff/logs/screenshots in PROGRESS.

## Phase6.5e-P1 inventory fixture scheduling (2026-11-04)

No public runtime API, signal, scene or saved-state change. Only test_inventory_screen.gd replaces fixed delays with a bounded check of the actual inventory refresh/UiCoordinator layout queues and stable visible-Control rectangles across two consecutive comparisons. Its isolated SubViewport renders once for each existing screenshot; native input, all six original test bodies and all36 captures remain. The wait fails explicitly after120 process frames without convergence. Final fixture runs retain370 headless/406 renderer assertions; three renderer runs9.97/9.69/9.907s versus29.8s. Official parse/data/headless63/63/renderer359/359/Main PASS, graphics170.057s under the unchanged180s bound. See PROGRESS for exact scope/diff/capture review and remaining timing risk.

## Phase6.5e mouse placement and idle return (D66, 2026-11-04)

Verification continuation: no API/runtime change. The unchanged official batch now passes parse/data/headless63/63/complete renderer359/359/Main; graphics time173.546s remains close to the unchanged180s bound. Profiling and timeout history are recorded in PROGRESS; human F5/commit pending.

- `MachineBuildService.can_place(machine_id: StringName, cell: Vector2i, rotation: int) -> Dictionary` and `can_remove(cell: Vector2i) -> Dictionary` are read-only preflights reused by place/remove. They preserve D65 identity, job, collection and rollback guards, and check actual ownership/registration/rotation/occupancy before placement.
- `MachineBuildConfig.is_valid(map_region: Rect2i) -> bool` validates its Resource-owned `allowed_region`. Current `data/machine_build_config.tres` sets Rect2i(0,0,6,6). `DataValidator.validate_machine_build_config(config: MachineBuildConfig, world: IsometricWorldConfig) -> PackedStringArray` participates in the normal data gate.
- `MachinePlacementRequest.configure(build: MachineBuildService, farm: FarmGridState, config: MachineBuildConfig, map_region: Rect2i, reach: float) -> void`; `preview/place(id: StringName, cell: Vector2i, rotation: int, player_cell: Vector2i) -> Dictionary`; `can_return/return_to_storage(cell: Vector2i, player_cell: Vector2i) -> Dictionary`; `can_use_farm_tool(cell: Vector2i, action_id: StringName) -> Dictionary`. Stateless RefCounted adapter, no Nodes or serialized state. Confirmation repeats preview using actual Player context. New placement also rejects outside-region, Player, too-far and tilled/cropped cells. Nearby idle returns outside the new region remain allowed for old saves.
- `MachinePlacementFlow.configure(owner: Node)`, `begin(id: StringName)`, `cancel()`, `confirm()`, `point(screen_position: Vector2)`, `rotate(direction: int)` return void; `handle_shortcut(event: InputEvent) -> bool`. Only transient selected machine/cell/rotation/feedback. Shop Place defers begin; Return uses the request adapter, refreshes actual presentation and dirty tracking on success. Shop adapter public methods remain unchanged.
- `LifeMachineBuildOverlay.ensure_built() -> void` lazily composes preview/status once; typed signals `pointed(point: Vector2)`, `confirmed()`, `cancelled()`, `rotated(direction: int)`. Status emits the last three, owns native Buttons and displays snapshots. `MachinePlacementPreview.display(world: GrayBoxWorld, cell: Vector2i, machine_id: StringName, rotation: int, valid: bool)` projects existing manifest art through the world grid and actual camera zoom. See machine_build.md for exact scene contracts.
- `ToolActionController.configure_placement(request: MachinePlacementRequest)`, `set_placement_active(active: bool)` and `ToolDragStroke.cancel()` return void. Placement cancels farm strokes; confirmation held input is gated until release. Hoe/seed use the request permission check; legacy crop water/harvest/shovel remain available. UiCoordinator alone owns pause/Player/camera/modal interruption. No new InputMap binding, save field/version, domain state owner or simulation path.

## Phase6.5d job-safe build facade (D65, 2026-11-04)

- `MachineBuildService.configure(state: MachinePlacementState, operations: MachineOperationService) -> void` explicitly requires the actual operation owner. Main initializes/configures operations before wiring build; the existing placement fixture now supplies both. Missing/unconfigured dependencies return `invalid_state`. Existing `place/rotate/move/remove` names and `{ok, reason}` result shapes stay.
- `MachineOperationService.can_edit_placement(cell: Vector2i, require_idle: bool = true) -> Dictionary` is a read-only `editable`/`machine_busy`/`invalid_state`/`collection_busy` preview. It validates cell/machine/placement identity, a completely empty idle job, or (for in-place rotation only) actual registered active recipe/output terms. Orphan active/buffered/corrupt rows fail closed and remain saved; no orphan output is adopted or repaired.
- `forget_idle_job(cell: Vector2i) -> Dictionary` removes only a registered, cell-matching, completely empty idle row, returns `forgotten`, and respects the transient collection guard. It validates emptiness independently of the placement identity because successful move/return/replacement may already have changed that placement. The facade must preview before editing and call cleanup only after success; direct cleanup is not an active-job removal API.
- Different-cell move/remove require editable idle source; place/move also preview the destination. Successful place/move/remove clear only validated empty rows; cleanup rejection rolls back placement, owned-count and job snapshots. Failed placement does not clean jobs. `rotate` never changes jobs; same-cell `move` retains the underlying rotate-in-place semantics, including valid active progress/output.
- Every facade edit/cleanup is rejected during D63 collection, including its reserved-idle inventory-callback interval. No wallet/bag grant/refund, simulation, new persistent owner/signal/field/save version or resource/scene/UI/InputMap change. Low-level MachinePlacementState remains for codec/unit operations; production VIEW requests must use Main's connected facade.

## Phase6.5c modular machine presentation (D64, 2026-11-04)

- `MachineShopPanel` retains `configure(main: Node)`, `open()`, `open_machine(cell: Vector2i)`, `close()`; `screen: LifeMachineScreen` and `controller: LifeMachineController` compose the existing modal root. Its service/result/cell inspection adapters remain available for the prior integration checks. Main/world/scene callers are unchanged.
- `LifeMachineSnapshot.capture(main, selected, recipe_id, operation, cell) -> Dictionary` captures the seven real shop entries, placed cells, selected recipe inputs/output/duration, coins/owned/house requirements and actual job/buffer/capacity. It mutates no owner. `LifeMachinePresenter` localizes item/state/result/reason text, constructs common Theme Controls and caches read-only textures resolved from the existing manifest; no new resource path/art/data is registered.
- `LifeMachineController.configure(view, owner)`, `open(operation = false, target = Vector2i.ZERO)`, `reset()`, `select(key: StringName)`, `request(action: StringName)`, `queue_refresh()` own transient display selection/result only. Actions are catalog/buy/place/start/collect; hidden/sleeping/inactive/mismatched/reentrant requests are rejected. Low-level domain/shop/build APIs are unchanged. A disabled Start uses fresh read-only readiness to avoid creating an empty domain job; successful starts still pass through the domain authority. Wallet load/new-game resets the panel, invalid placement closes it. Successful place/start/collect refresh existing world presentation.
- `LifeMachineScreen.display(model, feedback)` composes five new scene pairs under `ui/machine`. `LifeMachineCatalog.display(rows, selected_id, operation_mode)` reuses native row Buttons and emits `selected(id: StringName)`. `LifeMachineCard.display(data, selected)`, `LifeMachineDetails.display(model, operation_mode)` and `LifeMachineFooter.display(model, feedback)` only display snapshots; Footer emits `requested(action: StringName)`. Screen forwards selected/requested and emits closed. Header/footer stay fixed, detail/catalogue scroll independently, valid action focus/scroll survive deferred owner/locale refresh.
- UiLayout centers only this added panel in existing wide modal bounds and excludes it from legacy recursive restyling. UiCoordinator allows native Tab/Space/Enter/navigation inside it before overlapping world shortcuts; original Escape/E/modal/day-end/sleep/Player authority stays. No new action/save field/house owner/merchant/selling/batch/build mode is added. Existing test placement is explicitly labelled; see `SCENE_CONTRACTS/machine_shop.md` for the exact composition and human checks.

## Phase6.5b safe machine collection (D63, 2026-11-04)

- `MachineOperationService.can_collect_output(cell: Vector2i) -> Dictionary` previews placement/job identity, ready output, registered item, exact single-output recipe terms and whole-quantity bag capacity without mutation.
- `collect_output_to_inventory(cell: Vector2i) -> Dictionary` returns `{ok, reason}` plus `item_id/quantity` on success. It reserves the buffer before InventoryState callbacks, transfers once and restores both snapshots if addition fails. Full/unknown/invalid/no-output requests leave inventory, output and wallet unchanged. The transient guard blocks nested collect/start/raw take/day advancement; existing APIs and serialized state remain compatible.
- Reasons: `ready` (preview), `collected`, `collection_busy`, `invalid_state`, `no_machine`, `no_output`, `unknown_item`, `inventory_full`, `transfer_failed`. Raw `take_output()` remains a destructive low-level API, not a bag transfer; views must use the safe request.
- `MachineShopPanel` retains `configure/open/open_machine/close`, delegates collection to the service and shows actual localized results/buffered items. Inventory/locale signals coalesce deferred rebuilds; mode/cell and valid action focus survive refresh. Disabled Collect explains readiness/capacity, freed space refreshes immediately. See `SCENE_CONTRACTS/machine_shop.md`.
- DataRegistry registers seven existing `temp_*` output ItemData with approved vi/en labels, category `other`, stack99 and zero trade values; bag/detail rendering uses existing item APIs/icon fallback. No recipe, balance, save-v8 shape, Player or scene change.

## Restored Player + retained machine/crop APIs (D62, 2026-11-04)

- `CameraRig.set_target(Player)` again follows the Player's child Camera2D with existing follow/clamp/zoom Resources; movement/sleep/modal gates block zoom input. Player/get_cell/move_to_cell, appearance/profile/Character screen and legacy logical-position save/load are restored.
- `GrayBoxWorld.pick_cell()` still converts pointers to logical cells; restored tool/NPC/shop/bin/bed paths use Player reach. Added machine_shop_marker/machine_shop_interacted and placed-machine selection remain; machine input is gated by Player movement/sleep.
- Main serializes/restores player.position alongside current machine_inventory/machine_placements/machine_operations. New crop data/art/care/shovel and machine domain services remain unchanged. Exact Ctrl+M still opens the machine shop, whose modal locks Player. Earlier manager-only removal/drag contract is superseded by the owner's selective restoration request.

## Phase 6.1 machine processing APIs (2026-11-04)

- `MachineData` defines a machine ID, manifest-backed `sprite_dir`, input/output slot counts, allowed recipe IDs and house unlock level. `accepts_recipe()` is the allow-list check.
- `RecipeData` defines typed-by-convention input/output dictionaries (`item_id`, `quantity`), game-day duration, allowed machine IDs and house unlock level. Existing processed output IDs remain stable; Phase6.5b registers their ItemData labels while final trade values/art remain deferred.
- `MachineState.start(machine, recipe, inventory, house_level)` validates the machine/recipe/house contract and atomically consumes inputs. `advance_day()` progresses only one completed game day; completion fills the output buffer and uses `blocked` until `take_output()` is called. `serialize()`/`deserialize()` preserve job progress and output state.

## Machine Shop APIs (2026-11-04)

- `MachineData.purchase_price` is the Resource-owned temporary purchase price; `unlock_house_level` remains the house requirement.
- `MachineInventory.add_machine()`/`get_quantity()`/`serialize()`/`deserialize()` own unlimited machine counts separately from item slots.
- `MachineShopService.purchase(machine_id, house_level)` checks shop membership, machine unlock level and wallet affordability, then atomically charges `WalletState` and adds one machine. It returns `{ok, reason}`.

## Phase 6.2 occupancy and placement APIs (2026-11-04)

- `OccupancyMap` tracks occupied logical cells and Resource-owned locked cells. `can_place(footprint, origin, rotation)` rejects invalid rotations, locked cells and overlap; `occupy()`/`release()` mutate only after validation.
- `MachinePlacementState.place(machine_id, origin, rotation, machine_inventory)` consumes one owned machine and records cell/rotation; `remove(origin)` releases the machine and clears occupancy. `serialize()`/`deserialize()` preserve placements and rotation.

## Phase 6.3 build-mode domain APIs (2026-11-04)

- `MachineBuildService` delegates place, rotate, move and remove commands to `MachinePlacementState` without owning gameplay state.
- `MachinePlacementState.rotate(cell, rotation)` changes only a valid placed machine's saved rotation and restores the original occupancy if the target rotation cannot be applied.
- `MachinePlacementState.move(cell, target_cell, rotation)` atomically changes a placement's cell and rotation; failed moves restore the original cell, rotation and occupancy. Removing a machine returns it to `MachineInventory`; coin refunds and UI/ghost previews remain deferred.

## Phase 6.4 machine shop and operation APIs (2026-11-04)

- `MachineOperationService` owns one serializable `MachineState` per placed machine cell, starts registered recipes, advances jobs on completed days and exposes buffered output collection.
- `MachineShopPanel` is a script-built view for the seven existing machine resources. It delegates buying, test placement, recipe start and output collection; it owns no machine state.

## Phase 6.5 direct machine presentation APIs (2026-11-04)

- `MachineInteractionController` converts the existing world mouse-cell picker into a selected logical machine cell and opens operation UI through the existing `interact` action when the cell is in reach.
- `MachinePresentation` rebuilds placed machine sprites from `machines_manifest.json`, using the manifest pivot and supplied idle/work files; missing manifest data is warning-only.

## ISO-18 supplied crop catalog and care APIs (2026-11-03)

- `DataRegistry` loads `data/crops/supplied_crop_catalog.tres` and registers all 16 supplied crop IDs, their planting items, produce items and manifest-backed seed icons. `CropData.planting_item`, `planting_item_buy_price`, `produce_sell_price`, `perennial` and `regrow_days` remain data-owned.
- `FarmGridState.water_cell()` restores a withered crop; `water_all_crops()` provides the rain path. `advance_day()` withers an unwatered crop at a stage transition and removes it after the second consecutive withered day without care. `clear_withered()` preserves the tilled plot for replanting.
- `ToolAction.apply(&"shovel", ...)` is the dedicated withered-crop cleanup action. `CropPresentation` uses the supplied stage/wilted files and `crops_manifest.json` pivots for every registered supplied crop.

## ISO-17 planting-item shop APIs (2026-11-03, D55)

- `SeedShopPanel` reads `DataRegistry.get_seed_items()` and current season state, then displays actual `ItemData` names/prices/icons without a crop-specific hardcoded catalogue.
- `SeedShopPanel` delegates purchases to existing `WalletState`/`InventoryState` owners and keeps affordability, inventory capacity and atomic rollback behavior unchanged.
- Unsupported planting-item categories and remaining shop/house/NPC/dialogue/calendar/event screens have no registered runtime API and remain deferred; no new gameplay data is implied by the supplied crop art.

## ISO-12 ground/assets APIs (2026-11-03, D50)

- `GrayBoxWorld._build_tiles()` assigns the imported `res://assets/tiles/tileset/ground_tileset_128x64.tres` to Ground and Farmland. `_ground_variant(cell: Vector2i) -> Vector2i` deterministically selects the atlas grass/flower row-0 variant from the logical cell; no gameplay state or save field is added.
- `IsometricWorldConfig.tile_size` is `Vector2i(128, 64)` and its default camera zoom is `0.5`; `IsometricGrid` remains the only projection adapter using `TileMapLayer.map_to_local()` / `local_to_map()`. Highlight remains the only hover-cell visualization.
- Imported ISO-12 asset roots are `assets/tiles/`, `assets/decor/` and `assets/objects/`; the nested source bundle remains retained. See `SCENE_CONTRACTS/gray_box_world.md`.
- `WorldPresentation._build_natural_scenery()` creates stable passive rock/grass-clump sprites from logical-cell hashing. Large rock roots contain a `WorldStaticCollision` body; no scenery state is saved and cleanup interactions remain deferred.
- `CropPresentation.render()` loads matching crop stage/wilted textures and manifest canvas/pivot data from `res://assets/crops/crops_manifest.json`; missing crop basenames retain the generated placeholder and emit one warning. `CropData` exposes optional `stage_textures`, `wilted_textures`, `pivot`, `perennial` and `planting_item` fields without changing existing domain/save ownership.

## ISO-11 Quest book APIs (2026-11-03, D48)

- Existing Main/NpcJournal remains NpcPanel; enable_quest_book(main: Node)/show_quest_book() -> void add journal-only book: LifeQuestBook and book_controller: LifeQuestBookController. tabs references book.tabs; legacy margin is hidden, existing column/title_label/close_button/show_content/enable_tabs/close_requested stay for dialogue/standalone callers. Dialogue action selectors remain unchanged. NpcSystem.open_journal keeps guards/lock/fallback; InventoryController.attach_main enables the book before connecting tabs. Main resets transient UI on New Game/load/title.
- LifeQuestBookController.configure(owner_panel: NpcPanel, main: Node), reset(), queue_render(), select(key: String), filter(id: StringName) -> void; selected_key: String, active_filter: StringName. Coalesced deferred rendering reads after owner transactions, retains valid selection/scroll and resets detail position when changing tasks. Inventory/social/onboarding signals refresh only visible presentation. No accept/deliver/reward/state/save callback.
- QuestBookSnapshot.capture(main: Node) -> Dictionary reads entries/people: actual seven onboarding flags, registered QuestData/QuestManager status, current bag quantity and Resource reward terms, real NPC friendship. Current content is one Minh delivery quest. Current possession is not delivery history; a completed flag can coexist with0 items. Onboarding has no listed reward. QuestBookPresenter.render(book, snapshot, filter, key, main) -> String returns valid visible selection.
- Seven ui/quests scene pairs: LifeQuestBook (tabs/filters/list/people/detail/hint); LifeQuestFilters.display(active: StringName, counts: Dictionary), filter_requested(id: StringName); LifeQuestList.display(values: Array[Dictionary], key: String), selected(key: String); LifeQuestRow.display(row: Dictionary, selected: bool); LifeQuestDetail.display(row: Dictionary, main: Node); LifeQuestObjective.display(row: Dictionary); LifeQuestReward.display(row: Dictionary). All display methods return void. See SCENE_CONTRACTS/quest_book.md for fields/tree/internal journal migration.
- All/Active/Completed are transient filters; Daily/Pin/Map unavailable, no XP/deadline/category/gift claims or new T binding. Nearby NPC dialogue alone accepts/delivers/pays through unchanged atomic owners. NpcSystem/UiCoordinator pass native ui_* keys in journal; existing Q/E/J/B/I/clock/world hold/day-end precedence remain. No domain/core/data/old scene/Theme/art/renderer/InputMap/save-v8/golden/tool changes.

## ISO-10 Character/relationship APIs (2026-11-03, D47)

- Main owns character_flow: LifeCharacterFlow, configured before inventory.attach_main/UiCoordinator. configure(main: Node), open(), close(), refresh() -> void; panel: LifeCharacterSheet (Main child CharacterScreen). Open respects started/title/tutorial/sleep/day-end guards; Main closes stale presentation on New Game/load/title. Visibility/social.changed/locale refresh read-only values. UiCoordinator alone owns pause/input/modal state; no saved UI flags.
- CharacterSnapshot.capture(main: Node) -> Dictionary reads actual profile names/normalized appearance and registered NPC rows{id,name_key,color,points,maximum}. Current social world registers Minh/Linh; catalogue-only recipes are not additional NPCs. CharacterPresenter.render(panel: LifeCharacterSheet, snapshot: Dictionary) -> void localizes display without talking, granting friendship, trading, advancing or saving.
- Seven ui/character scene pairs: LifeCharacterSheet (tabs/identity/skills/relationships/hint); LifeCharacterIdentity.display(snapshot: Dictionary); LifeCharacterPortrait.display_player(selection: Dictionary)/display_npc(id: StringName, fallback: Color); LifeCharacterSkills.refresh(); LifeCharacterSkill.display(key: StringName); LifeCharacterRelationships.display(rows: Array[Dictionary]); LifeCharacterRelationship.display(row: Dictionary). All return void. Actual PlaceholderAvatar2D/catalogue/hair renderer is shared; no portrait artwork or cosmetic edits. See SCENE_CONTRACTS/character.md for fields/tree.
- Existing LifeInventoryTabs now enables0/1/2; InventoryController.attach_main connects three headers, show_tab(index) and existing Q/E cycle Bag/Character/Quest. Calendar/Map remain disabled, no new input action. J/B/I shortcuts retain original targets; native Tab/Enter/Space stay GUI actions inside Character. UiLayout supplies wide bounds; day-end keeps precedence and prior pause restores.
- Raw friendship points/per-NPC cap accompany five floor-ratio hearts, display only. Cards reuse existing controls on refresh and scroll only when needed. Skills/XP/levels/bonuses/birthdays/gifting remain unavailable; no core/domain/data/save-v8/golden/old-scene/Theme/renderer/tool changes.

## ISO-9 morning bulletin APIs (2026-11-03, D46)

- Main owns morning_flow: LifeMorningFlow. Its existing day_started callback queues the day after the one care/simulation/weather/journal path and direct save attempt. Existing day-end confirmation finishes its final save synchronously before presentation on a later process frame. No new simulation/save callback or gameplay state.
- LifeMorningFlow.configure(main: Node), queue_day(day: int), dismiss(), reset(), refresh() -> void; panel: LifeMorningSheet. Transient pending/last-shown guards wait for completed sleep/day-end/other modal, discard stale days and reset on New Game/load/return-title. No automatic bulletin on tutorial/Continue/load. Dismiss only hides the view; UiCoordinator restores the prior pause hold.
- MorningSnapshot.capture(main: Node) -> Dictionary reads actual one-based seasonal date, current weather/three saved forecasts, harvestable/needs-water/tilled-empty/withered counts, onboarding progress/hints and sorted produce rows{id,name_key,price}. CropData.water_need and FarmGridState.can_harvest supply existing rules. No weather roll, trade, watering or save mutation. MorningPresenter.render(panel: LifeMorningSheet, snapshot: Dictionary) -> void localizes these values.
- Six scene/script pairs under ui/morning: LifeMorningSheet (dismissed(), typed title/date/weather/garden/market/tasks/begin_button); LifeMorningWeather.display(weather: StringName, forecast: Array[StringName], day: int); LifeMorningGarden.display(snapshot: Dictionary); LifeMorningMarket.display(rows: Array[Dictionary]); LifeMorningPriceRow.display(id: StringName, name_key: StringName, price: int); LifeMorningTasks.display(ready: int, water: int, empty: int). All return void. Price icons reuse LifeInventoryIcon.for_item; prices match unchanged ItemData.sell_price read by shipping bin.
- UiCoordinator registers the new sheet in the existing exclusive modal list; native GUI keys precede overlapping world shortcuts and day-end retains precedence. UiLayout supplies wide summary bounds and excludes legacy recursive styling. Calendar/events/trends remain unavailable; no new InputMap, autoload, bus, save fields or old scene changes. See SCENE_CONTRACTS/morning_bulletin.md.

## ISO-8b creation/2D preview APIs (2026-11-03, D45)

- LifeTitleProfileForm retains get_selection() -> Dictionary, submitted()/cancelled(), LineEdit player_name/farm_name and native confirm/back fields. New names: LifeProfileNameFields, choices: LifeProfileChoices, preview: LifeProfileAvatarPreview, fields_scroll: ScrollContainer (follow_focus). Six choices per row; hair_style/skin_tone/hair_color/outfit_color are now LifeProfileChoiceRow, explicitly replacing OptionButtons/AppearanceGrid internals. begin_submission() -> bool/reset_submission() -> void enforce one request per profile opening, with reentry/hidden guards in TitlePresenter. StartMenu public APIs and _name_box VBox remain.
- LifeProfileChoiceRow.configure_styles(styles: PackedStringArray), configure_colors(colors: Array[Color], key: StringName), select(index: int) -> void; selected: int, item_count: int getter, buttons: Array[Button], get_item_metadata(index: int) -> Variant/get_item_text(index: int) -> String, selected_changed(index: int). LifeProfileChoices.get_selection() -> Dictionary normalizes through unchanged catalogue; changed(selection: Dictionary).
- LifeProfilePresenter.configure(form: LifeTitleProfileForm), refresh(_value: Variant = null), cycle(direction: int) -> void binds transient names/choices to actual renderer; no game state. LifeProfileAvatarPreview.display(selection: Dictionary, player_text: String, farm_text: String) -> void, hair_cycled(direction: int), avatar: PlaceholderAvatar2D and typed arrow/caption fields; arrows cycle hair, not facing.
- PlaceholderAvatar2D.get_hair_style() -> StringName exposes the cosmetic ID selected via existing configure_profile; shared stateless AvatarHair2D.draw_back/draw_front(CanvasItem, StringName, Color, Color) -> void supplies six player silhouettes. Empty player customization preserves the old NPC arc exactly. Body/action/motion/collision/state are unchanged; no new data/schema/3D nodes.
- See SCENE_CONTRACTS/character_creation.md for five new scene pairs/seven UI helpers and explicit internal-control migration. UiLayout now uses wide bounds for both profile/settings; title is unchanged. Existing shared Theme/art/Main/core/domain/data/InputMap/save-v8/goldens remain. Only the graphics GUT invocation adds TimeoutMs180000; all tests/error gates and helper defaults remain.

## ISO-8a modular title APIs (2026-11-03, D44)

- StartMenu preserves configure(new_game_callback: Callable, continue_callback: Callable, exit_callback: Callable), appearance_selected(appearance: Dictionary), get_appearance_selection() -> Dictionary, refresh_continue()/apply_chibi_style() -> void. New screen: LifeTitleScreen, presenter: LifeTitlePresenter; handle_back() -> bool returns from profile/settings to title, false on title. Compatibility _name_box/_settings_box point to actual VBox components. Old script-created MarginContainer/Column paths are explicitly replaced by typed screen fields; Main/StartMenu is unchanged.
- LifeTitleScreen.Mode {TITLE,PROFILE,SETTINGS}; set_mode(value: Mode), display_version(value: String) -> void. Typed latest/actions/profile/settings components and logo/tagline/version/hint Labels are defined in SCENE_CONTRACTS/start_menu.md. Five scenes and seven small scripts live in ui/title; no existing .tscn edits.
- LifeTitlePresenter.configure(menu: StartMenu, screen: LifeTitleScreen, start: Callable, resume: Callable, exit: Callable), refresh(), request(id: StringName), submit() -> void. Reads latest saved payload, enables/revalidates Continue, forwards original normalized profile callback. No gameplay ownership/new save fields.
- LifeLatestSaveCard.display(payload: Dictionary) -> void renders actual saved names/day/coins, omits invalid/missing optional fields. LifeTitleProfileForm.get_selection() -> Dictionary delegates existing catalogue normalization, submitted()/cancelled() signals; form scrolls independently of fixed confirm/back controls. LifeTitleSettings.begin()/apply()/defaults() -> void reuse existing LifeSettingsPanel and Settings setters, cancelled() returns to title.
- UiLayout uses a left title/profile card and a centered wide settings rectangle; UiCoordinator preserves the title's world lock, handles Back/Escape and permits native GUI keys before overlapping world actions. TitleBackdrop/art/Theme/Main/core/domain/data/InputMap/save-v8/goldens remain unchanged.

## ISO-7 modular pause/settings APIs (2026-11-03, D43)

- Existing Main/PauseMenu keeps configure(save_callback: Callable, load_callback: Callable, main_menu_callback: Callable), open(), close(), toggle() -> void and _toggle_settings() compatibility. New typed fields shell: LifePauseShell, presenter: LifePausePresenter. Six scene/script pairs under ui/pause separate shell/actions/settings/audio/game/bindings; see SCENE_CONTRACTS/pause_menu.md.
- LifePausePresenter.configure(menu: PanelContainer, shell: LifePauseShell, save: Callable, load: Callable, exit: Callable), begin(), apply(), defaults(), request(id: StringName), show_result(key: StringName), refresh_summary() -> void. Drafts live only in native controls. Apply calls existing Settings setters; Default edits only supported drafts; opening reloads current values. Language changes refresh captions without rebuilding signal emitters.
- LifeSettingsPanel.select_tab(index: int), show_status(key: StringName) -> void; applied()/defaulted() request signals. LifeAudioSettings.set_values(music_volume: float, effects_volume: float) -> void; native music/effects sliders have read-only Theme-backed ProgressBar tracks. LifeGameSettings.set_locale(value: String) -> void / get_locale() -> String. LifeControlsHelp.refresh() -> void reads current bindings. LifePauseActions.requested(id: StringName) requests resume/save/load/settings/menu.
- Main private callbacks _save_game(), _save_game_to_slot(slot: int), _load_game(), _load_game_from_slot(slot: int), _return_to_start_menu() now return bool. Blocked/failed save returns false, manual/morning feedback reflects actual outcomes, and required save failure prevents return to title. No payload/schema/save-backup/Settings API changes: version stays8, v1-v8 goldens retained.
- UiLayout gives PauseMenu the wide summary-style rectangle; excludes its modular styling from legacy recursion. UiCoordinator keeps modal ownership/day-end precedence and permits native ui_* focus/activation/navigation before overlapping world shortcuts inside pause. Existing clock hold restores on close.

## ISO-6b1 crop cycle/economy APIs (2026-11-03, D42)

Current save version is **8**. Historical milestone entries below describe their original deliveries.

- CropData adds regrow_days: int (0 default, tomato 2). Current new-sowing targets are carrot 3, tomato 5, turnip 4, corn 7; approved price table is in DATA_SCHEMA/D42. Existing yield/care/seasons/IDs stay unchanged.
- CropEconomyConfig (scripts/data/crop_economy_config.gd; data/crop_economy_config.tres) owns max_profit_per_plot_day=80 for the current dataset. CropEconomyRules.validate(config: CropEconomyConfig, crops: Array[Resource], items: Array[Resource]) -> PackedStringArray is pure/stateless. It checks positive bounded values, net first-cycle return and gross repeat return using exact integer cross multiplication, with safe int64 products. DataValidator.validate_crop_economy delegates here; old unit-price and monotonic-price gates remain.
- CropMigrationConfig (scripts/data/crop_migration_config.gd; data/crop_migration_v7.tres) owns previous_growth_days: Dictionary for all nine pre-v8 crop IDs. DataValidator.validate_crop_migration(config: CropMigrationConfig, crops: Array[Resource]) -> PackedStringArray rejects missing/unknown IDs or invalid historical durations. Both gates run in tools/validate_data.gd.
- FarmGridState owns growth_target: int and regrowing: bool per plot. get_growth_target(cell: Vector2i) -> int returns the current frozen target (0 for absent crop); get_growth_remaining/can_harvest use it. New planting snapshots Resource first-growth days. Harvest returns the usual yield; single-harvest crops are removed, repeating crops retain their cell/ID/care and reset growth=0, target=regrow_days, regrowing=true before signals. No free water/drought reset or extra seed consumption. Existing ToolActionController capacity/reach/lock checks remain the transaction path.
- CropCycleRules.target_days(crop: CropData, plot: Dictionary) -> int and begin_repeat(crop: CropData, plot: Dictionary) -> Dictionary are stateless snapshot helpers. FarmSaveCodec.encode(plots: Dictionary) -> Dictionary and decode(data: Dictionary, crops: Dictionary, legacy: CropMigrationConfig) -> Dictionary extract wire conversion/validation; decode returns {success: bool, plots: Dictionary}. It takes Resource snapshots, never Nodes or state ownership. Invalid whole arrays retain the previous farm through the owner; row/care guards remain. New cycle targets are restricted to current or legitimate historical first targets, or exactly the repeat target; malformed flags default false.
- SaveService CURRENT_VERSION=8; migrate_7_to_8(data: Dictionary) -> Dictionary deep-copies and assigns pre-v8 historical targets plus regrowing=false without rewriting original fields/growth. v1–v7 goldens stay unchanged; v8 golden includes a living repeat cycle. Current first-cycle targets survive save/load; repeat targets stay 2. Ledger/guard, slots, wallet and other fields remain.
- FarmView now queries get_growth_target for stage/readout; CropInspector shows UI_CROP_REGROW_NOTE for an actual unready repeat cycle, with dry warning precedence. Main refreshes all existing farm views after restoring a snapshot using the existing configure API. Existing native controls, paths, scenes, input/autoload/bus APIs remain; no house/fertilizer domain is implied.

## ISO-6a crop care APIs (2026-11-03, D41)

At ISO-6a delivery the save version was **7**; ISO-6b1 above supersedes it with v8.

- CropData adds max_consecutive_dry_days: int, with 2 in all nine existing crop Resources. Only care metadata changes; growth/yield/seasons/prices/IDs are unchanged. A crop with water_need=0 does not accumulate dry days. DataValidator requires a positive threshold for water-requiring CropData while retaining the existing economy invariants.
- FarmGridState owns consecutive_dry_days: int per plot. advance_day() grows watered/water-free crops, resets their dry streak, or increments dry days and withers at the Resource threshold. It skips terminal withered crops. water_cell()/water_all_crops() reset surviving plants' streak; withered crops cannot be watered/revived/harvested. Ripe crops left planted still require care.
- FarmGridState.get_dry_days_remaining(cell: Vector2i) -> int returns threshold minus current streak, or 0 for absent/withered/water-free plants. serialize()/deserialize() persist the counter; restore clamps it, rejects malformed new values safely and preserves old progress. Withered flags and threshold-reaching saved counters block harvest even when mature.
- Main's single day_started -> DaySimulator path applies the FINISHED day's stored care/current rain, simulates once, marks new-season withering, advances weather, then waters surviving new-morning plots if rainy. New rain cannot rescue yesterday's second missed day; yesterday's rain cannot stay on a sunny morning. Existing flow/clock/modal and save-safe-point APIs remain.
- CropInspector reads the real remaining dry days through the owner query and shows UI_CROP_DRY_WARNING only for an unwatered surviving plant with a nonzero dry streak (including ripe plants). Water/Harvest requests keep existing tool/reach/capacity ownership. Locale notification refreshes visible text. No scene or InputMap changes.
- SaveService CURRENT_VERSION=7, migrate_6_to_7(data: Dictionary) -> Dictionary deep-copies and initializes absent plot counters to 0. v1–v6 goldens are unchanged; v7 golden includes a threatened plant and a terminal withered mature plant. Existing other fields, atomic writes, ledger/guard, inventory migration and latest-save selection remain.

## ISO-5 inventory APIs (2026-11-03, D40)

At ISO-5 delivery the save version was **6**; ISO-6a above supersedes it with v7.

- InventoryConfig (scripts/data/inventory_config.gd, data/inventory_config.tres): default_capacity=40, columns=8, visible_rows=5. Explicit InventoryState(max_slots) still supports small-capacity tests. ItemData adds category (seed/produce/tool/material/other) and optional description_key; current IDs/prices/stack limits remain unchanged.
- InventoryState adds transient revision: int, sort_slots() -> Array[int] (new-index -> old-index, stable category/id order), discard_from_slot(index: int, expected_id: StringName, expected_quantity: int, expected_revision: int, quantity: int) -> bool. Exact-row discard validates identity/count/revision, emits normal removal once, and never changes coins. Deserialize preserves valid legacy stacks beyond declared capacity/stack limits; malformed shapes/unsafe totals retain previous state with warnings.
- InventoryActions (scripts/domain/inventory_actions.gd) exposes static sort(inventory) -> Array[int] and discard(inventory,index,expected_id,expected_quantity,expected_revision,quantity) -> bool; stateless delegates to the owner.
- InventoryPanel keeps configure/toggle_inventory/close_inventory/slot_selected/inventory_toggled; adds attach_main(main) and typed screen/controller. LifeInventoryController handles transient selection/filter/confirmation/contextual keys and owner requests. LifeInventoryScreen composes eight small scene/script pairs under ui/inventory. Their typed requests are in SCENE_CONTRACTS/inventory.md. Q/E switches Bag/Quest; F explicitly selects a real stack; Z sorts in Bag. Unsupported tabs stay disabled.
- HotbarPanel adds selected_index() -> int, active_tool() -> StringName, remap_selection(order: Array[int], previous_index: int, previous_tool: StringName) -> void. Reordering/removal preserves the selected surviving stack and active tool without another action. NpcPanel.enable_tabs() attaches the shared header only for journal; content/actions remain.
- SaveService CURRENT_VERSION=6; migrate_5_to_6(data: Dictionary) -> Dictionary deep-copies payload, floors player capacity to config while preserving larger capacities/all slots/previous fields. v1–v5 goldens stay unchanged; v6 golden added. DataValidator.validate_inventory_config(config: InventoryConfig) -> PackedStringArray checks positive dimensions/capacity and product; item categories/descriptions join the data/translation gate.
- LifeInventoryTheme.apply(theme) extends the existing shared Theme builder; LifeInventoryIcon.for_item(id) -> Texture2D caches trimmed AtlasTexture views of existing art. No new autoload or source-art changes.

Public methods and signals of every system. Agents read THIS instead of scanning code, and update it at the end of every task. Source of truth for each entry is the `## API:` header at the top of the script.

## ISO-4 day-end APIs (2026-11-03, D39)

Current save format is v5, extending the historical v4 entries below with day_ledger / day_end. Clock/tool/farm/wallet ownership and Main node paths remain compatible.

- DayLedgerState (scripts/domain/economy/day_ledger_state.gd), pure RefCounted: reset(day: int, history_complete: bool = true), record(amount: int, reason: StringName), annotate_trade(reason: StringName, item_id: StringName, quantity: int, total: int), totals() -> Dictionary (income/expense/profit ints), rows() -> Array[Dictionary], serialize() -> Dictionary, deserialize(data: Dictionary). Unspecified setters return void. Refund/minh_rollback reduce expense; metadata never adds cash. Unknown/corrupt/bounded history is marked incomplete. Static number(value: Variant, fallback: int = 0) -> int safely decodes finite JSON integers.
- DayEndState (scripts/domain/day_end_state.gd), pure RefCounted: review(day: int, automatic: bool) -> bool, confirm(day: int) -> bool, cancel() -> bool, reconcile(day: int) -> void, serialize() -> Dictionary, deserialize(data: Dictionary) -> void. IDLE/REVIEW/ADVANCING and last_completed_day guard repeated/re-entrant confirmation; forced review cannot cancel.
- GameClock adds typed day_end_requested(day_index: int), hold_day_end(day: int), release_day_end(day: int), is_day_end_held() -> bool. Held review blocks raw minute advancement, try_sleep and set_time. A cutoff with no claiming consumer keeps immediate rollover fallback. Existing low-level APIs/signals remain compatible; deserialize clears transient sleep/hold state.
- GrayBoxWorld adds local bed_requested() on the reachable/night bed action; standalone world retains try_sleep fallback. Main owns day_end_flow: LifeDayEndFlow.
- LifeDayEndFlow (ui/day_end/day_end_flow.gd): configure(main), request(automatic: bool = false) -> bool, cancel() -> bool, confirm(), is_advancing() -> bool, on_morning(day: int), reset(), restore(payload). Owns ledger/state/panel; observes local wallet deltas plus optional trade metadata. One existing clock rollover/Main DaySimulator path; safe review or completed-morning saves only.
- LifeDayEndSheet emits confirmed()/cancelled(). Small ledger_view/ledger_row/farm_warning/tomorrow_card scene pairs and presenter/parts/weather_symbol helpers are under ui/day_end. Typed setters accept read-only snapshots; no UI owns financial/simulation state. See SCENE_CONTRACTS/day_end.md for exact composition/modal behavior.
- SaveService CURRENT_VERSION = 5; migrate_4_to_5(data: Dictionary) -> Dictionary preserves old fields and initializes incomplete history plus idle review. v1–v4 fixtures remain; v5 adds a review example. load_latest preserves subsecond timestamps and prefers later saved clock days on exact ties so a completed morning wins over its preceding review.

## 2D migration status — ISO-1 (2026-11-02)

- Active gameplay is now 2D. Existing domain, clock, inventory, wallet, weather/social services, autoloads, InputMap, fonts and save v4 remain in use. See D36 and scene contracts for reparented view nodes.
- GridMath's Vector3 methods remain pure legacy logical-coordinate/wire adapters for NPC Resources and old saves. IsometricGrid owns every screen/canvas/isometric conversion in VIEW; DOMAIN never receives it.
- C0–C3 generated 3D art/builders/shaders and ChibiAvatar/WorldArtFactory/WorldSeasonFx APIs remain available for historical tooling/tests. They are not instantiated in active gameplay.
- The sixteen mockups are reference-only. ISO-2 now supplies the shared Theme, imported licensed fonts and standalone component gallery; final icon/frame artwork and later HUD layouts remain pending.

## ISO-2 shared UI APIs (2026-11-03)

ISO-3 adds modular active HUD views under `ui/hud/`; these reuse ISO-2's single Theme. See the HUD APIs below and `SCENE_CONTRACTS/hud.md` for exact trees and input semantics.

- `LifeTheme` (`ui/theme/life_theme.gd`): `get_theme() -> Theme` returns the cached `ui/theme/the_life_theme.tres`; `bind(control: Control, variation: StringName = &"") -> void` assigns it; `text_variation(size: int) -> StringName` selects a shared text size. It is not an autoload and callers must not mutate the shared resource.
- `LifeThemeFactory.build() -> Theme` (`ui/theme/theme_factory.gd`) is tooling-only. `tools/build_ui_theme.gd` regenerates the committed resource. Palette tokens, fonts, native Control states, frame margins and generated toggle/slider textures live here rather than per-node StyleBox overrides.
- `LifeButtonBase`: `set_caption(key: StringName) -> void`, `set_preview_state(state: StringName) -> void`; primary/secondary/danger/accent scenes retain native `pressed`. `LifeBtnRoundHud.set_hint(action: StringName)` displays an existing InputMap binding.
- `LifeItemSlot`: `set_item(id: StringName, count: int, name_key: StringName, texture: Texture2D = null) -> void`, `set_state(value: SlotState) -> void`; `slot_requested(item_id: StringName)`. Empty/filled/selected/locked are presentation states; a locked slot emits no request.
- `LifeBanner.set_caption(key)`, `set_tone(tone)`; `LifeProgressBar.set_displayed_value(current: int, maximum: int)`, `set_tone(tone)`; `LifeHeartRow.set_hearts(count: int)`; `LifeKeyHint.set_action(action: StringName)`; `LifeCoinLabel.set_coins(value: int)`; `LifeTabBar.set_active(index: int)` and `tab_requested(index: int)`. Setters return void. Toggle/slider retain native `toggled(bool)` / `value_changed(float)` signals; no service is called by a component.
- `LifePill.set_value(value: int) -> void` updates its localized display; `LifeKeyHint.action_text(action: StringName) -> String` is a static binding formatter. `LifePanelWood`, `LifeTag`, `LifeIconPlaceholder` are reusable localized view surfaces. Exact Inspector fields, scene roots and runtime children are in `docs/SCENE_CONTRACTS/ui_components.md`.
- `LifeUiGallery` (`ui/ui_gallery.gd`): `get_sections() -> Dictionary`, `rebuild() -> void`. Standalone gallery has nine sections, translated sample values and responsive scrolling; `--capture-ui-gallery` requires a graphics renderer. No game/save controller is instantiated.

## ISO-3 HUD APIs (2026-11-03)

- `LifeHudRoot` (`ui/hud/hud_root.gd`): typed `right_column`, `clock_card: LifeHudClockCard`, `wallet_frame`, `coins: LifeCoinLabel`, `toasts: LifeHudToastStack`. Non-interactive shell, no domain data ownership.
- `LifeHudPresenter.configure(main: Node) -> void`, `sync(modal: bool, title: bool) -> void`, `show_message(message: String, icon_id: StringName = &"journal") -> void`: binds real clock/weather/wallet/quest/result signals to views and coordinates visibility. No new autoload/bus signal/save field.
- `LifeHudRegions.apply(main: Node) -> void`: anchors the root's right column/toasts and existing quest/hotbar/shortcut/inspector/prompt adapter roots. Modal rectangles remain in UiLayout.
- `LifeHudClockCard.display(day: int, day_in_season: int, year: int, season_text: String, minute: int, weather_id: StringName, forecast: String) -> void`; `LifeHudClockArc.display(value: int, weather: StringName) -> void`. Displays existing calendar values and uses sunny/cloudy/rain/storm IDs from WeatherState; never advances time.
- `LifeHudQuestCard.display(keys: Array[StringName], completed: Array[bool]) -> void`: actual completed/total with up to three relevant existing checklist steps, no fabricated amounts/rewards. QuestPanel's existing configure/help suppression APIs delegate here.
- `LifeHudToolbar.display(slots: Array[Dictionary], selected_inventory: int, active_tool: StringName, window_start: int) -> void`, `request(index: int) -> void`; signals `tool_requested(tool_id: StringName)`, `item_requested(slot_index: int)`. `LifeHudToolbarSlot.display(key, texture, quantity, selected, title) -> void` is a native Button display. Selection/validation remains in HotbarPanel/ToolActionController.
- HotbarPanel retains `configure`, `register_tool`, `get_selected_slot`, `refresh_readability`, `select_slot` and `slot_selected`. Its `toolbar: LifeHudToolbar` exposes visible buttons. Hidden legacy child paths stay queryable. 1–3 selects tools, 4–8 selects the current five-stack window, 9 selects legacy inventory index 8; selecting any real inventory index from InventoryPanel moves the display window without resizing inventory.
- `LifeHudShortcutBar.create_button(id: StringName, title: String, action: StringName) -> Button` supplies actual inventory/journal/help/pause buttons through HudButtonBar's existing registration API. No calendar/map placeholders or dead shortcuts.
- `LifeHudToastStack.show_message(message: String, icon_id: StringName = &"journal") -> void`, `clear() -> void`: at most two messages, 3 s view-only Timer lifetime; `LifeHudToastCard.display(message, icon_id) -> void`. FeedbackPopup retains configure/show_message/text compatibility and emits local `message_shown(message: String, icon_id: StringName)` into the presenter. Main's existing `_show_toast` delegates to the same stack.
- `LifeHudFrame`, `LifeHudParts` are decoration/construction helpers. Each new HUD script is under 250 lines. Existing Main node paths, Label text adapters, scene IDs, modal APIs, tool/domain services and save v4 remain intact. InputMap changes are documented in INPUT_MAP.

## ISO-1 new view/data APIs

- IsometricWorldConfig (scripts/data/isometric_world_config.gd; data/isometric_world_config.tres) owns tile size, logical map/player regions, spawn/house/shop/bin/debug cells, reach, zoom/follow bounds and placeholder colors/rain limits. Movement speeds are in data/player_2d_config.tres using the existing PlayerConfig Resource type.
- IsometricGrid (scripts/view/isometric_grid.gd) is a VIEW-only RefCounted adapter initialized with a TileMapLayer: cell_to_global(cell: Vector2i) -> Vector2, global_to_cell(point: Vector2) -> Vector2i, screen_to_cell(point: Vector2) -> Vector2i, cell_to_screen(cell: Vector2i) -> Vector2, mouse_cell() -> Vector2i. It delegates to Godot map/local/canvas APIs. Static diamond(size: Vector2) -> PackedVector2Array draws placeholder geometry only, not coordinate projection.
- Player (scripts/player/player.gd) now extends CharacterBody2D. screen_direction(input_vector: Vector2) -> Vector2 replaces camera-yaw direction math (limit/normalize input before y ×0.5); get_cell() -> Vector2i and move_to_cell(cell: Vector2i) -> void use the injected view grid. movement_enabled remains the modal/sleep gate; camera is the child Camera2D, config remains PlayerConfig, map_min/map_max now bound logical cell indices.
- PlaceholderAvatar2D (scripts/view/placeholder_avatar_2d.gd): configure(color, with_hat), configure_profile(profile, customization), set_motion(value), play_tool(tool_id), play_talk(), play_sleep(), show_emotion_bubble(emotion_id, duration) -> bool, get_emotion() -> StringName. action_id exposes transient Idle/Walk/Tool/Talk/Sleep presentation for review. It owns no collision/save state. Cosmetics resolve through the existing catalogue.
- PlaceholderWorld2D (scripts/view/placeholder_world_2d.gd): configure(visual_kind: StringName, title: String, tint: Color) -> void draws non-colliding cottage/market/bin/tree placeholders at ground-level pivots; label/color are view-only. Obstacle polygons own collision separately.
- DataValidator adds validate_isometric_world_config(config: IsometricWorldConfig) -> PackedStringArray, called by tools/validate_data.gd. Invalid tile size/regions/reach/zoom/locations fail the data gate.
- Main is a CanvasLayer at layer 1; WorldCanvas at layer 0 follows the viewport. Existing UI Controls retain their direct Main paths. Legacy capture flags now capture the 2D main scene at their conventional screenshot paths. The v4 position adapter stores legacy cell-center x/y/z, validates old numeric fields and clamps cell bounds. No schema field/version is added.
- WeatherFx is a Node2D observer: configure(weather), get_current_mode() -> StringName, get_active_effect_count() -> int (placeholder effect-group count). WorldTint, windows, rain and seasonal marks do not advance weather/time or mutate crops.

## Documentation-only reference

- `docs/CHIBI_STYLE_PROMPT.md` is a product-owner supplied visual-production reference. It adds no runtime API, save field, resource id, or scene contract; an authorized Chibi milestone must still define and document any resulting public APIs separately.

Format:

```
## ClassName  (path/to/script.gd)
- func name(arg: Type) -> ReturnType        — one-line meaning
- signal name(arg: Type)                    — when it fires
- Notes: invariants, who owns the state, edge cases
```

---

## GridMath  (scripts/util/grid_math.gd)
- static func world_to_cell(position: Vector3) -> Vector2i — converts a world XZ position to a logical cell using floor-safe division
- static func cell_to_world(cell: Vector2i) -> Vector3 — returns the center of a logical cell
- static func footprint_cells(origin: Vector2i, size: Vector2i, rotation_steps: int) -> Array[Vector2i] — returns occupied cells for a 90-degree footprint rotation
- Notes: legacy XZ conversions remain pure adapters for saved/NPC coordinates; active canvas conversion uses IsometricGrid. Footprints remain logical Vector2i cells.

## GrayBoxWorld  (scripts/view/gray_box_world.gd)
- func pick_cell(screen_position: Vector2) -> Variant — converts a viewport point through Ground's canvas transform/local_to_map and returns a Vector2i cell
- func get_day_night_lighting(minute: int) -> Dictionary — returns the sampled lighting values currently used by the world view
- Notes: placeholder view only; it owns no gameplay state.

## DayNightProfile  (scripts/data/day_night_profile.gd)
- func sample(minute: int) -> Dictionary — interpolates the data keyframes for sun, moon, ambient and sky lighting
- Notes: pure data/resource sampling; the view applies the result to world nodes.

## WeatherState  (scripts/domain/weather_state.gd)
- func advance_day(day_index: int) -> void — consumes the saved forecast and rolls the next forecast entry
- func force_weather(weather_id: StringName) -> void — selects a valid data-defined weather for debug testing
- func is_rainy() -> bool — reports whether today's weather automatically waters crops
- func is_stormy() -> bool — reports whether storm presentation should flash
- func serialize() -> Dictionary — saves seed, current weather, forecast and committed day_index (v12)
- func deserialize(data: Dictionary) -> void — restores saved weather without re-rolling
- signal weather_changed(weather_id: StringName) — emitted when today's weather changes
- signal forecast_updated(forecast: Array[StringName]) — emitted when the forecast changes

## SeasonData  (scripts/data/season_data.gd)
- season_id: StringName — stable season identifier
- days_in_season: int — data-defined season length
- grass_color: Color — placeholder grass tint for the season
- Notes: four shipped resources define spring, summer, autumn and winter.

## WeatherProfile  (scripts/data/weather_profile.gd)
- func get_entry(weather_id: StringName) -> Dictionary — returns data-defined probability and visual effects

## CameraRig  (scripts/view/camera_rig.gd)
- func set_target(target_node: Player) -> void — assigns the node followed by the rig
- func get_pan_offset() -> Vector2 — returns the current world-space camera drag-pan offset
- func reset_pan() -> void — resets the drag-pan offset to Vector2.ZERO
- func is_panning() -> bool — reports whether Right/Middle Mouse drag panning is active
- Notes: drives the player's child Camera2D with data-owned smoothing, center bounds, documented zoom actions (`=` / `-` and Mouse Wheel Up/Down over the map), and Right/Middle Mouse drag-panning (`_pan_offset` auto-returns smoothly when the player walks or on double-right-click).

## GameClock  (scripts/core/game_clock.gd)
- func advance_real_seconds(seconds: float) -> void — converts real seconds into in-game minutes
- func advance_minutes(minutes: int) -> void — advances the in-game clock and emits hour/time signals
- func sleep_to_morning() -> void — starts the next day at 06:00
- func can_sleep() -> bool — returns true only from 20:00 through 02:00
- func try_sleep() -> bool — advances to the next morning only when sleeping is allowed
- func is_sleeping() -> bool — returns whether the overnight sleep transition is active
- func set_time(hour: int, minute_in_hour: int) -> void — sets the debug clock time, clamped to the playable day range
- func set_speed(multiplier: float) -> void — sets the real-time clock multiplier; zero pauses advancement
- func get_hour() -> int — returns the displayed in-game hour in the 0–23 range; overnight internal minutes wrap after 24:00
- func get_minute_in_hour() -> int — returns the minute within the current hour
- func get_day_in_season() -> int — returns the one-based day within the current season
- func format_time(total_minutes: int) -> String — formats any internal clock minute as 24-hour `HH:MM` in the 00:00–23:59 range
- func serialize() -> Dictionary — returns the clock save payload
- func deserialize(data: Dictionary) -> void — restores and validates the clock save payload
- signal time_changed(day_index: int, minute: int) — emitted after the clock changes
- signal day_started(day_index: int) — emitted after sleeping or reaching the day cutoff
- signal sleep_started()                                 — emitted when an allowed sleep begins
- signal sleep_finished(day_index: int)                  — emitted exactly once at 06:00 after sleeping
- Notes: day 1 starts at 06:00; 12 real minutes represent one 24-hour game day. Awake rollover occurs at internal 26:00; sleeping continues through internal 26:00 to 30:00 and finishes at displayed 06:00.

## InteractionPrompt  (scripts/components/interaction_prompt.gd)
- func show_prompt(prompt_text: String) -> void — displays a reusable interaction message
- func hide_prompt() -> void — hides the interaction message
- Notes: view-only component; future tools, NPCs and interactables can use the same prompt surface.

## InventoryState  (scripts/domain/inventory_state.gd)
- func can_add_item(item_id: StringName, quantity: int) -> bool — checks whether the entire quantity fits without changing inventory
- func add_item(item_id: StringName, quantity: int) -> int — adds as many items as capacity and stack limits allow; returns the quantity added
- func remove_item(item_id: StringName, quantity: int) -> bool — removes the requested quantity only when enough exists
- func has_item(item_id: StringName, quantity: int = 1) -> bool — checks whether the requested quantity exists
- func get_quantity(item_id: StringName) -> int — returns the total quantity across all stacks
- func get_slots() -> Array[Dictionary] — returns a deep copy of the current slots
- func clear() -> void — removes all item stacks
- func serialize() -> Dictionary — returns capacity and slot data for saves
- func deserialize(data: Dictionary) -> void — restores valid registered item stacks
- signal inventory_changed(slots: Array[Dictionary]) — emitted after the slot list changes
- signal item_added(item_id: StringName, quantity: int) — emitted after items are added
- signal item_removed(item_id: StringName, quantity: int) — emitted after items are removed
- Notes: item definitions come from DataRegistry; each occupied stack uses one capacity slot.

## CropData  (scripts/data/crop_data.gd)
- Current shipped data rule: `yield_qty` is positive and every starter crop yields two product items per completed harvest.
- crop_id: StringName — stable crop identifier used for all saved state and registry lookups
- display_name_key: StringName — translation key for the crop name
- seed_item: StringName — item required to plant the crop
- product_item: StringName — item produced when harvested
- yield_qty: int — number of product items produced on a completed harvest
- growth_days: int — number of watered days required to mature
- water_need: int — target watering requirement for the crop lifecycle
- seasons: PackedStringArray — seasons in which the crop can grow
- Notes: this is a data Resource; scripts must not contain crop balance numbers or rules.

## FarmGridState  (scripts/domain/farm_grid_state.gd)
- func get_plot(cell: Vector2i) -> Dictionary — returns a defensive copy of one plot's current state
- func till_cell(cell: Vector2i) -> bool — tills an unworked plot; returns false if the plot is already tilled
- func plant_crop(cell: Vector2i, crop_id: StringName) -> bool — plants a crop on a tilled empty plot; returns false if invalid
- func water_cell(cell: Vector2i) -> bool — marks the plot as watered when it is planted and needs water
- func water_all_crops() -> void — waters every planted crop, used by rainy mornings
- func mark_out_of_season() -> void — marks crops outside their allowed season as withered
- func clear_withered(cell: Vector2i) -> bool — removes a withered crop from a plot
- `withered_days: int` is persisted per crop for the two-consecutive-day death rule; missing legacy values default to zero.
- func advance_day() -> void — advances cared-for/water-free living crops, updates consecutive dryness/terminal withering, then resets moisture
- func can_harvest(cell: Vector2i) -> bool — returns true only for a mature non-withered crop
- func get_growth_remaining(cell: Vector2i) -> int — returns the number of watered growth days remaining
- func harvest_cell(cell: Vector2i) -> Dictionary — removes the crop and returns the harvest payload
- func get_harvest_payload(cell: Vector2i) -> Dictionary — previews the complete harvest result without changing the plot
- func serialize() -> Dictionary — saves plot state for save/load
- func deserialize(data: Dictionary) -> void — restores plot state from the save payload
- signal plot_changed(cell: Vector2i) — emitted whenever a plot mutates
- Notes: does not touch UI; all view updates listen to signals from the world state.

## AudioService  (scripts/core/audio_service.gd)
- func play_sound(sound_id: StringName) -> void — plays the original `assets/audio/<id>.ogg` or `.wav` effect when present; missing files are silent and the player's saved effects-volume preference is applied at playback
- func get_sound_path(sound_id: StringName) -> String — returns the resolved OGG/WAV asset path or an empty string

## FarmView  (scripts/view/farm_view.gd)
- func get_cell_view(cell: Vector2i) -> Polygon2D — returns the placeholder soil view
- func get_crop_view(cell: Vector2i) -> Sprite2D — returns the crop root view
- func get_crop_label(cell: Vector2i) -> Label — retains the legacy billboard growth-status label for compatibility
- Notes: label text still refreshes from `FarmGridState.plot_changed`, but the label stays hidden because CropInspector provides the readable status/timer surface.

## FeedbackPopup  (scripts/view/feedback_popup.gd)
- func show_message(message: String) -> void — displays a short animated result message

## SaveService  (scripts/core/save_service.gd)
- func save_game(payload: Dictionary, slot: int = 1) -> bool — writes the current v12 domain envelope atomically with three backups; weather day is validated against clock (see D86 above)
- func load_game(slot: int = 1) -> Dictionary — loads, validates and migrates a save; returns an empty dictionary for missing/corrupt/future saves
- func delete_save(slot: int = 1) -> void — removes one save slot
- func has_save(slot: int = 1) -> bool — reports whether a valid save exists
- func load_latest() -> Dictionary — loads the newest valid save from slots 0 and 1
- func get_latest_summary() -> Dictionary — returns farm name, day and saved timestamp for the newest save
- `migrate_3_to_4(data: Dictionary) -> Dictionary`: adds empty social defaults without replacing onboarding or any previous payload fields. v1/v2 continue through the existing migration steps; missing wallet defaults to 100 coins. Golden v1/v2/v3 are retained.
- Social payload contains NPC quest state, merchant seed/consumed days, friendship, heard dialogue, last talk days and cell strings. Main restores it after clock/weather; routes are rebuilt.

## TutorialQuestState  (scripts/domain/tutorial_quest_state.gd)
- func is_step_completed(step_index: int) -> bool — checks one onboarding milestone
- func is_complete() -> bool — returns true when all seven farming/economy milestones are complete
- func serialize() -> Dictionary — saves onboarding progress
- func deserialize(data: Dictionary) -> void — restores onboarding progress
- signal step_changed(step_index: int, completed: bool) — emitted when a domain event completes a step
- signal all_completed() — emitted once all farming milestones are complete
- Notes: listens to typed Events and GameClock.sleep_finished; the view only renders this state.

## TutorialPanel  (scripts/view/tutorial_panel.gd)
- func configure_modal(close_other_modal: Callable, set_quest_visible: Callable = Callable()) -> void — wires modal exclusivity and quest suppression
- func open_help() -> void — opens the controls guide and locks player movement
- func close_help() -> void — closes the guide and persists the opt-out checkbox
- func is_help_open() -> bool — reports whether the guide is visible
- func configure_modal(close_other_modal: Callable) -> void — closes another modal before opening the guide
- Notes: controls are formatted from InputMap bindings; player-facing text uses localization.

## HotbarPanel  (scripts/view/hotbar_panel.gd)
- func configure(inventory: InventoryState) -> void — binds the hotbar to inventory state
- func get_selected_slot() -> Dictionary — returns the selected inventory slot
- signal slot_selected(slot_index: int) — emitted when an occupied inventory slot is selected
- Notes: each slot is a contained key/name/quantity layout; empty quantities are omitted and selected slots use the Button focus/pressed style.

## QuestPanel  (scripts/view/quest_panel.gd)
- func configure(state: TutorialQuestState) -> void — binds checklist rendering to domain state
- Notes: hides itself after all five onboarding steps are complete.

## FarmView  (scripts/view/farm_view.gd)
- func configure(farm_state: FarmGridState) -> void — binds the placeholder view to the farm domain state
- func get_cell_view(cell: Vector2i) -> Polygon2D — returns the visible soil placeholder for a cell
- func get_crop_view(cell: Vector2i) -> Sprite2D — returns the crop placeholder for a cell
- func pick_crop(screen_position: Vector2, camera: Camera2D) -> Variant — selects transformed visible crop sprite rectangles, resolving overlap by ground y, or returns null
- setup(world: GrayBoxWorld) binds the view grid before configure. Terrain lives in WorldCanvas/Farmland; crop sprites under Objects share actor y-sort origins; effects live under WorldCanvas. Plot rules remain in FarmGridState; hidden localized Labels preserve the status API.

## CropPresentation  (scripts/view/crop_presentation.gd)
- static func render(crop: Sprite2D, crop_id: StringName, growth_ratio: float, crop_color: Color, withered: bool, watered: bool, cell: Vector2i) -> void — assigns a cached replaceable 2D stage texture from existing plot data
- static func clear(crop: Sprite2D) -> void — clears only the view texture/metadata of an empty crop
- Notes: active ISO-1 art uses stage/color/moisture placeholder textures for sprout/growing/mature/wilted states. Generated crop-family scenes remain archived. No crop state, growth timer, inventory or save rule is owned here.

## WorldArtFactory — historical 3D art tooling (scripts/view/world_art_factory.gd)
- static func replace_anchor_visual(anchor: MeshInstance3D, asset_id: StringName, season: StringName = &"spring") -> bool — replaces only an existing visual anchor's mesh children without moving the anchor, marker or collision
- static func create_asset(asset_id: StringName, season: StringName = &"spring") -> Node3D — instantiates a stable generated C3 asset with its view-only seasonal material treatment
- static func apply_season(root: Node, season: StringName) -> void — recolors a C3 visual tree only; it never changes gameplay or saved state
- Legacy `build_cottage`, `build_market`, `decorate_shipping_bin`, `add_decorative_cottage`, `add_ground_dressing` and `add_rock_cluster` remain compatible wrappers for existing callers.
- Notes: no marker, collision, interaction or gameplay ownership changes. Generated source scenes retain C0 shader data; C3 applies local readable materials to toon pieces under the existing world lighting and preserves foliage/water shader behavior.

## WorldArtCatalog  (scripts/data/world_art_catalog.gd)
- func get_model_path(asset_id: StringName) -> String — resolves a stable generated C3 scene path
- func get_asset_kind(asset_id: StringName) -> StringName / func get_asset_role(asset_id: StringName) -> StringName — resolves presentation-only category and palette role
- func get_placements(asset_id: StringName) -> Array[Vector3] / func get_season_effect_color(season: StringName) -> Color — returns passive exterior layout/effect data
- func validate() -> PackedStringArray — validates IDs, category coverage, palette roles, finite placements and the bounded ambient cap
- Notes: catalog data contains no collision, navigation, farm, economy, schedule, time/weather authority or save fields.

## WorldSeasonFx — historical 3D view (scripts/view/world_season_fx.gd)
- func configure(weather_state: Object, catalog: Resource) -> void — observes existing GameClock/WeatherState presentation signals only
- func get_active_effect_count() -> int / func get_current_mode() -> StringName — review/test visibility into the bounded visual state
- Notes: spring petals, summer day birds/butterflies or night fireflies, autumn leaves, winter snow and rain ripples are deterministic view details capped by `WorldArtCatalog`; they never alter clock, weather, save or gameplay randomness.
- Notes: the gray-box scene places the 6×6 grid inside the 6 m × 6 m `FarmPlot`; target green means reachable and red means outside tool reach.

## SoilPresentation  (scripts/view/soil_presentation.gd)
- static func render(soil: Polygon2D, tilled: bool, watered: bool, cell: Vector2i) -> void — adds only view-level furrows and a transparent moisture sheen; FarmGridState remains the source of truth

## ToolData  (scripts/data/tool_data.gd)
- tool_id: StringName — stable tool identifier
- action_id: StringName — domain action selected by the tool
- reach_cells: int — maximum logical-cell reach
- item_id: StringName — optional inventory item backing the tool

## ToolAction  (scripts/domain/tool_action.gd)
- static func is_in_reach(player_cell: Vector2i, target_cell: Vector2i, reach_cells: int) -> bool — checks Chebyshev grid reach
- static func apply(tool_id: StringName, farm_state: FarmGridState, cell: Vector2i, crop_id: StringName) -> bool — applies hoe, water or seed action
- Notes: pure domain dispatcher; inventory consumption and UI locks are handled by the view controller.

## ToolActionController  (scripts/view/tool_action_controller.gd)
- Continuous use rule: holding the existing left-use input can seed, water or harvest one time for every newly crossed reachable cell. A default hoe click on a crop still opens CropInspector.
- func configure(world: GrayBoxWorld, farm_state: FarmGridState, inventory: InventoryState, farm_view: Node, player: Player, inventory_panel: InventoryPanel, debug_menu: DebugMenu) -> void — wires world targeting and farm action state
- func select_tool(tool_id: StringName) -> void — selects a data-defined tool action
- func select_seed() -> void — selects seed planting
- func get_selected_tool() -> StringName — returns the selected action

## ToolDragStroke  (scripts/view/tool_drag_stroke.gd)
- func handle(event: InputEventMouse, world: GrayBoxWorld, farm_view: Node, farm_state: FarmGridState, selected_tool: StringName, crop_inspector: CropInspector, can_apply: Callable, apply_cell: Callable) -> bool — view-only pointer adapter that deduplicates visited cells and delegates work to ToolActionController

## DaySimulator  (scripts/domain/day_simulator.gd)
- func simulate_day(farm_state: FarmGridState) -> void — advances watered planted crops once and dries plots
- Notes: called by the main game flow at GameClock.day_started; the domain owns no nodes or UI.

## ItemData  (scripts/data/item_data.gd)
- item_id: StringName — stable data identifier
- display_name_key: StringName — translation key rendered through `tr()`
- max_stack: int — maximum quantity in one slot

## Localization  (scripts/core/localization.gd)
- func apply_default_locale() -> void — selects Vietnamese for a new session without a settings override
- func load_translations() -> bool — loads the Vietnamese and English CSV translations
- Notes: player-facing item and crop names must reference translation keys rather than storing display text in Resources.

## Settings  (scripts/core/settings.gd)
- func get_locale() -> String — returns the saved locale, defaulting to Vietnamese
- func set_locale(locale: String) -> void — persists and applies a locale
- func get_music_volume() -> float — returns saved music volume
- func set_music_volume(volume: float) -> void — clamps and persists music volume
- func get_effects_volume() -> float — returns saved effects volume
- func set_effects_volume(volume: float) -> void — clamps and persists effects volume

## PauseMenu  (scripts/view/pause_menu.gd)
- func open() -> void — pauses the game clock and locks player movement
- func close() -> void — closes the overlay; modal owner restores the prior clock hold and movement gate
- func toggle() -> void — toggles the pause overlay

## StartMenu  (scripts/view/start_menu.gd)
- func configure(new_game_callback: Callable, continue_callback: Callable, exit_callback: Callable) -> void — wires start-screen actions

## DataValidator  (scripts/core/data_validator.gd)
- static func validate_item_resources(resources: Array[Resource]) -> PackedStringArray — validates resource presence, unique snake_case IDs and positive stack limits
- static func validate_item_paths(paths: Array[String]) -> PackedStringArray — loads and validates declared data paths

## DebugMenu  (scripts/view/debug_menu.gd)
- func configure(player_node: Player) -> void — connects the developer menu to the active player
- func register_action(label: String, callback: Callable) -> void — adds an extensible developer action button
- Notes: exists only in debug builds; Ctrl+M toggles it and disables player movement while open.

## HudButtonBar  (scripts/view/hud_button_bar.gd)
- func register_button(button_id: StringName, label: String, callback: Callable, enabled_check: Callable = Callable()) -> Button — registers a reusable HUD button and optional enabled-state rule
- func set_button_active(button_id: StringName, active: bool) -> void — updates the visual toggle state of a registered button
- Notes: consumes mouse input within its panel; buttons are registered by systems rather than hardcoded in the bar.

## InventoryPanel  (scripts/view/inventory_panel.gd)
- func configure(inventory, player: Player) -> void — connects the view to the inventory domain state and player input gate
- func toggle_inventory() -> bool — opens or closes the inventory unless sleeping
- signal inventory_toggled(is_open: bool) — emitted after the inventory visibility changes
- Notes: keyboard I and the HUD button call the same toggle method; sleeping disables opening.

## HotbarPanel  (scripts/view/hotbar_panel.gd)
- func configure(inventory: InventoryState) -> void — binds the hotbar to inventory change signals
- func get_selected_slot() -> Dictionary — returns the selected inventory slot without mutating inventory
- signal slot_selected(slot_index: int) — emitted when a non-empty slot is selected
- Notes: redraws after selection and removes old controls safely; UI selection never changes inventory quantities.

## GrayBoxWorld interaction helpers  (scripts/view/gray_box_world.gd)
- static func is_player_near_interactable(player_cell: Vector2, target_cell: Vector2, reach: float) -> bool — checks logical-cell Euclidean distance against data-owned reach
- signal shipping_bin_interacted() — emitted when the player presses E within reach of the shipping bin
- signal seed_shop_interacted() — emitted when the player presses E within reach of the seed shop

## WalletState  (scripts/domain/economy/wallet_state.gd)
- func get_coins() -> int — returns the current non-negative coin balance
- func add_coins(amount: int, reason: StringName = &"") -> void — increments coins, enforces non-negativity, emits coins_changed and Events.coins_changed
- func remove_coins(amount: int, reason: StringName = &"") -> bool — atomically spends coins if sufficient balance exists
- func can_afford(amount: int) -> bool — returns true if current balance is >= amount
- func serialize() -> Dictionary — encodes {"coins": coins}
- func deserialize(data: Dictionary) -> void — loads coins and emits update signal
- signal coins_changed(new_total: int, delta: int, reason: StringName) — emitted on any balance change

## WalletHud  (scripts/view/wallet_hud.gd)
- func configure(wallet) -> void — binds the top-left HUD coin counter to wallet state and signal updates

## Phase 8 quest and data APIs
- `QuestData` (`scripts/data/quest_data.gd`): quest/giver ids, localized title/description keys, item requirement, coin and item reward.
- `QuestManager` (`scripts/domain/quests/quest_manager.gd`): register/get/accept quests, query active/completed ids, `can_deliver`, `confirm_delivery`, serialize/deserialize; local quest_accepted and quest_completed signals. Preview checks exact post-removal capacity; confirmation rejects shortages, missing wallet, invalid data and repeated/reentrant payouts.
- `NpcData` (`scripts/data/npc_data.gd`): id/name key, home, schedule, rain behavior, appearance and friendship data.
- `NpcScheduleEntry.applies_to(season: StringName, minute: int) -> bool`: data-defined seasonal time window.
- `WorldLocations`: named positions, navigation region and solid rectangles; `has_location` and `get_location_position`.
- `DataRegistry.get_quest(quest_id: StringName) -> Resource`, `get_all_quests() -> Array[Resource]`: registered delivery quest resources.
- `DataValidator.validate_quest_resources(quests, items)` / `validate_quest_paths(quest_paths, item_paths) -> PackedStringArray`: checks ids, references and nonnegative requirements/rewards.

## MerchantService (scripts/domain/quests/merchant_service.gd)
- `get_offer(day: int, season: StringName) -> MerchantOfferData`: pure seeded quote from eligible resource templates; no mutation of item prices.
- `confirm_trade(day, season, available, inventory, wallet) -> bool`: explicit confirmed finite trade, checking wallet/inventory and current visit availability.
- `is_consumed(day: int) -> bool`, `serialize() -> Dictionary`, `deserialize(data: Dictionary) -> void`: saved seed and consumed days; load cannot restock a completed trade.
- `MerchantOfferData`: offer/item ids, discount/request kind, int unit_price/quantity and eligible seasons.
- `DetRandom.make_rng(world_seed, day, tag) -> RandomNumberGenerator`: stable integer seed mixing; TAG_MERCHANT stream.

## NpcSchedule / NpcSocialState (scripts/domain/quests/)
- `NpcSchedule.configure(data: NpcWorldData)`, `destination(npc, day, minute, season, rainy) -> StringName`: rain and sampled moon energy override seasonal/weekday schedule; returns home when no work block applies.
- `location_cell(location_id) -> Vector2i`, `route(from_cell, to_cell) -> Array[Vector2i]`: GridMath conversion and AStarGrid2D paths avoiding declared solids.
- `NpcSocialState.configure(data)`, `get_npc(id)`, `get_dialogue(id, season)`, `talk(id, day, season)`: conditional data dialogue, heard ids, daily capped friendship.
- `update_schedule(day, minute, season, rainy)`, `advance_step(npc_id)`, `is_indoors(npc_id)`: authoritative cell movement; view only animates between cells.
- `serialize()/deserialize()`: quests, daily merchant stock, friendship, heard lines, last talk days and cells; routes rebuilt from current conditions. `changed()` is local.
- `NpcWorldData` (`data/npcs/phase8_world.tres`): NPC/dialogue/offer resources, locations, blocked rectangles, lighting profile, night threshold, week length and interaction distance.

## Phase 8 views (scripts/view/)
- `NpcSystem.configure(main: Node, dialogue: NpcPanel, journal: NpcPanel) -> void`: connects clock/weather, actors, shared state, and debug actions.
- `open_journal()`, `open_dialogue(npc_id: StringName)`, `close_panels()`, `is_open() -> bool`: modal lifecycle and input gate; dialogue requires a nearby outdoor NPC. Clock pause and HUD visibility restore on close.
- `restore(data: Dictionary) -> void`: restore domain, rebuild schedule, synchronize placeholder positions/visibility. Main writes `state.serialize()` only at safe points; exit closes the modal first.
- `NpcPanel.show_content(title: String, body: String, actions: Array[Dictionary] = []) -> void`: scrollable localized body/buttons; `close_requested()` is local.
- `NpcActor.configure(social: NpcSocialState, npc: NpcData)`, `reset_position()`: interpolate the domain route through an injected VIEW IsometricGrid, hide on arrival home, display a localized Label/prompt. Actors/homes render under world Objects; NpcSystem.actors/homes dictionaries replace their old Main/NpcSystem visual paths.
- `DataValidator.validate_npc_world(data, items, quests, locale_paths) -> PackedStringArray`: unique ids, references, schedule bounds, reachable destinations, friendship limits, merchant prices and translation coverage. tools/validate_data.gd includes this gate.

## UiCoordinator / UiLayout (scripts/view/ui_coordinator.gd, ui_layout.gd)
- `UiCoordinator.configure(main: Node) -> void`: registers the nine existing modal surfaces, applies the runtime theme/layout, and creates a view-only backdrop; no autoload or scene edits.
- `close_active() -> void`, `get_active_panel() -> Control`: closes through each panel's existing API and coordinates visibility, clock/player locking, prompts and secondary HUD. Start menu cannot be bypassed by gameplay shortcuts.
- `UiLayout.apply(main: Node) -> void`, `reflow(main: Node) -> void`: assigns the shared Theme, retains existing modal rectangles and delegates active HUD anchors to LifeHudRegions. Deferred reflow follows minimum-size changes; no per-node StyleBox skin is built here.
- `HotbarPanel.refresh_readability() -> void`: refreshes the modular eight-slot toolbar/caption. Hidden backing selectors retain legacy child-path compatibility. `select_slot(slot_index: int) -> void` selects any inventory stack and follows its five-stack window. InventoryPanel still shows all items in a scrollable list with explicit Select buttons and a fixed close header. Current key mapping is in INPUT_MAP and the ISO-3 API section above.
- Modal shortcut contract: B/I/Tab/H/J/Ctrl+M replace the active modal; Esc closes it; E still closes seed shop/shipping bin. Help appears after New Game, separately from the start menu. Regular modals pause the game clock; debug menu preserves its clock controls.
- Backdrop is the first Main child for mouse hit order; render z_index alone is insufficient. Mouse events pass to GUI before key filters; mouse regression tests use press/release pairs in a separate SubViewport.

## Chibi presentation and entry flow (scripts/view/)
- `UiIcons.get_icon(icon_id: StringName) -> Texture2D`, `for_item(item_id: StringName) -> Texture2D`, `decorate(button: Button, icon_id: StringName, icon_only: bool = false) -> void`: caches 22 declared original SVG assets and maps current items to crop icons; labels/tooltips remain localized.
- `TitleBackdrop` (TextureRect): non-interactive generated illustration with slow pointer-relative decorative motes, visible only while StartMenu is visible. Main constructs it in code.
- `StartMenu.apply_chibi_style() -> void`, `refresh_continue() -> void`: outlined/breathing title treatment, keyboard-first primary-form focus, and consistent slot-0/slot-1 Continue availability. Existing configure callback API remains compatible.
- `ChibiCursor` (`scripts/view/chibi_cursor.gd`): view-only original code-drawn paw/tool cursor. `set_ui_hovered`, `set_pressed`, `set_tool_mode`, `get_visual_mode` and `get_tool_mode` only select presentation; it writes no input, state or save data.
- `ChibiUiMotion` (`scripts/view/chibi_ui_motion.gd`): `configure(main)`, `refresh()` and `get_cursor()` bind existing focusable Controls to small hover/press/open tweens, keyboard focus and the cursor. It observes actual Godot Control signals and owns no modal/gameplay state.
- `Main --capture-chibi-ui` is a private normal-renderer review argument. It creates title/HUD PNGs in `screenshots/chibi-ui/`, does not restore gameplay state from or write a player save, and exits after capture.
- Historical ChibiAvatar.configure remains available to generated-art tooling/tests; active player/NPC rendering uses PlaceholderAvatar2D.
- WorldPresentation.configure(main: Node) -> void creates/recolors 2D placeholders at data-owned interaction cells and safe C3 tree catalogue placements. configure_player_appearance(selection) applies existing cosmetic data; get_player_avatar() -> PlaceholderAvatar2D, get_world_art_root() -> Node2D (WorldArt2D, nested y-sort), get_season_fx() -> Node (active WeatherFx). No collision or gameplay state is created here.
- `HotbarPanel._unhandled_input` handles existing hotbar_1 through hotbar_9 only while visible. Full item selection/caption and 12-slot inventory state are preserved.

## CropInspector / compact HUD (scripts/view/crop_inspector.gd)
- `configure(farm: FarmGridState) -> void`, `show_cell(cell: Vector2i) -> void`: binds existing farm state and shows one click-selected crop without pausing time or mutating state. Local `action_requested(cell: Vector2i, action_id: StringName)` delegates Water/Harvest to the existing controller.
- `get_remaining_minutes() -> int`: game-minute estimate to the remaining growth-day morning boundary, assuming daily watering and a suitable season. Derived from FarmGridState.get_growth_remaining and GameClock constants; no new timer, growth path or saved state. Ready/withered plants show explicit status instead.
- `FarmView.pick_crop(screen_position: Vector2, camera: Camera2D) -> Variant`: uses transformed sprite rectangles and a small click margin to select the frontmost crop (or null). Ground picking remains the fallback. `get_crop_label` retains its API/text, but tiny repeated world labels are hidden.
- `ToolActionController.configure_crop_inspector(inspector)`, `perform_crop_action(cell, action_id)`: click inspection precedes mouse tool use; explicit panel actions validate player input/reach and reuse watering/harvest/inventory logic. Inspection itself never consumes items or harvests.
- `InventoryPanel.slot_selected(slot_index: int)`: emitted on a row's localized Select button; Main forwards it to HotbarPanel and inventory closes. Selection preserves all item quantities.

## ShippingBinPanel  (scripts/view/shipping_bin_panel.gd)
- func configure(inventory, wallet, player: Player, feedback: Node = null) -> void — binds inventory and wallet
- func open() -> void / func close() -> void / func toggle() -> void — modal visibility controls; locks player movement
- func is_open() -> bool — query panel open state
- signal item_sold(item_id: StringName, quantity: int, total_price: int) — emitted on successful sale

## C0 chibi art foundation
- `ArtPalette` (`scripts/data/art_palette.gd`): Resource owning stable palette id, chibi scale/head-ratio values, per-category triangle budgets and four-season role colors. `get_color(role, season)`, `get_triangle_budget(kind)` and `validate()` are the public data API.
- `DataValidator.validate_art_palette_path(path: String) -> PackedStringArray`: loads an art palette Resource and returns its validation messages; `tools/validate_data.gd` validates `chibi_valley.tres` in the normal data gate.
- `ChibiMaterialFactory` (`scripts/view/chibi_material_factory.gd`): view-only opt-in factory. `get_palette()`, `get_shader_paths()`, `get_material_paths()` and `create_material(shader_id, role, season)` expose the generated shader/material suite without mutating shared Resources or gameplay state.
- `ChibiMeshBuilder` (`tools/art/chibi/chibi_mesh_builder.gd`): deterministic tooling-only primitive builders for calibration character, prop, crop, building and tree models. It accepts the palette Resource and returns a grounded `Node3D` tagged with `art_kind`.
- `ChibiMeshAudit` (`tools/art/chibi/chibi_mesh_audit.gd`): tooling-only `triangle_count(root)`, `collect_meshes(root)` and `validate_model(root, triangle_budget)` checks for mesh presence, bounds, finite values, ground pivot and triangle budget.
- `ChibiArtReview` / `ChibiArtLineup` (`tools/art/chibi/art_review.gd`, `tools/art_lineup.tscn`): deterministic four-angle/day-night calibration layout. `tools/art_review.bat` writes ignored normal-renderer contact sheets under `screenshots/chibi-core/`; it is not a gameplay scene.

## SeedShopPanel  (scripts/view/seed_shop_panel.gd)
- func configure(inventory, wallet, player: Player, feedback: Node = null) -> void — binds inventory, wallet and player
- func open() -> void / func close() -> void / func toggle() -> void — modal visibility controls with seasonal seed filtering
- func is_open() -> bool — query panel open state
- func try_buy_item(item_id: StringName, quantity: int) -> bool — performs atomic purchase checking funds and inventory capacity
- signal item_purchased(item_id: StringName, quantity: int, total_price: int) — emitted on successful purchase

## C1 chibi characters

- `CharacterAppearanceData` (`scripts/data/character_appearance_data.gd`): a data-owned visual recipe. `to_builder_dictionary() -> Dictionary` supplies a detached builder profile and `validate() -> PackedStringArray` validates ids, colors and scale.
- `CharacterAppearanceCatalog` (`scripts/data/character_appearance_catalog.gd`): owns the player base profile, An/Bac Lam/Linh/Minh recipes, dog calibration recipe and selectable player choices. `get_npc_appearance(id)`, `get_default_player_appearance()`, `get_player_customization()`, `normalize_player_customization(selection)`, `resolve_player(selection)` and `validate()` are the public API. A normalized selection contains only `hair_style`, `skin_index`, `hair_color_index` and `outfit_color_index` and is safe in `profile.appearance`.
- `DataValidator.validate_character_catalog_path(path) -> PackedStringArray` validates the C1 catalogue in the normal data gate. `tools/validate_data.gd` invokes it for `data/art/characters/chibi_character_catalog.tres`.
- `ChibiCharacterModelBuilder` (`tools/art/chibi/chibi_character_builder.gd`) is deterministic tooling/runtime presentation support. `build_character(profile, customization = {}) -> Node3D` and `build_dog(profile) -> Node3D` create grounded C0-material model rigs. Its stable generated outputs are under `assets/generated/models/characters/`; regenerate them with `tools\build_chibi_characters.bat`.
- Historical ChibiAvatar (scripts/view/chibi_avatar.gd) remains view-only for archive tooling; active avatars are PlaceholderAvatar2D. In addition to legacy `configure`, its public API is `configure_profile`, `apply_customization`, `set_emotion`, `show_emotion_bubble`, `play_tool`, `play_sleep`, `play_talk`, `stop_action`, `set_facing_direction`, `get_model`, `get_face` and `get_animation_player`. It owns the six C1 `AnimationPlayer` clips but never owns player/NPC state, collision or saves.
- `CharacterFace` (`scripts/view/character_face.gd`) accepts `configure(profile)`, `set_emotion(id)`, `set_blinking(value)` and `set_talk_phase(phase)`. Valid emotions are `normal`, `happy`, `surprised`, `sad`, `sleep` and `talk`.
- `EmotionBubble` (`scripts/view/emotion_bubble.gd`) is transient, view-only feedback: `show_emotion(id, duration)` and `hide_emotion()`. Valid bubble ids are heart, surprise, question, music, sweat and sleep.
- `WorldPresentation.configure_player_appearance(selection)` reconfigures only the child PlaceholderAvatar2D; `get_player_avatar()` exposes that view anchor. `NpcActor.play_talk()` and `show_emotion(id)` are presentation helpers called after existing dialogue eligibility checks.
- `StartMenu` emits `appearance_selected(appearance: Dictionary)` before its unchanged two-argument New Game callback. `get_appearance_selection()` returns the validated normalized selector state.
- `tools\art_review_characters.bat` writes C1 day/night contact sheets and calls `tools\capture_chibi_characters.bat`. The latter starts the configured project main scene with `--capture-chibi-characters`; the flag is review-only, exits without a save write, and is not a player-facing input action.

## C2 chibi farming

- `ItemData` (`scripts/data/item_data.gd`) has optional view-only `model_path` and `icon_path` fields. They point to generated local art only; inventory stacks, prices, crop references and save payloads continue to use the stable `item_id`.
- `FarmingArtCatalog` (`scripts/data/farming_art_catalog.gd`) owns crop-family mapping, growth-stage scales, tool ids, soil/dew/sparkle/effect colors and generated asset path helpers: `get_crop_scene_path`, `get_crop_family`, `get_stage_scale`, `get_tool_scene_path`, `get_tool_icon_path` and `validate`.
- `DataValidator.validate_farming_art_catalog_path(path)` validates the C2 catalogue. `DataValidator.validate_item_visual_assets(resources)` verifies every declared C2 item model and 128 px transparent PNG sticker; `tools/validate_data.gd` invokes both in the ordinary data gate.
- ISO-1 CropPresentation.render uses 2D stage textures; C2 generated 3D crop scenes remain archived. `get_stage_id` maps the existing growth ratio to stage `0` through `3` or `withered`; `clear` and the root click bounds remain compatible with `FarmView.pick_crop`.
- `FarmEffects.play_action(cell, action_id)` creates bounded, transient hoe/seed/water/harvest presentation only. `FarmView.play_action_fx` is the existing-view bridge. Neither method changes grid, inventory, wallet, yield, time or save state.
- `UiIcons.for_item` prefers an ItemData sticker PNG and retains its existing SVG fallback. `get_icon` prefers the four C2 tool stickers before its existing UI-chrome fallback.
- `ChibiAvatar.play_tool` uses the C2 generated held prop when available, preserving its old procedural fallback and all C1 animation APIs.
- `ChibiFarmingBuilder` and `tools\build_chibi_farming.bat` reproducibly build 45 crop-stage scenes, 18 item prop scenes, four tool prop scenes and 22 transparent sticker PNGs. `tools\art_review_farming.bat` writes isolated normal-renderer contact sheets and an opt-in `--capture-chibi-farming` main-scene evidence image; neither path writes a save.

## C3 chibi world

- `ChibiWorldBuilder` and `tools\build_chibi_world.bat` reproducibly generate 21 grounded world/building/prop/critter scenes plus `assets/generated/models/world/manifest.json`; `ChibiMeshAudit` enforces the existing C0 budgets.
- `tools\art_review_world.bat` writes five normal-renderer seasonal/day-night/four-angle contact sheets and invokes `tools\capture_chibi_world.bat` for a real-main-scene image. The private `--capture-chibi-world` argument is review-only, reads/writes no slot and exits after its image.
- `DataValidator.validate_world_art_catalog_path(path)` validates the C3 catalog in the normal data gate. C3 tests additionally lock safe passive placements, anchor/marker transforms, seasonal effect cap, material readability and review layout.
