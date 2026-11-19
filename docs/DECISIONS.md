# DECISIONS — THE LIFE

## Phase8.5h approved implementation boundary (2026-11-19)

﻿Step8/10 after8.5g pushed4e5c471/full933. Companion card below Character identity uses detached DogSnapshot and localized DogPresenter. New NameSheet/Form/Card scenes compose only shared Theme/native controls; Character retains public identity/skills/relationships/tabs aliases and left profile can scroll. NameFlow captures expected owner revision, native LineEdit has max_length0 (no silent24-character truncation), command goes through DogState validation and guarded publication. Successful save and explicit Cancel/Back return to Character; Esc/coordinator/lifecycle close only hide and never reopen. Owner remains authoritative, default world caption follows locale and named caption remains actual name. UiCoordinator alone owns holds/focus/input, native text/Tab/Enter preserved without world shortcuts; new/load/title close naming. No new actions/autoload/old scene/Player/save15 wire or other domain changes.

Import1 clean except inherited assetUID warnings. Focused1 3scripts/4/4/46assert/2.284s PASS. Native1 adds original Character layout/screen regressions:5scripts/12/12/1099assert/13.780s PASS; warnings only expected missing legacy crop/coop fallbacks. Native mouse open, Unicode key events M+U00E2+y, Enter/Tab/Esc, cancel/invalid/25char/control/stale quote/lifecycle close all pass. vi/en x1152/1280/1920 long24codepoint names produced12fresh name/card captures, vi1152 card and modal visually inspected. Forty read-only open/cancel/render refreshes preserve owners and save bytes; locale default caption verified. All old tests/goldens and20real saves protected. Human OS IME composition/art/tone/F5 remain pending, not inferred from synthetic native key events. Full follows.

Existing DATA/domain/view ownership and previous save fields remain. Actor pixels, routes and animation phases are derived; only DogState owns the dog name/cell. No economic/statistical/story reward or new input action.

## Phase8.5g approved implementation boundary (2026-11-19)

﻿Step7/10 after8.5f pushed8fc035c/full929. SaveService.CURRENT_VERSION15 adds only dog{name,cell_x,cell_y}; 14-to15 baseline and all earlier migrations preserve prior systems and do not simulate days. Independent DogSaveCodec canonicalizes nativeJSON integers/name, preserves a valid Unicode name on bad/missing position and supplies bounded safe Resource baseline. DogLifecycle prepares against current actual nav before silent replacement of the same DogState; runtime refreshes sparse obstacles and reuses actor/children after load. Good current cells preserved; blocked positions repair locally with good name retained. No saved route/timer/nav cache/Nodes; dirty-save observes actual dog commands. Root busy guard remains across publication. Director intent/default-off, weather three forecasts, ecology/coop/can/land/jobs/progress unchanged.

Import1 clean except inherited assetUID warnings. Focused1 2scripts/4/4/94assert/1.404s PASS; native1 1script/2/2/71assert/1.384s PASS. All fourteen historical golden inputs tested, prior files untouched. Actual SaveService._migrate produced new golden15 from tracked golden14 (never a human save). Independent32-dependency no-autoload project:1000nativeJSON/Unicode/safe-cell/restore steps PASS. Current save/load/Continue/new/title and bad dog-only fallback retain other real owners. Exact approved38row/33oldtest compatibility verified byte-for-byte; remaining455prior tests/fixtures and20real saves SHA unchanged. Full follows; no assertion removal/fixture/golden1..14 changes or timeout extension.

Existing DATA/domain/view ownership and previous save fields remain. Actor pixels, routes and animation phases are derived; only DogState owns the dog name/cell. No economic/statistical/story reward or new input action.

## Phase8.5f approved implementation boundary (2026-11-19)

﻿Step6/10 after8.5e pushed6c0fb32/full922. Main retains stable DogState and one LifeDogRuntime/DogActor2D under actual world.objects. DogNavigationContext snapshots actual owned land regions, MachinePlacementState.MACHINE_SIZE footprints and owned coop Resource footprint (placement occupancy is currently one cell irrespective of art). Static world water/buildings/farm use original Resource. Polls sparse sources at configured0.25s and immediately before adjacent arrival; navigation rebuild only on canonical change. DogMotionFlow quotes before pixels, rechecks on arrival then resets display from sole owner; stale/blocked arrivals cannot commit. Only newly covered origin uses bounded repair; one actor/two child display nodes reused. Lifecycle reconfigures existing visual references after silent owner reset, keeps name/cell display coherent.

Paused clock, all UiCoordinator modals including DebugMenu, sleeping/day-end and title stop advance; title hides and cancels route. New/load reset derived routes; actual owner publication prevents save/load/new/title reentry. No new collision/input/Player/camera/NPC/scene/save14 fields or economic mutation. Live dog not persisted until approvedg. Native walking/sprint feel and final art remain human F5 acceptance.

Import1 clean except inherited duplicate assetUID warnings. Focused1 3scripts/7/7/54assert/2.663s PASS; native1 same7/7/54assert/2.740s PASS, no errors/leaks. Real Main follow to far negative grid cells, hysteresis stop, pause/modal/title, stable cache, owned water/buildings/coop, actual machine place/move/remove and land grant, covered-origin/name preservation, stable owner/actor across lifecycle and publication reentry all verified. Existing tests and20real saves protected; full follows.

Existing DATA/domain/view ownership and previous save fields remain. Actor pixels, routes and animation phases are derived; only DogState owns the dog name/cell. No economic/statistical/story reward or new input action.

## Phase8.5e approved implementation boundary (2026-11-19)

﻿Step5/10 after8.5d pushedc0cfe8f/full918. DogVisualProfile supplies shared ArtPalette cream/brown/outline/ground shadow, finite polygon geometry and cosmetic timing. Avatar owns only phase/facing; actor reads sole DogState, interpolates real IsometricGrid ground points and emits arrived without mutating domain. Exactly avatar+non-interactive name Label, no physics/input/3D. Actor is not spawned by Main until approvedf. configure/reset_position/begin_step/advance and set_unnamed_caption are the composition API; unnamed caption empty until localized UI integrationh. External Resource palette and shape arrays detached by frozen_copy.

Import1 clean except inherited duplicate artUID warnings. Focused1 2scripts/4/4/86assert/1.766s PASS, native1 1script/2/2/86assert/2.954s PASS. Native actual Main grid vi/en x1152/1280/1920 x5zooms rendered, six fresh PNGs archived; manually inspected vi1152 silhouette/ground/name/shadow. Ground invariant, pause pose/position freeze, no owner mutation, finite validator negative cases pass. No scene/InputMap/Player/assets/economy/day/RNG/save14 changes. Main spawn followsf; provisional art still needs human acceptance.

Existing DATA/domain/view ownership and previous save fields remain. Actor pixels, routes and animation phases are derived; only DogState owns the dog name/cell. No economic/statistical/story reward or new input action.

### D132 — validated adjacent movement and limited invalid-origin repair (2026-11-19)

Approved8.5d respects start3/stop1 hysteresis and actual reachable space. Choose closest stop-radius goal before lowest route cost and stable grid ties; blocked components wait rather than jumping across walls. Movement service captures owner/nav revisions and rechecks adjacent walkable step at commit, retains guard through callback. Only an origin made invalid by changed world may relocate to bounded nearest safe cell; normal movement never teleports toward Player. No free cell leaves name/cell unchanged. No new progress owner/timers/save fields/economy, only references and transient guard. Rendering/runtime follows later scopes.

### D131 — independent bounded navigation cache, no position owner (2026-11-19)

Approved8.5c uses native AStarGrid2D over current player_region39x39 and actual static DATA exclusions, with orthogonal routes. Keep NPC grid and world physics untouched. Context wire contains dynamic sources/bounds only; trustworthy static exclusions are reapplied from frozen config, never deletable by cache restore. Configure captures a new static configuration; equivalent dynamic updates/restores retain revision/build count. Derived context serialization satisfies stateful-library contract but is never included in game saves. DogState remains sole name/cell owner; callbacks/movement arrive later.

### D130 — sole pet identity and exact logical-cell wire (2026-11-19)

Approved8.5b owns only name/cell, derives no economic/story progress. A blank saved name is an unnamed localized label, not translated text stored as a custom name. Commands reject invalid/too-long names without cutting user text; source Vietnamese codepoints retained. Pinned Godot decoder replaces NUL withU+FFFD before the domain layer, so reject that normalized corruption marker and keep decoder diagnostic in independent probe. Silent replacement increments transient revision to invalidate pre-load UI quotes. Callback guard spans typed publication; navigation/adjacency belongs to later movement service, no second cell owner.

### D129 — approved dog batch and DATA-only first slice (2026-11-19)

Owner approved all10steps8.5a-j/160paths, explicit parameters/provisional2D/name UI/save15 exact38row33file compatibility; each full test/commit/push sequentially. Currenta only DATA/validator/contracts; real Player preserved. S21 cosmetic companion, no hunger/rewards/economic effects/story intro invented. Name max24codepoints, follow3/1,speed3cells/s,context0.25s,idle3s/radius2,reaction0.8s in Resource. Dog data deep-copy must detach external Resource graph (duplicate(true) alone did not), preserve internal shared references, leave immutable Script resources shared. Data CLI must defer VIEW translation-key catalogue compilation until autoload identifiers exist. Human art/F5/tone remains separate; later steps alone add runtime/save15/UI.

### D128 - complete bounded simulations through validated seasonal checkpoints (2026-11-19)

Approved7.5k verifies current production code without changing domain/runner/old tests. Direct three-world1000day probes exceed180s, so retain all days/invariants across explicit validated season checkpoints and keep the same per-child bound. Resume carries actual three v14-normalized worlds, clock, observations, histories/counters/seed/decision bytes, never recalibration or replay. Checkpoints/loops are verification-only, with stdout/source/SHA chain archived externally. Native JSON decimal trace rounding/integral spelling is reported; compare exact parsed wire, all exact decision/RNG fields and unchanged threshold sides. Both consumers receive the same decoded checkpoint. Large JSON output is chunked losslessly to avoid the existing PowerShell giant-line bottleneck; no timeout extension or assertion skip. Human production story/release/art/tone acceptance remains separate.

### D127 - explain committed plans without inventing effect history (2026-11-19)

Approved7.5j uses separate small morning/history components and a shared detached current snapshot/presenter. Stored decisions describe selected intent and planned period; disabling may cancel application, so do not present past selections as proven executed effects. Current cost comes from pure validated projection/actual measured rain-canopy context; no guessed water measurement. Compact morning summary keeps full counter text in tooltip and journal. Native tooltip requires meter pointer PASS, children ignore; no input action or new modal. Ordinary J branch retains no-progress invariant. Human text/art/editor acceptance remains separate.

### D126 - read-only current preview beside immutable decision trace (2026-11-19)

Approved7.5i adds a modular debug modal through existing exact Ctrl+M shop, never a new input action/story unlock. Current evaluation is recomputed without RNG; trace/history is stored source truth, not recomputed past. Missing observation/measurement uses explicit unavailable labels, no fabricated scores/water zeros. Queue checks current eligibility and next completed morning checks again; only lottery bypass, never safety/telegraph. UI remains paused and follows shared modal/lifecycle guards. Strings are one-line CSV because existing localization parser is line-oriented. Human tone and real release export remain separate acceptance.

### D125 - actual command receipts and completed-morning save14 (2026-11-19)

Approved7.5h integrates both pure owners through small Main adapters and existing single day handler. Attribute human activities at explicit successful source boundaries, not global notifications that also describe rain/debug/load. Hold command lock through callbacks and record_many; actual quantities, partial coverage if proof lost. Keep public old tool/water/shop/scheduler calls compatible. UI feed purchase reuses original domain shop with copied original runtime entry checks and runtime busy, so its receipt lock does not self-block the existing public execute guard. Raw programmatic/debug routes are not human observations.

Reserve outgoing activity/Director before farm callbacks, commit after existing complete world/forecast and before ledger/autosave/bulletin. Source quotes/normal lifecycle cannot interleave. No second listener, catch-up or fake story flag. Debug intent remains stored independently from effective OS-bound authorization; release gets no effects. If raw debug calendar is unavailable at finished optional selection, explicitly turn events off without replaying core day. Effects use current measured counters and captured terms, preserve finite stock/routes/cells/14critter identity/phase/opacity. No extra stamina/yield/money, no asset/oldscene/InputMap/Player edits.

Save14 introduces only paired activity/director fields; legacy/corrupt baseline is current-day partial/off, no inferred history. Apply exactly owner-approved39line/33file version compatibility patch; no other old assertion/test/fixture changes. Golden14 is actual SaveService write/read of migrated repository13, not human data. Native and headless evidence separated; human tone/art/F5 and actual release-export remain pending.

### D124 - paired persistence without inventing observed history (2026-11-19)

Approved7.5g libraries validate actual saved day/catalogue/calendar/weather/ecology/owned land using existing pure boundaries. Preserve already saved weather even if seed algorithm differs; unavailable weather remains unavailable, no forecast generation. Calendar mismatch is recorded rather than silently fixing core clock. Valid current pair restores coverage/captured decisions/terms/force/counters/RNG exactly without reroll or notification. Corrupt/missing/misaligned pair resets together to explicit current-day partial/off baseline; do not let one surviving component imply complete observation provenance. Legacy ignores unknown future components. Prepare all candidates before replacing either owner, respect both busy flags and keep unrelated progress. No live runtime/root schema/version change until7.5h.

### D123 - reversible terms and captured multi-charge watering (2026-11-19)

Approved7.5f keeps effects projections, no extra gameplay owner or direct world mutation. Saved debug enabled cannot authorize production effects; actual caller gate/current measured weather-canopy apply. Unmeasured canopy is unknown and neutral rather than inferred zero; refill/rain remain immediate counters. Add explicit DATA base manual cost1 while preserving20/40/200 and all one-unit APIs/save fields. Debit entire cost before farm mutation, reject insufficient first, refund only captured debit under existing refill/load revision rules. Optional quote includes water/modifier revisions and actual cost. No extra stamina/yield/coin/growth, fake merchant stock, extra ecology actors or live Main integration. Following approved runtime alone supplies current terms.

### D122 - guarded sole Director owner before runtime (2026-11-19)

Approved7.5e creates a pure serializable owner from its first commit. Reserve adjacent day by opaque identity; commit selection/schedules/history atomically under token and guarded typed notification. Invalid candidates leave prior owner/token for explicit retry/abort, stale tokens cannot unlock another operation. Preserve immutable actual decisions/trace/RNG and independent cooldown/season/pity counters when128history prunes. Negative reservation charges actual target season when selected. Off cancels application but retains booked counters/cooldowns conservatively, with no refund of past actions; reenabling starts new grace/pity at actual day. Force queues for next decision only; failed safety checks record declined intent without random replacement. No production unlock/clock subscription/Node/world/save13 change. Full-precision JSON is the existing game protocol, not a new rounded format.

### D121 - seeded choice before persistent scheduling (2026-11-19)

Approved7.5d chooses with explicit no-event weight and deterministic dedicated tag2, preserving existing stream tags/mixer. Quotas apply to actual proposed start season and count pending reservations; cooldown/grace/negative spacing/mutex all filter before drawing. Supported active-day affinity bonus is bounded by DATA, never quantity/style punishment. Pity waits for an eligible positive instead of inventing one. Force retains all constraints/telegraph and bypasses lottery only. Capture actual terms/seed/lossless RNG state/trace; never use history as current ecology. No live owner/save/runtime until following steps.

### D120 - explicit Director observations before scoring (2026-11-18)

Approved7.5c keeps snapshot/condition libraries pure and detached. Require actual day-aligned clock/ecology/activity/weather and explicit bool availability/gates; partial windows cannot become scored zeros, water stays unavailable, story unlock is never inferred. Use active-day frequencies over complete closed window so one-day quantity spikes do not gain more affinity; open day excluded. Predicate min/below uses exact current threshold side, ignores historical triggered, and reads saved weather at proposed effect start rather than rerolling or guessing. Market-extra eligibility uses actual current schedule weekdays. JSON reads integers as doubles: recursive exact-value normalization accepts only equivalent integral representation, no tolerance around gameplay values. Invalid/forged/unknown/busy/stale context fails explicitly, no owner/clock/RNG/save changes. Selection/state/runtime remain later approved steps.

### D119 - approved three-event Director DATA prototype (2026-11-18)

Owner approved all10scopes7.5b-k, policy numbers and full-test/commit/push per step. Firstb is DATA only. Dust is extra can consumption1(total2) for1day after2saved forecast days; rain/current measured canopy birds threshold waive it, refill is immediate counter. It does not change farm water flags/growth/stamina. Merchant prototype uses actual Minh market/hours/stock/prices, not unimplemented riverside navigation. Bloom changes existing eligible butterfly color for2days, no extra actors beyond14 or fake flowers/water score. Defaultoff; M2.4 story not fabricated. Policy grace/pity/cooldown7, negative2/gap3, weights1/noevent1/positive bonus<=0.5, history128 in Resource; positive cap0 unlimited. Known metric/weather/NPC/calendar/condition/effect bindings and explanations/counters must validate. Native deep-copy boundaries explicitly tested. Next steps alone activate selection/state/effects/runtime/save14/debug/UI; no early implementation.

### D118 - approved7day Director observation foundation before runtime (2026-11-18)

Owner approved Phase7.5a/21paths, default7day window within S14's7-14 range, full gate and commit/push. Create DATA config plus pure state/codec only; source IDs are actual existing Events signals, but this step subscribes to none. Successful till/plant/water actions and harvest/buy/sell quantities are observational units, not coins or scoring weights. Default first day is explicitly partial; only genuinely observed complete consecutive closed days make query available, with no invented zero history or open-day influence. Configure/load silent; typed local notification only after atomic record/advance with mutations locked through callbacks. Freeze config/detach outputs and cap each counter's current+retained history sum at JSON-safe integer limit. Runtime collector, replay/bulk/rain/load attribution, activity bias/weights/pity/negative counteractions and actual effects/M2.4 gate await new scopes. Keep current save13/Player/InputMap/oldtests/runners; no fake woodcutting/fishing/cleanup inputs or live Director claim.

### D117 ? honest1000day and native end-to-end verification (2026-11-18)

Approved7.4c adds only a verification tool/two test files and docs. Use actual farm/season/care/land/simulator/lifecycle/sampler, compare reserved grouped path to independently advanced farm/daily lifecycle. Restore both from identical decoded full-precision checkpoints so known native1ULP rounding is measured, not concealed by an impossible bit-identity claim. Verify threshold sides/held unmeasured water/unique history/no duplicate day and silent restore. Custom SceneTree CLI dynamically loads autoload-dependent farm/simulator after deferred startup; no gameplay dependency rewritten. CLI writes no saves. Native real review/autosave/morning/J/feedback/load/Continue in vi/en3sizes captures actual states; fixture API mistakes are recorded, old tests remain unchanged. Final acceptance matrix distinguishes automated batch completion from unavailable water/clearwater gameplay, provisional art and human F5/tone review. Keep fixed full runner180s groups/Player/InputMap/save13 and exclude unrelated prompt files.

### D116 ? bounded reused2D ecology objects and lifecycle cleanup (2026-11-18)

Approved7.4b adds only two small VIEW scripts and Main composition. Native silhouettes are provisional; retain existing grid/Objects/y-sort/CanvasModulate. Root anchors derive actual owned regions through shared grid adapter; expansion redistributes stable effect:index instances rather than duplicating nodes. Current levels/availability only, not historical triggered. Pause/sleep/day-end holds freeze cosmetic phases, existing lighting plus Resource opacity handles night/rain. State/farm signals dirty the view; bounded context poll covers silent restores and non-signaling land ownership without garden scan each frame. Explicit Main lifecycle refresh ensures title/reset/load cleanup. Flow owns/free roots even though parented under Objects; no collisions/input/state/save13 side effects. Final art/human F5 and water system remain deferred.

### D115 ? provisional bounded native2D ecology feedback definitions (2026-11-18)

Approved7.4a Resource owns8butterflies/6birds,max14, polygon geometry/colors/motion/normalized anchors and refresh/lighting. Reuse actual ecology thresholds/availability; current level alone decides visibility, historical triggered never means current activity. No measured water/fish/clear effects. Pure selector returns detached definitions without side effects/RNG/Nodes. Existing available bird/butterfly assets are3D historical material and remain untouched/unloaded. Native2D silhouettes are approved prototypes, not completed final art. This step adds data/pure selection/validator only; live objects next7.4b. No gameplay/save13/input/Player change.

### D114 ? read-only morning ecology after committed day (2026-11-18)

Approved7.3i consumes existing actual snapshot/presenter in a separate compact strip. No state mutation, forecast replay or fake measured water; actual current estimates/counts and target/ease/hints stay distinct. Invalid context is waiting. Short fixed labels must not word-wrap at shrink width; long summary/counts may wrap. Native both-locale/three-size fit and old price scroll/dismiss tests are required. Save13 and morning timing remain unchanged; human wording acceptance separate.

### D113 — lazy ecology page within the existing journal modal (2026-11-18)

Approved7.3h adds separate small sheet/metric/source scene pairs and a transient Node controller to the existing J Quest book. Keep3enabled common-tab indices/4filters, close/modal/pause/QE and original quest transaction paths. Explicit Ecology entry creates page lazily; Back/reset/close detaches and queue_frees it, so ordinary quest mode continues to satisfy old no-progress/no-fake-XP invariant without changing its tests. Header entry shrinks to content instead of taking half the tab bar; Close remains far right. Same native Theme/Fonts, no global inputs/styles/art or old .tscn edit. Render only7.3g actual detached data; water remains unmeasured/hidden bar. Busy-state localization and deferred focus/reset guards avoid stale UI work. No world state/save13 mutation. Native captures/automated layout acceptance are distinct from human F5/tone review.

### D112 — actual ecology readouts before journal controls (2026-11-18)

Approved7.3g creates Resource-owned localized definitions and stateless VIEW snapshot/formatter. Current eased metric and current garden target/count are different values and displayed explicitly; only the daily simulator changes the former. Count aliases/healthy/regrow/ownership semantics stay in sampler, goals/ease/thresholds stay in existing DATA. Water is always unmeasured: formatter omits numeric value/bar/target/source/threshold fields instead of displaying a saved placeholder as cleanliness. Busy/stale/bad input gives waiting/failure, not invented zeros. Hints describe real planting/care/owned-garden actions, not imaginary cleanup/flowers/rewards/history. No Node/control/scene/clock/save/global event changes in this step;25vi/en draft keys and validator/CLI gate support the next journal/morning consumers. Human tone review remains separate from automated key/layout acceptance.

### D111 — ecology reservations in the single completed-day pipeline (2026-11-18)

Approved7.3f adds transient EcologyState reservation APIs and optional final DaySimulator callback, preserving original callers/metrics/ease/wire. Main validates and reserves under existing weather/coop guards, freezes sampling inputs before farm callbacks, resolves season withering at farm-step end, then farm->animals->machines->ecology before weather/new rain/ledger/save/bulletin. No eager easing on UI/plot/ownership changes. Reserved state rejects reconfiguration/load/direct advance through callbacks, reads old committed snapshot until atomic finish and guarded signals; wrong token/invalid target never silently commits. Invalid preflight aborts weather without simulating/saving; existing clock-first adapter is not rewritten. Late inconsistency remains locked/no success/autosave rather than concealing partial completion. Save13 and all prior tests/goldens remain unchanged.

Native pinned JSON full_precision still rounds some arbitrary doubles by1ULP (observed29.299488111481594->29.29948811148159); codec preserves decoded values, not an impossible guarantee about native parser bit identity. Same-input reserved/direct paths match exactly;1000day probe found147scalar rounding occurrences/max1ULP and no threshold-side flips. Added nearest below/equal/above tests at25/30/50 retain classification and no load notifications/history. No quantization/gameplay number/schema change is introduced to hide this native numeric limit.

### D110 — Main ecology owner, lifecycle guard and save13 (2026-11-18)

Approved7.3e composes one stable Main ecology owner plus RefCounted lifecycle adapter. Preflight canonical context before live mutation, hold busy through synchronous restoration so Main save/load/NewGame/title routes cannot reenter. Main's land lifecycle internal steps reuse documented public close/deserialize/refresh_land, preserving LandRuntime's external busy rejection without editing it. Existing state/codec/sampler libraries remain unchanged.

Save13 adds only ecology{day_index,metrics,triggered}; full-precision JSON protects threshold side. Legacy <=12 calibrates actual owned garden and cannot smuggle unknown ecology history; valid13 preserves matching-day values/history. Corrupt/missing/mismatched component has explicit calibration reason; invalid write context preserves existing files. Failed read context exposes ecology{} for explicit runtime rejection/fallback, not false complete data. Alloldgoldens unchanged, additive13 generated from12+actual codec. Only exact approved40lines in32oldtests change; explicit envelope12/13 contracts remain. Step has no daily callback yet;7.3f is required before daily ecology integration is complete. No Player/InputMap/scene/audio/price/cleanup change.

### D109 — canonical legacy ecology context before live save13 integration (2026-11-18)

Step7.3d implements only pure context/component libraries under approved12paths. Reuse existing FarmSaveCodec and LandOwnershipState so legacy aliases/frozen growth/ownership match real restoration, without rewriting source farm/land or goldens. Validate explicit Resources/catalog and direct-cast safety first. Valid ecology with matching clock day stays exact, including history and below-threshold floats; malformed/missing/mismatched state returns explicit current-garden calibration, never replay. Invalid sampling context fails completely; do not fabricate a partial component. Existing envelope/storage/weather/crop/water/animal/Player APIs and save12 remain unchanged until approved7.3e. Independent no-autoload probe verifies transitive pure Resource/domain dependencies.

### D108 — approved current-garden ecology baseline and sequential ten-step batch (2026-11-18)

Owner approved7.3c->7.4c scopes, one milestone at a time, full gate then commit/push per milestone. First7.3c is only lifecycle library: current normalized owned-farm targets calibrate tree/species on NewGame/legacy/corrupt ecology at loaded clock day; no invented past updates, threshold history or rewards. Water takes profile initial only as an unavailable placeholder, not measured cleanliness. Valid matching-day state retains exact values/history; load is silent. Validate full context/candidate before changing existing owner. Later approved steps alone introduce save13/runtime/day reservation/UI/bounded2D feedback; they are not implemented by this decision. All existing goals8/8/aliases/ease10/thresholds remain. Existing user prompt deletion/untracked addition are excluded from commits. No locked rule change, Director/cleanup gameplay or permission to weaken old tests.

### D107 — approved farm ecology sampling, with water explicitly unmeasured (2026-11-18)

Owner approved Phase7.3b/19 paths, targets of 8 healthy mature fruit trees and 8 distinct healthy species, and commit/push after verification. Resource data/ecology_sampling_config.tres owns goals, fruit IDs orange/apple/banana and six legacy species aliases. Canopy is a farm proxy on owned logical cells, not a measurement of all forest/decor. First-cycle maturity uses the frozen plot growth_target; regrowing fruit trees remain mature after harvest. Withered plants contribute neither tree nor species; living immature plants contribute species. Coffee/pepper are not canopy trees. Six equivalent legacy IDs collapse only for counting, without renaming data/save IDs. Targets are count/goal*100, capped100.

EcologySampler is stateless pure RefCounted, accepts explicit farm wire, CropData catalog, owned regions and current ecology metrics; validates all inputs before returning detached targets/counts/available. Reject malformed/duplicate/unknown rows even outside owned land, rather than silently dropping evidence. Overlapping owned regions count a cell once. No cleanup owner exists: water_clarity target holds the supplied valid current value and available=false; future consumers must hide it or label it unmeasured, never infer clean water from weather/refilling/PNG. Sampler does not advance ecology or change an owner. No Main/day/UI/autoload/global signal/save-v12 integration is authorized here. Parent7.3 remains partial; runtime/legacy baseline/day order/save migration require a separate approved scope.

### D106 — standalone ecology targets and snapshots before world integration (2026-11-18)

Owner approved Phase7.3a/23paths and commit/push after gate. Shipped Resource defines tree_cover/water_clarity/biodiversity0..100, initial0, ease10percent/day, thresholds birds30/clear_water50/butterflies25. Initial values are for standalone state only, not a claimed NewGame environment baseline. State takes complete normalized targets; no invented world count goals/weights/clean-water actions. DATA Resources validate; pure RefCounted state/codec have no Node/autoload/RNG/filesystem. Deep-freeze configuration, commit all metrics/day/history before local typed notification, guard configure/restore/update through callbacks. Crossed means a side change including upward arrival at equality and downward departure; signal once per crossing both ways, triggered remembers upward crossings only. Load is silent, no simulation/reward/replay. Separate active threshold query derives current side. Standalone wire is not added to game saves; Save12/Main/DaySimulator/Events/Player/audio/UI remain unchanged until a new integration scope. Remaining schema sources/weights/count collection are deliberately deferred.

### D105 — context-driven loops stay in transient presentation (2026-11-18)

Approved7.2c wires Main-owned four-slot loop flow and pure cosmetic context selector. Profile controls listening regions/time/fade; no geometry/land/ecology authority. Typed clock/weather markdirty; reconcile nextprocess and actual Player cell/title/gameflag avoid observing half a restore. Delta only fades local profile gain. Rain>night>regionalday; morning/afternoon music quiet atnight. Pause keeps loops so sliders preview actual accepted audio; title silences even when existing Main gameflag remains true. Clone WAV before enabling loops, never edit shared imports. Fixed two slots per layer bound rapid context changes/load/NewGame; same context does not restart. Existing bus router alone applies accepted gains, preventing squared volume. All state/simulation/save12/input/scene/audio asset/bus/source bytes outside this scope remain. Human listening/final content still pending.

### D104 — original replaceable PCM ambience placeholders (2026-11-18)

Approved7.2b uses original offline synthesis for eight tracks; no external sound/license/package dependency. PCM WAV instead of finalOGG is explicitly approved for this placeholder slice. Do not describe it as a field recording or final content/listening acceptance. Profile Resource owns track paths/gains/durations, cosmetic listening regions and fade/time bands, with pure validation/detached lookup. Four original SFX remain byte-identical. Native WAV imports use uncompressedPCM; shared imports stay loop-disabled so7.2c clones before enabling loops. Fixed generator noise seed is cosmetic, never gameplay RNG; finite synthesis is deterministic. No runtime playback, geography/gameplay/owner/save changes in7.2b.

### D103 — five audio buses with one accepted gain per path (2026-11-18)

Owner approved all Phase7.2a–c and per-step commit/push. For7.2a add default Master/Music/SFX/Ambience/UI layout; existing Settings accepted values remain the only preference owner. Keep original SFX player.volume_linear for public/tests compatibility and SFX bus unity, while Music uses music_volume and Ambience/UI use effects_volume. Master stays user/device-independent unity by default. Validate bus names/sends before any write; no partial rebuild/mutation on missing layout. Router is core RefCounted with no Node references, not another autoload. Four original WAV/API/cleanup/scene/inputs/save12 and all old tests remain. Native APIs are verified before use. No loop playback until7.2c; audio asset WAV placeholder exception is explicitly approved for7.2b, not a final OGG/content acceptance.

### D102 — wire modular dialogue through existing owners with guarded requests (2026-11-18)

ApprovedF16 reuses F15 views in existing NpcPanel/NpcSystem, retaining column/title_label/close_button aliases to actual controls and legacy show_content/book behavior. A transient VIEW controller checks fresh identity, enabled action, nearby visible NPC and modal/game/clock context before routing original handlers. Its synchronous busy guard rejects stale/reentrant GUI requests and close/shortcut callbacks while existing domain transactions execute; a separate route guard prevents recursive execution. No world/schema12/owner/transaction arithmetic changes. Coalesced inventory/social/schedule/locale refreshes read state only and hidden lifecycle changes invalidate displayed identities.

Native geometry probes found only floating-point edge rounding during scaled modal transitions (less than0.001px); reserve1px bottom breathing room rather than relaxing strict bounds. Final capture review also exposed actual HUD toasts covering the wide dialogue body: UiCoordinator places root.toasts below the dialogue, restores its original order elsewhere. The legacy Main.toast is not the live stack; the first attempted z-order target was corrected after native capture review. No new portrait/blur art, story/actions/hotkeys or claim of human acceptance. Existing illustrations mismatch and process-level save/power-loss limits from earlier milestones remain explicit.

### D101 — passive modular dialogue components using actual data and portraits (2026-11-18)

ApprovedF15 builds mockup12composition independently before runtime wiring: actual NPC renderer/name, read-only localized line/quest/offer values, exact friendship counts and only real enabled choices plus Close. No illustrated portrait asset/role/hearts/story/keyboard binding is fabricated. Views emit requests, own no domain state. Stable close and revision guards support existing consumers and future safe routing. Body scroll/minimum-driven reflow fixes observed655px stale body height after wide-long→small-locale resize; preserve all strict bounds/test waits. Current NPC/full-body art and existing world backdrop differ from the illustration/blur in the mockup; that art gap is explicit. Existing NPC runtime/questbook/save12/owners are untouched untilF16.

### D100 — accepted effects volume updates active and future players (2026-11-18)

ApprovedF14 consumes theF13typed accepted-preferences event. Apply actual effects volume through native AudioStreamPlayer.volume_linear to active children and newly created players;0is exact mute. Ignore mutable event arguments in favor of accepted Settings. Preserve one listener, original sounds/callers/cleanup and all game state. No new audio tracks/bus/autoload or claim that music/ambience7.2is complete. Native properties/lifecycle were tested, human listening/device acceptance remains separate.

### D99 — validate accepted preferences and persist before publication (2026-11-18)

ApprovedF13 keeps ConfigFile as the single accepted preference source and preserves valid unknown keys/sections through clone/serialization. Normalize supported fields on read in memory only; malformed CFG falls back without rewriting it. Apply validates a merged supported patch, persists one staged replacement, then publishes accepted config/explicit locale and one typed change event if values changed. Failed persistence leaves runtime/locale untouched; report retains any I/O rollback limits. Do not introduce unsupported settings or savegame fields. Legacy finite volume clamps stay; non-locale setters must not unexpectedly switch a temporary UI locale. Native malformed-file verification runs separately because ConfigFile logs a parser diagnostic for invalid syntax; no error suppression or GUT weakening.

### D98 — present actual completed load results (2026-11-18)

ApprovedF12 separates title inspection from actual load notification. A small shared notice renders detached source/error reports with vi/en keys and no filesystem paths; title hides it outside TITLE, including live translation. Main exposes transient request feedback cleared before busy/error guards; recovered success requires the restore routine to finish. Pause captures this feedback from its callback owner before refreshing summaries and uses the existing status area, not another toast/modal. Continue alone shows one recovered toast after entering the restored world. Save failure remains bool-based. Gameplay restore order, owners, save12 and all old scene/InputMap/assets remain unchanged.

### D97 — staged save publication and observable rollback (2026-11-18)

ApprovedF11 replaces unchecked destructive rotation with a core adapter/transaction. Read originals, stage their copies and all desired new bytes, then move/publish with retained copies. Backup history is existing primary then backups in order, truncated to3, compacting holes without discarding history merely because primary is absent. No new persistent owner/schema. An observed precommit failure returns false and restores originals when rollback I/O succeeds. If rollback also fails, retain copies and report their paths; never silently destroy the last previous bytes. Once the complete family commits, cleanup failure is reported as committed cleanup_pending, not a false failed save. Tests inject I/O errors and exercise Windows rename; no claim of atomicity across power cuts or actual disk-full testing.

### D96 — conservative automatic backup reads with transient reports (2026-11-18)

ApprovedF10 wires the strict envelope through a core read resolver. Only an existing damaged/unreadable primary enables backup1→2→3. Missing/deleted primary stays missing; delete_save continues removing only the primary. A supported-shape future-version primary blocks automatic downgrade within that slot. Loading never repairs or overwrites files. Reports are transient detached core metadata, not saved state; inspect/has_save/summary cannot replace a report from a real load. Latest selects actual migrated payloads using the existing timestamp/day rule. Component normalization is still the existing migration/codec behavior; this does not claim complete arbitrary-component fuzz safety.

### D95 — standalone strict save-envelope codec (2026-11-18)

ApprovedF9 introduces stateless boundary validation before future file-resolution wiring. Do not truncate fractional, nonfinite or unsafe JSON versions. Keep historical missing meta/version as0, including empty legacy dictionaries accepted by the old envelope. Unknown fields are deep-copied unchanged, not proof of valid component state. Component codecs/migrations remain authoritative for their own fields. No version bump/runtime/save change inF9. Future primary downgrade policy is reserved for approvedF10.

### D94 — three sequential complete graphics groups (2026-11-18)

ApprovedF8 replaces only two-way partitioning by sorted index%3. Keep all discovered test scripts/cases/assertions/captures, Forward+ renderer and180000ms per child. Keep strict summary/hash/coverage/fail-fast behavior; do not reduce tests or claim concurrent TEMP safety. Native PowerShell harness tests cover partition, malformed success output, timeout124, parse failure and source drift through a disposable replica. No GUT implementation or old test changes.

### D93 — enforce the existing stable engine pin before bounded runs (2026-11-18)

Approved AUDIT-F7 keeps PROJECT_RULES4.7.2-stable. Accept the exact stable version or its official build suffix (including mono official), reject other channels/versions, nonzero/missing/ambiguous output and version-probe timeout. Probe limit10s is separate from the existing target timeout; no target starts after a rejected probe. APPDATA isolation/hidden children/target exit propagation remain. This enforces the current rule, without downloading, selecting, or upgrading an engine.

### D92 — supplied tall-object visuals on preserved decorative anchors (2026-11-18) — LOCKED by approved AUDIT-F6, automation 625/625 verified

Render bush/tree_fruit in existing eligible env_round_tree placements, alternating catalogue order. Preserve Tree_i/cell/root-count with the existing PlaceholderWorld2D adapter and child shared passive scenery view. This retains separation between explicitly placed tall objects and scattered rock/grass/decor consumers, so existing tests/metadata consumers need no adaptation. Zero new collision/input/harvest/ecology/gameplay, no crop replacement or art rewrite. Occupied legacy plot/placement/actor/route hides only the art, preserves the same root, and existing coalesced refresh restores it. Static owned/source/coop exclusions still remove ineligible generated decorative roots during normal land rebuild. Keep native object colors and global time/weather tint; do not recolor imported shared textures by season. Full/human/commit evidence is separate.

Adapter keeps existing kind=tree/color season metadata. self_modulate alpha0 suppresses only the root procedural drawing; supplied Visual child remains fully visible. Processing is disabled. The unchanged C3test passed after this compatibility fix; no old test was modified.

### D91 — supplied small decor through a passive view helper (2026-11-18) — LOCKED by approved AUDIT-F5, automation 621/621 verified

Use canonical catalogue/rules directly in WorldPresentation; preserve every old rock/grass choice/pivot/collider and only fill formerly empty buckets with9decor. SuppliedSceneryView is display-only, ground-root y-sort plus nearest Sprite2D. Small decor has no physics/input/process or player effects. Coalesce plot/lifecycle view refresh; remove blocked small roots immediately and restore deterministic unoccupied ones, without rebuilding rock physics per crop notification. Runtime never writes farm/stock/jobs/coin/weather/land/water/coop/social or saves. Actual owner queries cover legacy plots, full machine footprints, actors/routes beyond static exclusions. No new art/scene/camera/Theme/input/control/localization/owner edit. F6tallobject step remains separately gated.

### D90 — supplied scenery catalogue with exact legacy selection (2026-11-18) — LOCKED by approved AUDIT-F4/F5/F6, automation 616/616 verified

Use29existing canonical PNGs, no generated/changed art. Measured image/alpha bounds set native scale1;18rock/grass keep old64,128pivot to preserve current placement. DATA owns bands7/18/22/25/30 of100, old hash factors/bias/offsets and size order; pure compile/selector preserve every old choice before scattering new4%flower/3%pebble/5%tuft into formerly empty cells. Tall objects do not scatter. F4 has no runtime caller. Keep large-rock-only collider policy/physics unchanged.
Existing linear hash correlates size/variant: current43square selects12 of18old candidates. Do not change old layout to claim all18 appear; tests pin per-cell compatibility and actual legacy ID set, while all29files import/validate and all9small decor are selectable. A future visual rebalancing needs its own scope. No DetRandom/gameplay/save/scene/InputMap changes. Full evidence/human acceptance separate in PROGRESS.

### D89 — compact machine header and measured useful area (2026-11-18) — LOCKED by approved AUDIT-F3; automation 607/607 delivered

Measured before changing: 2 and 30 frames have identical bad header geometry; a wrapping land Button shrinks to 28 px then wraps each letter, raising the whole row to 250/276 px. Extract a small header, use natural non-wrapping native button minimum widths and keep aliases/signals. Existing title/font/red banner/Theme remain; normal header becomes 92 px and body 332 px at1152×648. Catalogue gets existing themed inset room for motion-scaled cards; no shared animation/theme changes. Validate useful area and bounded convergence, not just enclosing the modal. Keep all old test bodies/assertions/captures, add a real-owner locale/size/status/long-text/native matrix. This is machine presentation, not the full Cô Hoa shop/cart/Sell/Buyback/house/NPC domain. Human/commit separate.

### D88 — exact Ctrl+M and one debug policy across routes (2026-11-18) — LOCKED by approved AUDIT-F2; automation 603/603 delivered

Use the existing toggle_debug_menu InputMap binding with exact modifiers and no echo/release, gated by OS.is_debug_build at each caller through one stateless policy. Native world and modal routing must agree; plainM stays distinct from the future map. Keep explicit logical InputEventAction compatibility for internal debug requests/tests, never permit them with false buildflag. Main's world route checks lifecycle/busy/sleep/day-end/title too, rather than relying on an active modal to supply that protection. No normal E-shop/gameplay/menu redesign, new input binding or debug console recovery. A simulated false buildflag proves the policy guard, not a complete release export; local export templates are absent. Human/commit separate.

### D87 — shared four-stage care/art boundaries and retained repeat plant (2026-11-18) — LOCKED by approved AUDIT-F1; automation596/596 delivered

Owner approved all three AUDIT-F1/F2/F3 scopes together. This decision implements only F1 before running its full gate. Keep stage_count4/repeat_stage3 in CropStageConfig. First growth uses quarter boundaries; stage4 can show fruit before ripeness, but mature/harvest remains tied to100% actual owner progress. Every regrowing crop, including both tomato IDs, displays stage3 until it is ripe again. Withered art uses that same current stage. No resetting saved growth or new save flag.

Farm care uses the same rational boundaries instead of modulo ceil(target/4), retaining current_days>0 grace and the existing dry-limit override/death/recovery path. Thus an unwatered target5 crop atgrowth2 now withers at the real next-stage boundary, without gaining a growth day. This deliberately fixes the recorded mismatch; it is not a new growth/price/yield/season tune. No duplicate simulation path or per-frame growth. D49/D56 retain all other terms. Human editor acceptance/commit remain separate from automation.

### D86 — Day-locked weather runtime, tagged draws and save v12 (2026-11-17) — Status: LOCKED by approved Phase7.1b; automation583/583 verified2026-11-18; human review separate

Owner approved56 paths and the exact old-test version/legacy-roundtrip patch, then explicitly approved five additional full-envelope expectations at D:/godot/game-godot-backups/phase71b-20261117/proposed-weather-migration-test-compatibility.patch. Retain every assertion/old test/golden/runner/bound; only expected weather gains day from original saved clock and canonical integer seed. No other data/balance change.

On2026-11-18 owner additionally approved the exact real-transition fixture in tests/unit/test_day_simulator.gd, expanding scope to57 paths. Retain original water-drain assertion; use actual sleep_to_morning/explicit sunny pre-roll/clock cleanup and add2 growth/day assertions. Final unchanged parse/data/headless63/63/graphics583/583/Main PASS; all557 old cases retained,26 additive. Exact evidence/manual acceptance in PROGRESS.

Keep WeatherState as single weather owner. DATA declares initial sunny/horizon3, existing ordered55/25/15/5 weights/effects unchanged. New rolls use existing DetRandom.make_rng with reserved weather tag1; merchant tag8 and mixer unchanged. This intentionally migrates future RNG only: never reroll valid saved today/seed/three forecasts, including known zero-weight choices. Consume saved head and append only needed absolute future day; valid reload needs no draw. Genuine4.7.2 captured golden pins signed/large-seed vectors and merchant independence.

Persist day_index in save12. Legacy valid3 binds to saved clock; current4 must match it. Pure codecs do no RNG. Empty/malformed component remains/normalizes{} with other progress intact; trusted Main explicitly initializes deterministic seed0/declared current initial and future weather at actual loaded day. Ordinary invalid deserialize retains prior state/emits nothing. No partial coercion or gameplay inference. Reserved token captures next terms before farm callbacks, exact-next-day preflight rejects duplicates/reentry/skips/overflow, source busy includes notifications and Main lifecycle guard. Views receive detached forecast arrays. Public debug fields remain compatible; production writes use guarded commands.

Main keeps established farm->animal->machine daily orchestrator and one-argument farm delegate, outgoing rain before care/new rain after weather, ledger/autosave/bulletin safe points. No additional clock/listener/offline progress/UI scene/Events/autoload. Water introduction10, coop11, every gameplay number and all inherited work remain. D85 standalone codec API remains valid; its runtime-gap status is superseded by this authorized integration. No broad PROJECT_RULES change, commit permission or human acceptance is inferred.


### D85 — Validated weather profile and standalone snapshot decoder (2026-11-17) — Status: LOCKED by approved Phase7.1a; full557/557 verified; standalone foundation only

Owner approved16 paths for DATA horizon3/strict profile validation and independent current-wire decoder. Preserve all weather entries/probabilities/order/flags, all535 old tests/goldens/runners, current forecast/RNG/savev11/runtime/UI. Pure canonical three-field codec validates complete signed JSON-safe seed/known IDs/exact horizon and returns detached result or explicit errors, without mutation/randomness/events/fallback. Current save_v11 weather component is the new codec fixture; not a new weather RNG golden.
Existing official path validator delegates strict WeatherProfile checks, with missing/unloadable/wrong Resource handling. No new tool/scene/input/state owner/save schema. The new codec is intentionally unconnected. Existing WeatherState's custom arithmetic and unsafe raw restore/no day-token are recorded legacy gaps; no DetRandom rule is waived. Actual runtime wiring/RNG/tag/day/migration work requires a separately approved7.1b plan. Prior D19 weather/day-night/season features remain in use, no competing WeatherService.
Focused42/42 passed before full verification. Exact later acceptance/limits in PROGRESS; no automatic commit or new human/visual acceptance claim.


### D84 — Integer recipe caps and actual catalog validation (2026-11-16) — Status: LOCKED by approved Phase6.7; full535/535 verified; handoff2026-11-17

Owner approved all24 paths, explicit recipe.unlock_house_level mapping1->15/2->40/3->120 per game hour,24 hours per existing duration_day, current crop80 and unpriced output0/savev11 preservation. Mapping is a validator policy, not a new runtime stage/house system or recipe repricing.
Pure stateless catalog/economy rules validate actual registered Resources, reciprocal references, runtime single output/slot limits and exact opportunity-value inequality with checked int64 arithmetic. Keep every prior validator gate; defer standalone initialization to read real autoload catalog and append recipe gate. New detached recipe/machine readers do not rewrite registration. Standalone negative fixtures clone in memory and must fail with actual exit1; never modify shipped data or registry.
No UI/scene/input/production/save/crop/coop change, old tests/goldens/runners/bounds retained. OS.execute test subprocesses reuse hidden isolated bounded helper, not player save directories. Targeted28/28 and explicit CLI normal0/negative1 checks passed before complete gate. Final evidence/status in PROGRESS; no commit or human acceptance claim.


### D83 — Playable fixed-site coop, modular operations and save v11 (2026-11-16) — Status: LOCKED by owner-approved Phase6.6d; full516/516 verified; human acceptance separate

Owner explicitly approved96 paths and the700-for4 bundle, fixed south-house site, existing E operation UI, daily/save integration and exact compatibility patch. Resource owns site geometry/pricing; existing item prices20/30 and crop/machine balance stay. New/legacy games remain unowned0 without free food. Small screen/summary/controls scenes plus snapshot/presenter/runtime/flow/site-view responsibilities preserve DATA->DOMAIN->VIEW.
One source lock spans purchases/feed/collection/completed-day reservations; opaque tokens and captured refs/terms protect synchronous callbacks. Debit then grant, exact rejected-debit refund, preserve independent bag/wallet changes; unexpected nonstandard added counts fail closed. Main/UI/day-end lifecycle safe points prevent half-state persistence. DaySimulator implements farm->animals->machines and removes Main's separate machine listener; source reserves captured production before farm notifications. No load/render progression.
Only owned site adds collision/dynamic NPC solids; clear/rebuild stale grid flags and recompute same-target routes, clear derived obstacle before NPC restore. Deny occupied site instead of deleting actor/crop/machine progress. Code-native site illustration matches current palette; no replacement assets/new input/autoload/event/old scene edits.
V11 adds validated purchased daily state and golden; v1-v10 defaults only new coop unowned0. Preserve prior fields and water format introduction10. Exactly27 output-version assertions plus2 absent-coop expectations change in23 old tests according to preapproved patch; no old fixture/golden/runner/name/assertion-count weakening. Evidence/current verification history in PROGRESS. No automatic commit/human F5 acceptance claim.


### D82 — Separate feed buy20 and guarded real bag debit (2026-11-09) — Status: LOCKED by owner-approved Phase6.6c; full492/492 verified, animal runtime deferred

Owner first chose “Thức ăn riêng: mua 20 xu; giữ trứng 30 xu”, then approved exact20-path domain/multi-file plan. Register chicken_feed/material/99 stack/buy20/resale0/current fallback and bind config feed_item_id; retain egg30 and autumn_wheat42. Old wheat20 table no longer determines this feeding identity. Current seed shop stays unchanged; no food purchase availability/UI is claimed.

Reserve requested hens on the same coop owner before actual InventoryState debit. Shared owner guard covers feeding and collection across facades/raw methods; collection_busy remains compatible, feeding_busy is explicit. Whole debit completes before notifications, then captured hen authorization commits. False debit grants none and unlocks; mutable config/future facade refs cannot redirect/strand current paid terms. Preserve independent bag callbacks; no snapshot rollback or another item/wallet owner.

Tokens are opaque/transient, matching operation only; old four-field codec andv10 bag schema remain. Main/animal world/day simulation/feed UI/purchase/coop-save wiring is deferred. Preserve all479 old cases/goldens/runners/bounds and18 art checks. Exact acceptance/history in PROGRESS; no commit/stage/push requested.


### D81 — Registered eggs and owner-shared guarded collection (2026-11-08) — Status: LOCKED by owner-approved Phase6.6b; full479/479 verified, animal runtime deferred

Owner approved18 paths: register documented egg/30 and existing99 stack/produce, buy0 and generic icon fallback; add collection into real InventoryState without animal Main/day/UI/save wiring. Defer actual feed mapping and wheat42 versus historical20 economics. No new balance guess or asset.

Source reservation must live in the coop owner, not one facade, so second facades and raw feed/day/take/reset/restore cannot replay/mutate the buffer during item signals. Opaque token and valid remaining amount authorize settlement; serialization remains four fields and future runtime must guard busy saves. Captured original refs retain command context after facade reconfiguration; config invalidation cannot strand a valid remaining output settlement.

Normal real InventoryState whole-capacity preflight blocks full bags unchanged; source is reserved before one full add, then cleared on success. Rejecting0 restores all; valid partial-added-count fault restores only remainder and reports partial_transfer. Independent legitimate bag callbacks are retained without whole-owner rollback. This defensive fault path is not partial-full-bag gameplay. Truthful added-count owner contract remains required; invalid settlement fails closed.

Old18 C2 visual asset checks keep identical members; newly registered egg receives logical/translation checks and approved existing fallback instead of a forced historical3D model. All466 old tests/goldens/runners/bounds and current savev10 remain. No stage/commit/push authorization. Exact verification and history in PROGRESS.


### D80 — Standalone daily chicken-coop state before inventory/runtime integration (2026-11-08) — Status: LOCKED by owner-approved Phase6.6a; full466/466 verified, runtime integration deferred

Owner approved the exact14-path plan after h3. Implement documented4-hen capacity,1 feed/hen/day,1 egg/fed hen/day through Resource data. Explicit standalone initialization only; no free runtime herd. Approve partial feeding by counts and retention/accumulation of uncollected eggs, with no invented small gameplay buffer cap. Unfed hens produce nothing and never die.

Require exact current completed day for one advancement; old/duplicate/skipped days fail atomically, no automatic catch-up. JSON precision bounds protect full-herd product/output/day arithmetic. Trusted raw feed/take primitives are not authorized inventory commands and must remain inaccessible to player input until a separate atomic transaction layer is approved. No actual feed mapping/registry/price/art/placement/purchase/UI/day-path/save integration in this foundation.

State serializes four integer fields from its first implementation. Require prior valid config and complete valid known fields; accept integral JSON floats, ignore extra keys, reject malformed/missing/overfed snapshot as a whole with warning while retaining previous state. Preserve pending eggs; no partial clamping into new production. Existing runtime savev10,457 tests/goldens and runner bounds remain unchanged. Current wheat42 versus historical20/egg30 economics are not silently reconciled. Human acceptance/commit separate; no commit requested.


### D79 — First watering-can upgrade through modular Bag confirmation (2026-11-08) — Status: LOCKED by owner-approved Phase6.5h3; full457/457 verified, human F5 pending

Owner explicitly approved the42-path plan after finite watering/refill/HUD/savev10 handoff. Reuse existing first20→40/200 Resource and WateringCanUpgradeService over actual Main can/wallet. Upgrade preserves remaining water, including empty; no refill grant or later tier/price. Existing savev10 already persists this state and stays unchanged.

Add a separate Bag footer entry and three small lazy shared-theme scene/script pairs with snapshot/presenter. Actual current/target/price/remaining/wallet remain visible with insufficient funds. Revalidate displayed terms and existing domain command; shared busy protects safe points and cross purchases. UiCoordinator remains sole modal/pause/input-lock authority; native GUI gets focus/accept, Escape closes, explicit Back returns safely. Lifecycle generic close never reopens Bag.

Classify existing watering rollback as reduced expense and localize both actual ledger reasons; preserve raw rows/independent callbacks/save schema. Add new tests only; retain all446 old tests/assertions/goldens and unchanged runner bounds. No additional balance/source/map/Theme/InputMap/domain-service changes or commit authorization. Human editor acceptance remains separate.


### D78 — One runtime can, explicit dry-bank refill and game save v10 (2026-11-08) — Status: LOCKED by owner-approved Phase6.5h2b; full446/446 verified, human F5 pending

Owner explicitly approved the54-path plan,20-use activation/all-manual-path routing, three existing source banks/E when can selected, small HUD meter and versioned persistence. Exactly23 old current-version expectations in19 named test files may change9->10; assertions/gameplay/input goldens/runners remain. All other scope is preserved.

Reuse D71 WateringCanState/WateringService unchanged; Main alone owns actual state. New Runtime validates real Player/context/reach/permission and prevents reentry/half-debit saves. New stateless refill service (class WaterRefillService) authorizes existing shared dry-bank geometry, no cost/time or UI-supplied source. Existing wither recovery is retained; no crop-policy change. Water notification is local after completed commands, not a new global event/autoload.

Selected water tool + valid dry bank makes existing E refill before the nearby bin; other tool contexts retain original bin/shop/bed/NPC semantics. This is the approved resolution of well/bin overlapping reach. Full-can context gives full feedback without mutation/sale. GUI/menu E remains exclusive. No new InputMap binding or water-on-source mouse command.

Display actual water alongside existing toolbar caption in a separate small Theme component. Retain eight slots/caption/selection/right cards/overall HUD bounds, native wheel behavior and scenes. No Theme/font/asset substitute.

Savev10 adds capacity/charges. Oldv1..9 intentionally get data-owned full base because no prior can state existed; any forged old field is overwritten. Current corruptv10 stays conservative/empty rather than getting a fresh grant. New game alone resets full; repeated load/Continue/overnight/rain preserve actual charges. Known40 capacity loads, but first40/200 purchase UI/later tiers remain deferred. Old goldens stay, new v10 sample added. Human F5/commit remain separate from automation.

### D77 — Expanded source world before runtime watering (2026-11-07) — Status: LOCKED by owner-approved Phase6.5h2a; full430/430 verified on2026-11-08; human F5 pending

Owner requested well beside the house, stream and pond, plus a larger map, and approved the concrete map-first scope. Ground85×85/player39×39/scenery43×43 and camera center/pan extents are Resource-owned. Existing farm/east parcel/anchors, NPC targets and save-v9 rights/progress stay; a larger walking region grants no farmland.

WaterSourceData/Config owns stable IDs home_well/forest_stream/east_pond, rectangles, name keys, label cells and orthogonal dry approach waypoints. WaterSourceRules is stateless and Node-free: lookup, shore/access/reservation geometry and overlap validation. Shared WorldLocations.get_solid_regions deduplicates source footprints with original solids; exact old well prop reuse is permitted. Player physics, NPC AStar (clipped to unchanged nav region) and parcel exclusion use this shared geometry. No cyclic Resources or second state owner.

WorldPresentation generates WaterSources under the actual Ground parent WorldCanvas, above Ground and below Farmland. Sharing this CanvasLayer is essential: a child of GrayBoxWorld's default canvas drifts from the WorldCanvas camera transform. Well art alone joins existing Objects y-sort. New WaterSourceView uses actual grid conversion, localized plain labels and paused cosmetic ripples; no interaction binding/prompt. Passive scenery is bounded and avoids routes/banks.

This slice does not activate can consumption/refill/HUD/upgrades or save-v10. Existing unlimited manual watering is preserved deliberately until every manual path, real source/reach feedback, water counter and versioned persistence can be integrated together under a later plan. No swimming/fishing/bridges/new story destination/parcel or bitmap replacement.

### D76 - Live world labels and transient feedback on locale switch (2026-11-07) - Status: LOCKED by owner-approved D72-C4; full automation421/421 verified; human F5 pending

Owner explicitly approved updating existing player/shop/bin/NPC-home labels when switching vi/en and dismissing old-language transient toasts. WorldPresentation keeps references to its created anchor art; current player name/existing translation keys refresh only labels and queue_redraw, including while paused. NpcSystem refreshes its existing home map from actual NpcData. No world rebuild, movement/collision/appearance/domain/quest/schedule/save-v9 change; user names are preserved.

Toast API already receives formatted strings: clear old messages on an actual locale change, retain them on same-locale apply, never infer translation keys or replay events. Translation notification traverses the tree, so hide old cards immediately and defer freeing their captured instance IDs; normal show_message flushes those old IDs first, preserving same-turn new feedback. Timer callbacks bind IDs rather than freed Node references. Max-two/three-second real-time view lifetime and public clear/show_message stay unchanged. No persistent field/new caller metadata.

First new focused run exposed busy-parent/free-during-notification errors and an engine crash; preserve its logs/source in the C4 backup focused-attempt1. Fixed the view lifecycle rather than suppressing errors. Updated only the new test's immediate assertions to require synchronous hiding followed by deferred removal, and cleared the fixture's prior Apply-result toast before same-locale identity checks. All old tests remain untouched. Focused second run9/9,144 assertions/3.88s passes. First unchanged full C2 gate PASS parse/data/headless63/63/graphics421/421 (21249 assertions)/Main; group GUT75.899s/101.033s, combined graphics wall187.949s with unchanged180s per child. Five same-Main captures inspected; old C1-C3/P1 captures/tests preserved. Exact reproduction before/after and11-file scope/diff/raw evidence in PROGRESS. No commit/human F5 acceptance implied.

### D75 - Toolbar selection and four-item pages (2026-11-05) - Status: LOCKED by owner-approved D72-C3; full automation418/418 verified; human F5 pending

Owner explicitly approved correcting the remaining inherited highlight/caption defect and moving private item pages from5 to the actual four displayed item buttons. Keep eight slots: hoe/shovel/watering/harvest then four item requests. Display derives item highlight from TOOLS.size() and only a valid populated visible index, resets stale caption and uses existing localized item titles/icons/quantities. No inventory/domain/gameplay/save/InputMap/scene/Theme change.

HotbarPanel derives private page size from the actual toolbar button count minus tools in select/remap. Bag index8 remains legacy key9's selected item, now visible first on page8-11 (active_index4). Wheel stays page-local with existing camera/GUI ownership and skips absent slots. Public APIs/signals/real item IDs stay unchanged; no hidden fifth item slot.

Explicitly approve correcting the obsolete test_isometric_hud key9 offset expectation6 ->4 plus real identity/title/style/icon assertions, and C1 camera test's obsolete hidden-index4 case ->visible second-page advancement. Preserve all test functions and other assertions; add separate actual native/render/remap coverage. First focused11/11,1296 assertions/17.426s PASS; first unchanged C2 official batch PASS parse/data/headless63/63/graphics418/418 (21153 assertions)/Main. Group GUT99.924s/101.975s, combined graphics wall216.068s;180s per child unchanged. All8 C3 screenshots inspected and20 C1/36 P1 captures retained. Exact11-file diff/scope/logs and preserved old method/assertion coverage are in PROGRESS; no commit or human F5 acceptance is implied.

### D74 - Complete graphics suite in two sequential bounded processes (2026-11-05) - Status: LOCKED by owner-approved D72-C2; full automation415/415 delivered

Owner approved the concrete C2 plan after C1 hit the same180s process bound three times. Replace only graphics orchestration: discover all root tests/unit/test_*.gd in ordinal order, alternate into two groups, run sequentially with existing graphics arguments/-gtest CSV and unchanged180000ms bounded wrapper per child. No test declaration/assertion/capture is removed or weakened; parse/data/headless/Main gates, C1 game/data/art/save-v9 and GUT stay unchanged. Total two-child wall time may exceed180s; report it honestly.

Fail closed on missing/duplicate/extra script coverage, declared test-count or summary mismatch, missing complete success marker, child failure/timeout, error/failing/pending/orphan/leak output or test-source change. Keep separate logs plus discovery/hash manifest and combined totals. Current inventory110 scripts/415 tests partitions55+55 scripts and210+205 tests; nonstandard future test declarations require explicit runner-contract review. C1 baseline/timeouts/diff remain preserved; full measured result and scope evidence go in PROGRESS. No commit/human editor acceptance is implied.

D74 measured result: official first C2 run PASS parse/data/headless63/63/graphics415/415 (20556 assertions)/Main. Group GUT times90.167s/121.726s; combined graphics GUT211.893s/wall225.897s. All test/GUT/bounded-helper/C1 source bytes stay unchanged;47 validator +6 shadow orchestration probes and actual missing-executable rejection pass. External Editor rewrite of project.godot during the interrupted session is preserved and separately hashed/diffed, not included in C2 scope. Exact logs/audit/limits in PROGRESS. Human F5/commit pending.

### D73 - D72 camera/visual handoff completion (2026-11-05) - Status: LOCKED by owner-approved D72-C1; full automation verified through D74

Owner confirmed the other agent stopped, requested its graphics slice be finished, then explicitly approved D72-C1/ALLOW_LIST in PROGRESS. Preserve inherited D72 art/cosmetics/five zoom levels and all prior gameplay/save-v9/domain/old tests. Separate the inherited28-file delta from our completion diff; backup/SHA256 evidence and native baseline probes are recorded in PROGRESS. No commit is authorized.

Native input proved Shift/toolbar wheel was consumed by camera before hotbar; fix routing so plain map wheel zooms and Shift/toolbar wheel cycles exactly once, with existing GUI/modal/placement ownership. Camera pan bounds move to data with the inherited defaults; projection/movement/collision/InputMap stay unchanged. Ready machine jobs must leave working animation, including paused model refresh, without advancing/collecting/mutating jobs from presentation.

Keep active procedural avatar/world/frame renderers and appearance customization. Generated PNGs remain draft/offline outputs; document their actual role rather than claiming runtime references. Finish safe deterministic asset generation and pure file/dimension validation using isolated output roots; source PNG/imports stay protected. Add separate native/animation/visual tests, retain old tests/P1 and180s bound, inspect actual render captures, and distinguish automation from human F5 acceptance.

D73 measured handoff: focused7/7,253 assertions and20 reviewed captures pass; three unchanged full runs time out at180s before a complete summary. Full completion PASS is not claimed. Scope/hash/diff evidence and proposed separately approved D72-C2 runner split are in PROGRESS. At that handoff the protected runner and old tests remained unchanged. Subsequently owner-approved D74 changes runner orchestration only and certifies all415 tests with old test/C1 source bytes unchanged.

### D71 - Standalone watering-can foundation and first price mapping (2026-11-05) - Status: LOCKED by owner-approved Phase6.5h1; foundation automation delivered, runtime deferred

Owner explicitly approved "Phase6.5h1:20->40 at200" in the session. This resolves only the first transition of the ambiguous20/40/80 versus200/600/1800 table: fresh capacity20, first upgrade target40/price200, remaining water preserved. No80 tier, later price assignment or automatic refill. All terms live in a Resource. Invalid/missing charge data restores conservatively to0; fresh configure starts full base20.

Implement pure Resource validation and standalone state/manual-watering/upgrade domain adapters only. WateringCanState serializes capacity/charges from first implementation; atomic primitives emit no external callbacks. WateringService reserves one for actual successful crop watering, rejects redundant/invalid work and refunds only its reservation on failed command. Upgrade uses actual WalletState with explicit spend/refund reasons, guards reentry and preserves independent callback changes. No economy refactor, new autoload/global signal or parallel simulation path.

A transient refill replacement revision is an implementation safeguard within D71: refill/load/reset subsumes an older water debit, so its rejected-command refund must not erase later independent consumption. No persistent field or additional gameplay tier is introduced.

Runtime/Main/tools/UI/refill source/scene/input/save-v9/goldens/old tests/P1 stay unchanged. No player-visible charge limit until a separately approved coherent refill/HUD/save integration exists. Low-level refill is trusted domain functionality, not source/reach authorization. Rain/bulk/day simulation remains outside manual-can consumption. Existing game-save version stays9; standalone JSON is not a save migration. Actual verification/audit and pending human/commit status will be recorded in PROGRESS. No commit is authorized.

### D70 - First bag upgrade and existing-v9 persistence (2026-11-05) - Status: LOCKED by owner-approved Phase6.5g; human F5 pending

Owner explicitly approved Phase6.5g and its exact ALLOW_LIST in PROGRESS. Preserve D40's40-slot base; adapt the master-plan stage1 +12 slots/300 coins to a single52-slot target. Keep later tiers and the ambiguous watering20/40/80 versus three-price mapping deferred. A legacy bag already at/above52 is complete without another charge or shrink; intermediate capacities show their actual before/after target. No new gameplay values in scripts: Resource owns12/300 and references the actual base.

Use existing WalletState/InventoryState owners, no economy/inventory service refactor or extra saved upgrade flag. Guard expected-capacity expansion; pay once, refund only its debit on rejected grant, preserve legitimate callback changes. Main shares land/bag transaction safe points for save/load/reset/title and rejects cross-modal callback reentry. New Game resets the purchased capacity to base40; ordinary clear() preserves it. Existing-v9 capacity serialization covers the upgrade, so SaveService/goldens and all prior tests stay unchanged.

Footer entry and lazy three-part confirmation reuse the shared Theme/native GUI/UiCoordinator. Existing grid/slot/filter/discard/toolbar code is preserved and tested through slot52. No key/NPC/shop role or old scene edit. Validation lives in pure Resource data so the --script data gate does not compile autoload-dependent command owners. Shared4096 integrity value is unchanged. Test/log/scope evidence and remaining manual acceptance are recorded in PROGRESS; no commit is authorized.

### D69 - Usable land expansion, modular shop entry and save v9 (2026-11-05) - Status: LOCKED by approved Phase6.4b; human F5 pending

Owner explicitly approved "Duyet Phase6.4b, bat dau trien khai" through the approval question recorded in the session. Exact approved scope is in PROGRESS. Integrate D68 state/service with Main tools/build/scenery/save and expose actual first-east purchase through a small modular shared-Theme panel. No new parcel/price/key/merchant/normal-game shop access: existing debug Ctrl+M shop header is the entry. No commit is authorized.

Ownership grants work permission, not exclusive NPC navigation. Keep Linh stream waypoint/routes and world/player bounds unchanged. Clear generated passive scenery and collision only for owned regions; reset/load restore deterministically. Existing tilled plots outside base remain usable for old-save progress without granting surrounding land; legacy machines remain operable and in-place idle rotation stays compatible. New empty work/placement/move targets require ownership.

Main keeps a single persistent land state and service; LandRuntime owns transient request/view guards. Reject callback-triggered Main save/load/new-game/title requests during payment/grant. Low-level D68 callback semantics stay unchanged. Save v9 adds purchased parcel IDs, old migrations start with none, old goldens stay intact. Only current-version expectations/messages change in sixteen prior tests. buy_land_rollback is a ledger refund, never false income. UiCoordinator keeps modal/clock/Player authority, contents are lazy to preserve test/startup costs, and the180s official bound is unchanged. See PROGRESS for actual tests and protected-tree audit.

Format of every entry: **ID — Decision — Why — Consequence — Changeable until — Status.**
Rule: never edit an old decision in place. To change one, add a new entry "Dxx supersedes Dyy" and mark the old one `Superseded`.
Status `DEFAULT` = a recommended default chosen for you. Change it to `LOCKED` once YOU have read it and agree (tick the box). Date written: 2026-10-24.

### D68 — Land-expansion domain foundation (2026-11-04) — Status: LOCKED by approved Phase6.4a; standalone automated acceptance delivered
- Owner approved standalone Resource/data/domain work and the proposed farm_east_1 parcel Rect2i(6,0,6,6), base region Rect2i(0,0,6,6), first500-coin price and documented2.2/round-to50 formula. Pricing parameters are integer Resource fields500/11/5/50; no float coins.
- LandExpansionConfig references the existing IsometricWorldConfig and NpcWorldData Resources so all new domain entry points can use the same bounds/static-solid validation. Legacy LandParcelData/locks stay. East parcel fits bounds/solid rectangles; natural scenery and the existing linh_stream waypoint in that area still require a later integration decision. Do not expose a purchasable/usable runtime lot yet.
- LandOwnershipState is the only new persistent domain owner and has serialize/deserialize immediately; it stores a validated ordered prefix of known IDs, not Nodes/pixels. Stateless service uses actual WalletState, validates next ID/price/funds, guards reentry, grants once and refunds only its debit if grant fails. No whole-wallet/state rollback over independent callback transactions.
- This slice does not wire Main/SaveService/UI/world; game saves stayv8. Later integration needs its own coherent scene/scenery/tool/build/save migration scope. Existing scenes/assets/goldens/runtime/old tests/runner stay protected; no commit/push.
- Earlier final-renderer attempts timed out twice at180s with a human F5 session active. After owner confirmed it stopped, unchanged final source passed official377/377,18683 assertions,154.692s plus parse/data/headless63/63/Main; focused8/288 also pass. Keep the timeout history and avoid attributing all variation to a single proven cause. No bound/gate/source/runtime-integration change or commit/push.

### D67 — Previewed nearby idle-machine relocation (2026-11-04) — Status: LOCKED by approved Phase6.5f; automation delivered, human F5 pending
- Owner approved the exact20-existing/two-new-script scope. Reuse current modal/ghost/components and the job-safe facade; retain source placement/occupancy/job during preview. No stock reservation, remove/re-place, purchase/refund, new balance/data/schema/input/scene/asset or physics rule.
- Move UI requires an actual nearby fully idle source matching a detached machine_id/cell/rotation snapshot. Different targets obey D66's reserved-region/reach/Player/plot rules and D65 source/target/collection guards. Confirm revalidates before the existing atomic move/cleanup/rollback path.
- Idle in-place rotation/no-op preserves existing occupancy/jobs, including legacy source crop/outside-region cases because no new cell is occupied. Other facade callers retain D65 active in-place rotation semantics; this UI does not expose that exception for busy machines. Identical fungible same-ID replacement has no persistent instance identity; do not invent one.
- Extend the existing flow/status/footer/controller/snapshot/presenter only; Main/Player/world/tools/UiCoordinator stay. Existing R/Q, LMB/Space, RMB/Esc and native GUI precedence remain. Lifecycle interruption clears transient source context. Focused24/24, clean renderer13/13 and official369/369 at155.38s plus parse/data/headless/Main PASS; human F5 pending, no commit/push.

### D66 — Mouse placement and nearby idle return (2026-11-04) — Status: LOCKED by approved Phase6.5e; automation delivered, human F5 pending
- Owner approved the exact Phase6.5e scope. New Resource-owned6x6 region matches the current reserved farm footprint; new placement obeys existing reach/stock/occupancy/D65 job checks and cannot overwrite tilled/cropped/Player cells. Old placements remain loadable; no land/house/physics/save schema change.
- A stateless domain request adapter revalidates actual context at confirmation/return. Build gets shared read-only can_place/can_remove previews. Nearby idle return uses D65, no refund/early output collection. Hoe/seed are blocked on machine cells; existing legacy crop water/harvest/shovel stay supported.
- Shared UiCoordinator owns the full-viewport modal/clock/Player lock; small overlay/status/flow/projected-ghost components own transient UI only. Existing grid APIs, manifest art, Theme and input actions are reused; open_build stays unbound. Confirm places one, cancel reserves nothing, lifecycle/modal interruption discards pending UI, and native controls cannot click through.
- Keep debug-only shop/exact Ctrl+M/E/house-level1 and original transactions. No direct move UI, new sprite directions, collision, generated art or package. Current180s test bound/error gates remain; no commit/push.
- Earlier verification: focused79/79 and clean native16/16 passed; official complete graphics timed out in three runs. The agent stopped fixes under AGENTS §5 and preserved logs/diff for profiling. Lazy controls/cache/coalesced layout and render-once UI-layout capture retain all assertions/images; no runner/bound/error-gate change.
- Owner-authorized profiling continuation: no source/test/runner change. World/review6/6 pass; full profile359/359 at172.945s, then unmodified official batch PASS with renderer359/359 at173.546s plus parse/data/headless63/63/Main. Total render/fixture cost is close to180s; inventory is the largest measured group29.8s, not an established sole cause of variance. Record the remaining timing risk rather than claiming a permanent performance fix. Human F5/commit pending.

### D65 — Job-safe machine placement commands (2026-11-04) — Status: LOCKED by approved Phase6.5d; automation delivered, human F5 acceptance pending
- Owner approved Phase6.5d's exact source scope. MachineBuildService.configure(state, operations) now requires the actual operation owner; Main initializes/wires both and the placement fixture follows the explicit contract. Missing dependencies fail closed.
- Operation preview validates job identity/empty-idle state and honors the collection guard. Different-cell move/remove reject working/buffered/corrupt/orphan jobs; successful place/move/remove clean only valid empty idle rows after placement success. Failed placement does not delete jobs. Cleanup rejection restores build-owned snapshots.
- Rotation preserves job bytes; same-cell move retains the existing rotate-in-place semantics, including active jobs. Current sprites stay single-direction. Reentrant build/cleanup during reserved collection is rejected even when the job temporarily looks idle.
- No UI/build mode/scene/art/data/balance/InputMap/day simulation/save-v8 field or version change. Low-level placement primitives remain codec/unit operations; runtime VIEW commands must use the connected facade. No silent orphan-output repair, refund or duplicate return. No commit/push; human F5 remains pending.

### D64 — Modular machine shop and operation presentation (2026-11-04) — Status: LOCKED by approved Phase6.5c; automation/render review delivered, human acceptance pending
- Owner approved the exact Phase6.5c ALLOW_LIST. Five new scene/script components under ui/machine plus read-only snapshot/presenter and transient controller compose reference10 using the existing shared Theme and machine manifest art. Existing MachineShopPanel/public Main boundary stays compatible; no old .tscn edit.
- Show real machine/recipe/price/owned/job/buffer data, actual service results and explicit test house-level1/access. No merchant profile, selling/buyback/batch/discount/house/build-ghost system is invented. Current test placement remains labelled as such.
- UiCoordinator keeps modal/clock/Player/sleep authority; centered wide layout and native GUI precedence extend only the machine panel. Rebuild after callbacks, preserve valid selection/focus/scroll and invalidate stale operation selections on reset/load. Domain/core/data/assets/Theme/InputMap/save-v8 remain unchanged; safe collection stays under D63.
- Add translations for the existing seven machine-name keys. Update credits only for reused asset usage; no new outside art/license claim. No commit/push; current180s graphics bound and all gates remain.

### D63 — Safe machine output into inventory (2026-11-04) — Status: LOCKED by approved Phase6.5b; implementation delivered, human acceptance pending
- Owner approved the Phase6.5b plan/ALLOW_LIST. Keep D62 Player/crop/machine behavior; no commit/push.
- Register the seven already-referenced temp_* outputs as ItemData (other, default stack99, zero buy/sell) with approved localized labels. No output-ID/recipe/machine/crop balance or save-shape change; final trade values/art remain deferred.
- MachineOperationService owns capacity/identity/ready checks and all-or-nothing collection, with transient reentry guard and snapshots. Preserve raw take_output for existing low-level callers; UI uses safe collection only and reports actual outcomes.
- UI rebuilds after callbacks and preserves valid operation/focus; no UI item grants, false success, duplicate payout or cleared output on a full/unknown-item failure. No new house/input/scene/production system.

### D62 — Restore Player while retaining new crops/machines (2026-11-04) — Status: LOCKED by explicit owner request
- Owner chose “Chỉ khôi phục nhân vật, giữ cây trồng và máy móc mới”. Supersedes only the manager-removal D50 entry immediately below (the separate imported-ground D50 is not revoked).
- Restore HEAD's Player/child Camera2D, movement/collision/reach, customization/Character UI, modal/sleep gates and legacy saved logical position. Merge mixed Main/world/UI files rather than resetting all pending work.
- Retain supplied crop data/assets/care rules/shovel, machine inventory/shop/build/operation/presentation and their save fields. Keep exact Ctrl+M machine shop with Player locked behind its overlay; new machine cell selection remains available.
- Backup all pending existing files before restoration and verify protected bytes afterward. No reset/clean/commit/push; report tests and any remaining pre-existing failures honestly. Camera manager-drag tests migrate to restored follow/zoom/lock semantics.

### D50 — Manager farm camera and legacy player removal — keep stamina, remove avatar and character screen — Status: Superseded by D62 (2026-11-04)
- The active game has no player node or movement authority. Legacy save `player` payloads are ignored during load.
- Camera input is bounded mouse/touch drag and wheel/pinch zoom. Zoom defaults to 0.5 and is clamped to 0.35–1.0 through `IsometricWorldConfig`; keyboard camera movement is not used.
- Direct cell/object selection replaces player distance checks. Ctrl+M remains an exact debug-only action for the machine shop.

---

### D01 — Technical direction: real 3D, orthographic `Camera3D`  `[ ] confirmed`  Status: Superseded by D33
- Logical grid is a 2D `Vector2i` mapped onto the XZ plane. Aseprite is for UI icons / pixel textures only, not world sprites.
- Why: day/night/rain lighting, shadows; the depth buffer solves draw order (avoids isometric 2D Z-sort pain); multi-cell buildings do not break y-sort; many CC0 3D assets exist.
- Consequence: heavier asset pipeline for a solo developer.
- Fallback rule (spike): if the 1-week asset spike (Master Plan 10.9) cannot produce 1 character + 1 crop + 1 ground tile at the right scale/angle, switch to the 2D plan (Master Plan 10.8).
- Changeable until: before Phase 0.4 (gray-box). After that, practically never.

### D02 — Platform: PC first (Windows), keyboard + mouse  `[ ] confirmed`  Status: DEFAULT
- Mobile is a different project (UI, performance, input). Release target: Steam and/or itch.io.
- Changeable until: before Phase 1.

### D03 — Time model  `[ ] confirmed`  Status: DEFAULT
- Three clocks, never mixed: real time; in-game clock 06:00 → 26:00 (02:00 next day), one game day = `DAY_REAL_SECONDS` (default 720 s = 12 min, a data parameter); crop/machine counters in `day_index` and `total_minutes`.
- Crops store `planted_day`; machines store `finish_at_total_minutes`.
- Closing the game pauses the world (MVP). Offline progress is an optional Phase 11 feature: capped (e.g. 5 game days per launch), negative events off, backwards-clock detection, same `simulate_day()` path.
- Changeable until: before Phase 2 (GameClock).

### D04 — Authority: local-authoritative world; server only for non-competitive social  `[ ] confirmed`  Status: DEFAULT
- Gifts (cosmetic / capped), friend snapshots, capped community-project ledger, "casual" leaderboard. No client-reported coin/score is trusted.
- Changeable until: before Phase 10.

### D05 — Monetization: premium (one-time purchase)  `[ ] confirmed`  Status: DEFAULT
- No IAP, no premium currency, no gacha, no ads. Only Coin (+ a non-currency "valley development" progress value).
- Changeable until: before Phase 5 (economy).

### D06 — Pressure philosophy: "Telegraph – Explain – Counter"  `[ ] confirmed`  Status: DEFAULT
- Weather/events never silently punish and never destroy a season of crops. Every negative event is forecast (when the station is repaired), explained (ecology journal) and counterable.
- Changeable until: before Phase 7.

### D07 — Languages: Vietnamese + English from day one  `[ ] confirmed`  Status: DEFAULT
- `tr()` everywhere, `KEY_SNAKE` keys, `localization/` files. Font must render all Vietnamese diacritics (Phase 0 test).
- Changeable until: before Phase 3 (UI). Adding more languages later is always possible.

### D08 — Godot version & renderer  `[x] confirmed`  Status: Partially superseded by D33 (Jolt only; engine version and renderer retained)
- Pin Godot `4.7.2-stable`, renderer `Forward+`, and Jolt Physics.
- Only patch releases may be adopted mid-project, deliberately, after running all tests + golden tests.
- Changeable until: before Phase 0.4. Treat as frozen afterwards.

### D09 — Controls  `[ ] confirmed`  Status: Superseded for movement and UI shortcuts by D33/D34; existing bindings retained until their migration step
- WASD camera-relative movement; mouse targets a cell within reach (2 cells around the player); `use_tool`; hotbar keys 1–9. Gamepad later (Phase 11) but action names are standard from the start.
- Changeable until: before Phase 4 (ToolAction).

### D10 — Daily scarcity ("bottlenecks")  `[ ] confirmed`  Status: DEFAULT
- Without limits players "do everything, then sleep". MVP limits: number of tillable plots (unlocked by expansion), watering-can capacity (upgradable; auto-irrigation unlocks in Chapter II), the 02:00 day end (no harsh penalty — wake up a little later, lose nothing), daily order refresh and machine slots, inventory capacity.
- No stamina bar in the MVP; optional in Phase 11 if playtests show the need.

### D11 — Reasons to stay up at night  `[ ] confirmed`  Status: DEFAULT
- Merchant Minh at the market 17:00–22:00 on set days; night-only fish / fireflies / collectibles; NPC schedules; machines finishing at set hours; end-of-day order deadlines; timed festival events.

### D12 — Naming  `[ ] confirmed`  Status: DEFAULT
- Player-facing: "Cỗ máy Mùa" / Season Machine. Code/docs: `EventDirector`, `WeatherService`, `EcologyState`. The rule-based system is never called "AI"; no LLM calls at runtime.

### D13 — Camera  `[x] confirmed`  Status: Superseded by D33
- `Camera3D` projection = orthogonal; yaw `45°`; pitch `35°`. Locked BEFORE assets are made (shadows, model heights, tile highlight depend on it). Zoom: 2–3 small levels. No free rotation in the MVP.

### D14 — Grid cell size  `[ ] confirmed`  Status: Superseded for presentation by D33; saved logical cell IDs retained
- 1 logical cell = 1 × 1 m (1 Blender unit = 1 Godot metre). Character height ≈ 1.2–1.5 cells. Buildings declare `footprint: Vector2i` in data.

### D15 — Player-to-player text  `[ ] confirmed`  Status: DEFAULT
- No free chat. Preset phrases and emotes only. If free text is ever added: filtering/moderation + report button are mandatory.

### D16 — Tools  `[ ] confirmed`  Status: DEFAULT
- Godot Editor (scenes, Inspector, run) + VS Code or Google Antigravity (code) + Git/GitHub (private) with Git LFS + ONE of GUT / gdUnit4 + gdtoolkit (gdlint/gdformat) if compatible with the pinned version.

### D17 — Director & Season Machine policy  `[ ] confirmed`  Status: DEFAULT
- Chapter I: the machine "sleeps"; weather is simple, seeded, by season. Chapter II (observation station repaired, milestone M2.4): `EventDirector` + forecast switch on. After 100% balance: "maintenance mode" (few negative events, optional challenges), never removed.

### D18 — Post-story content  `[ ] confirmed`  Status: DEFAULT
- Finishing the story is not the end: collections, free decoration, seasonal festivals, special orders, community projects, self-set goals.

### D19 — Early living-world slice scope — The requested day/night, weather and four-season systems are implemented before the Roadmap's later phase gates — Why: the product owner explicitly requested all three systems as the next continuous milestone — Consequence: the implementation remains placeholder/data-driven and does not add NPCs, economy or director systems — Changeable until: before production content — Status: DEFAULT

### D20 — MVP Economy: Distinct Seed & Produce Items, Shipping Bin, and Seed Shop with Season Filtering — Implemented dedicated seed and produce items for all crops with differentiated buy/sell values and colors, a shipping bin for selling produce near the farmhouse, an in-world seed shop with season filtering and atomic purchasing, wallet HUD integration, tutorial onboarding expansion (sell & buy), and save_version 3 migration. — Why: explicitly requested to establish the complete farming economic loop and prevent starter crop softlocks across all seasons. — Consequence: save_version bumped to 3; migration maps previous save files to version 3 with default wallet state. — Status: DEFAULT

### D21 — Phase 8 NPC/quest slice (2026-10-26) — Status: LOCKED by task scope
- Follow Roadmap 8.1–8.4: data-driven dialogue, a saved delivery quest, grid schedules, scheduled merchant visits with daily varying stock. Dog (8.5) and Chapter I content (8.6) remain separate tasks.
- Resolve the daily-merchant wording in favor of the Roadmap: prepare an offer each day, but Minh trades only during his data-defined visits (days 3 and 6 of the seven-day week), near the seed shop. Night and rain send all NPCs home.
- Keep base item prices unchanged. Merchant prices are isolated transaction quotes and cannot affect the existing year simulation.
- Use existing WalletState/InventoryState APIs as explicitly requested; do not introduce EconomyService/InventoryService refactors in this slice.
- Preserve `quests` for onboarding; v4 adds `social` for active/completed NPC quests, relationships, heard dialogue and consumed daily offers. Migrate v3 with empty social defaults while preserving all existing fields.

### D22 — UI readability and modal ownership (2026-10-26) — Status: LOCKED by playtest repair request
- Player screenshots showed overlapping inventory/pause/debug/prompt panels and unreadable hotbar/world labels. Main now owns a view-only UiCoordinator: one modal at a time, consistent close/switch input, dim background, hidden secondary HUD/prompt, and correct movement/clock restoration.
- Historical D22 implementation duplicated the runtime Theme. D37 supersedes that Theme ownership; its readability, modal and input requirements remain in force.
- The hotbar displays nine slots matching keys 1–9; I still exposes every inventory slot. No inventory capacity, item quantity, transaction, NPC schedule or save format changes.
- This supersedes the earlier 14 px presentation and simultaneous-panel layout expectations only. UI tests now exercise visible panels one at a time, real shortcut transitions, full inventories, settings, both locales and three resolutions.

### D23 — Click-through regression and cozy chibi presentation (2026-10-26) — Status: LOCKED by explicit product request
- Fix event hit ordering: the backdrop precedes modal Controls in sibling order, and GUI mouse events are not consumed by gameplay key filters. Physical mouse tests use an isolated viewport to avoid GUT's own overlay intercepting clicks. Windows app testing confirms the title/settings/new-game/backpack/close sequence.
- Authorize original SVG icons under assets/icons, generated title illustration under assets/ui, and procedural low-poly chibi characters/scenery in view scripts with gentle idle/walk presentation. Shared scenes and save v4 schema remain intact. The puppy in title art does not represent a completed dog system.
- Always show the title screen; Continue resolves both slots through load_latest; New Game initializes a clean world through existing state APIs. Icons replace repeated text in HUD/tool slots while localized names/tooltips and quantities remain.
- Whole-project audit is recorded in PROJECT_AUDIT.md/SOURCE_AUDIT.md. The user's broad completion request is acknowledged as sequential Roadmap work; Gate A/B require human/stranger evidence, and external online/release steps are not claimed complete automatically.

### D24 — Compact HUD and click-to-inspect harvest estimate (2026-10-27) — Status: LOCKED by player feedback
- The permanent nine-slot item bar covered the map. Hide its grid/caption in gameplay, retain four small tool buttons and smaller corner menu targets; full item selection lives in InventoryPanel. Existing 1–9 shortcuts remain compatible.
- Replace tiny repeated crop text with a readable, nonmodal click-selected card. Count down in game days/hours/minutes to the estimated morning growth boundary, explicitly conditional on daily watering and a suitable season. Missing a watering day moves the forecast; this does not introduce real-time crop growth or change DaySimulator/save v4.
- Clicking a crop is inspection only. Water/Harvest are explicit card buttons using the existing controller, reach checks and atomic harvest-to-inventory flow. Clicking the visual top of a mature crop must select that crop, rather than a neighboring ground cell.

### D25 — Native low-poly farm/world art pass (2026-10-27) — Status: LOCKED by player visual feedback
- Replace identical crop cubes with lightweight native 3D silhouettes for sprouts, roots, vines, stalks, grains, pumpkins and leafy crops. The same crop root remains the click target, and all crop rules/timing stay in FarmGridState/DaySimulator.
- Present the player house, seed market, shipping bin and NPC homes as visibly different view-only structures around their existing anchors. Decorative rocks/moss live outside farm cells and do not become hidden collision blockers.
- Favor restrained Forward+ filmic color, small glow, shallow fog and soft directional shadows over global illumination or expensive shaders. DayNightProfile and weather remain the data sources; the art layer never owns time/weather values.
- This task deliberately uses reproducible Godot primitive meshes rather than a newly generated bitmap/model dependency. It fulfills the requested chibi low-poly look while preserving Windows mid-range performance, source transparency and existing marker/collision tests.

### D26 — Separated farm landmarks, original effects and grounded terrain (2026-10-27) — Status: LOCKED by player visual feedback
- The player cottage stays at `(11, 0, 10)` while the shipping-bin mesh and `%ShippingBinMarker` move together to `(5.2, 0, 10)`, making home and sale destination unambiguous without changing interaction reach, save data or transaction rules. Extra cottages, path stones, grass and rocks are non-interactive visuals.
- The existing successful farming action calls now use four compact, deterministic, project-generated PCM WAV effects. AudioService prefers an existing OGG asset, falls back to WAV, and applies the already-saved effects-volume preference. No music, ambient system, economy or gameplay feedback timing is introduced by this decision.
- Ground fidelity stays primitive-mesh based: tilled cells gain view-only furrows and watered tilled cells a subtle sheen. Warm filmic fog/shadow tuning improves sunlight while DayNightProfile and WeatherState retain ownership of all clock/weather values.

### D27 — Two-product harvest and drag farming strokes (2026-10-27) — Status: LOCKED by player request
- Every current crop Resource sets `yield_qty = 2`: one seed is consumed only after a valid planting action and one mature crop grants two product items only after the existing inventory-capacity check succeeds. Yield remains data-owned, must be positive, and needs no save migration because planted plots save only their stable crop id.
- Holding the existing left-use input across farm cells reuses the established seed/water/harvest action path. A cell is submitted once per held stroke, out-of-reach cells are ignored, and inventory/harvest atomics remain unchanged. There is no new InputMap action or timed auto-farming loop.
- A default hoe click on an occupied crop remains the way to open CropInspector. Selecting the existing Harvest control now chooses direct harvest mode, so click/drag harvest no longer has to route through the inspector button.
- This intentionally raises current crop returns without changing prices. The year simulation is retained and asserts the data-defined yield; a dedicated later balance pass must set intended profit caps/prices rather than hiding this requested output change in code.

### D28 — Chibi art-core start before deferred M0 automation (2026-10-27) — Status: LOCKED by direct product-owner request
- The product owner explicitly started C0 after the clean M1 boundary while the broader `MASTER_PROMPT` M0 additions (`smoke_run`, autoplay, full capture matrix, baseline measurements/tag and global `build_assets`) remain deferred. This C0 commit must not imply that deferred automation is complete.
- C0 is deliberately additive and opt-in: a validated `ArtPalette`, generated shader/material/model calibration assets, mesh audit/build tooling and a review-only lineup. Existing runtime presentation, scenes, game logic, save schema and data IDs remain untouched.
- Palette roles and triangle budgets live in data. The contact sheet requires a normal graphics renderer and verifies calibration assets only; it does not substitute for future real-game-scene capture. Runtime outline toggling and model migrations are later chibi milestones.

### D29 — C1 cosmetics, character presentation and dog-art boundary (2026-10-28) — Status: LOCKED by approved C1 scope
- The optional normalized cosmetic value lives inside the existing opaque `profile.appearance` dictionary. It does not change save version 4: old profiles normalize to the catalogue default while all unrelated old-save progress remains intact.
- The C1 avatar rig, face, held tools, clips and reaction bubble are view-only children beneath existing player/actor anchors. Player, Minh and Linh retain their existing state, schedules, positions, collisions, interaction range and Phase 8 ownership; An and Bac Lam are generated/reviewed art assets only until their data-backed gameplay anchors are introduced by a later approved milestone.
- The dog model is a calibration/reference asset only. It does not add dog following, naming, collision, input, save data or Roadmap 8.5 behavior, preserving D21's phase boundary.
- `tools\capture_chibi_characters.bat` may make an in-memory daylight showcase arrangement only when passed through the private project command-line review flag. It starts no save, writes no save and exits immediately; it is evidence for C1 visual integration, not gameplay authority or a public debug action.

### D30 — C2 chibi farming presentation preserves farming authority (2026-10-29) — Status: LOCKED by approved C2 scope
- C2 maps the existing nine crop IDs to generated stage scenes, generated item/tool props, stickers and data-owned visual colors. `FarmGridState`, crop timing/yield, inventory atomicity, drag strokes, wallet, weather, DayNightProfile and save v4 remain authoritative and are not changed by art assets.
- `ItemData.model_path` and `ItemData.icon_path` are optional presentation metadata only. The v4 save format continues to use stable item IDs and quantities, so no migration or economy change is warranted.
- Crop picking stays on the existing logical root, not individual generated leaves/fruit. Farm VFX are spawned only after the pre-existing successful action flow returns; failed, out-of-reach, missing-item and capacity-blocked actions create no effect.
- The generated source asset scenes preserve C0 material intent. Under the current world’s daylight pipeline, C2 applies a local view-only readability material override so crop silhouettes are not lost to dark shading. This is deliberately constrained to instantiated crop presentation and does not alter shared materials, scene lighting, gameplay data or the C0 review contract.
- C2 updates the affected visual assertions from old primitive child names to the stable `CropVisual`/stage contract. Crop inspector/root-picking and drag-farming regression tests remain required, so visual replacement cannot conceal an interaction regression.

### D31 — C3 generated chibi world is a view-only M5/M6 slice (2026-10-29) — Status: LOCKED by approved C3 scope
- C3 delivers reproducible presentation for buildings, paths, water, boundary, village props, background creatures and seasonal ambience. It is not completion of later building/occupancy, ecology/director, map expansion or story mechanics: `WorldArtCatalog` remains visual-only and no save/schema/domain/input/event authority is added.
- Existing House, SeedShop, ShippingBin, NPC-home and marker transforms, collision, NPC routes/schedules, FarmView/crop picking, wallet/shop/bin mechanics and save v4 remain authoritative. C3 placements are catalogued outside farm cells and interaction reach; all ambience observes existing GameClock/WeatherState only and stays within its visual cap.
- Generated source scenes retain C0 shader vocabulary. The existing main-world DayNightProfile renderer makes the C0 toon/outline combination render nearly black on C3 geometry, so runtime C3 toon instances deliberately receive a local readable `StandardMaterial3D`; foliage/water retain their lightweight shader behavior. This fixes presentation only and does not mutate source resources, palette data or lighting authority.
- C3 intentionally replaces old primitive-child visual assertions with stable generated-asset, safe-placement, grouped-art and anchor-transform assertions. Existing farm picking, NPC/merchant marker, weather/day-night, save and interaction tests remain in the full suite, so the visual migration cannot conceal a gameplay regression.

### D32 — C4 chibi UI stays map-first and input-neutral (2026-10-30) — Status: LOCKED by approved C4 scope
- Historical C4 extended the runtime Theme using the C0 palette and Open Sans. D37 supersedes the palette/font/Theme ownership; native scene-built Controls, tooltips, localized labels and modal APIs remain in use.
- `ChibiCursor` is project-original code art above the GUI. It hides the OS cursor only for its live non-headless lifetime, restores it on exit, ignores mouse filtering and never calls tool/farm/world methods. `ChibiUiMotion` merely observes real Control signals; tool badges follow the existing tool button `pressed` signal and do not become another selection authority.
- Compact tool/menu bars are intentionally retained at their D24 footprints so the map remains readable. Full inventory and all transaction/detail UI stay modal/scrollable. Keyboard focus improves access to the title/form/settings/modal controls without adding an InputMap action or bypassing `UiCoordinator`.
- The private `--capture-chibi-ui` path starts no save load/write flow and exits after title/HUD capture. It is C4 visual evidence only; the deferred M0 full screenshot/autoplay matrix remains deferred.

### D33 — 2D isometric migration (2026-11-02) — Status: LOCKED by the migration prompt and the owner's instruction to begin
- Supersedes D01, D13, the presentation scale of D14, camera-relative movement in D09, and the Jolt part of D08. Keep Godot `4.7.2-stable` and Forward+; no engine/renderer upgrade is implied.
- Target active gameplay is entirely 2D: CharacterBody2D, child Camera2D, 64×32 px isometric TileMapLayer/TileSet, Ground/Farmland/Objects/Highlight layers and ground-origin y-sorting. Remove active Camera3D, yaw/pitch, 3D world nodes and Jolt configuration during ISO-1. Historical generated 3D assets/review tools stay intact.
- Logical cells and saved IDs stay Vector2i. FarmGridState remains a pure Dictionary-backed domain object. Only the view converts isometric coordinates, using the TileMapLayer APIs; GridMath retains logical footprint operations. Legacy NPC location data/converters must be adapted without importing Nodes into domain logic.
- Screen-relative input is normalized before its y component is multiplied by 0.5. Comparing speed after undoing this visual compression must show no diagonal advantage. Movement speed/zoom/reach configuration belongs in data, not new gameplay literals in scripts.
- Design size: 1152×648, `canvas_items`, preserved aspect ratio and responsive anchors/containers. Retain existing eight collision names/numbers under 2D physics.
- Consequence: ISO-0 documents the target; ISO-1 must convert the active scenes and affected view APIs/tests before any runtime completion claim. Preserve current farming, merchants, weather, saves and modal behavior. The previously proposed/approved allow list covers documentation only; source changes need their explicit ISO-1 allow list.

### D34 — Mockup UI target, fonts and contextual shortcuts (2026-11-02) — Status: LOCKED as migration specification; implementation staged
- The owner supplied all sixteen reference PNGs in `docs/ui_reference/`, with numbered Vietnamese hyphenated filenames. Keep these exact names; use the images for visual comparison only, never as runtime game textures. Actual dimensions and completeness are recorded in PROGRESS.
- Adopt the prompt's ink `#3A2412`, wood `#BC8340`, paper `#F5E3B0`, green `#5FB230`, yellow `#F7BC32`, red `#D6453A`, sky `#6FB7F0` and coin `#FFD25A`. ISO-2 will introduce the single `ui/theme/the_life_theme.tres`, component scenes/scripts and `ui/ui_gallery.tscn`. This approves the new top-level `ui/` directory; it does not authorize source files in this documentation task.
- Font selection: Baloo 2 ExtraBold headings, Nunito SemiBold body, Noto Serif Italic secondary quotations/tips, Open Sans fallback. These are selected font families, not imported/verified assets yet. ISO-2 must verify licenses, include notices in CREDITS and visually check Vietnamese before shipping them. Use StyleBoxFlat/code placeholders while final frames/icons/sprites are absent; logic must not depend on artwork.
- ISO-1 preserves the current InputMap. The later UI migration moves B to inventory while retaining I/Tab and hotbar key 9 for compatibility; the mockup displays eight tool slots. B must be removed from the old build binding before it is assigned to inventory. Keep the `open_build` action ID; its replacement binding remains unassigned until a building task defines it.
- J keeps the existing journal entry; K/M are calendar/map targets; Q/E are modal tab navigation only, leaving E interaction and Q rotation in their gameplay contexts. F/Z/T are reserved quick-store/sort/pin targets, registered only when the respective behavior is implemented. Do not add dead shortcuts/buttons or invent unavailable system data.
- This supersedes D22/D24/D32 only where the upcoming mockup UI intentionally replaces their presentation. Retain real GUI event routing, one-modal ownership, keyboard focus, localized labels and regression coverage. D10 remains in force: no stamina domain exists, so hide the stamina HUD until a separate stamina milestone is approved.

### D35 — Calendar and later gameplay data changes (2026-11-02) — Status: LOCKED as target; not applied during ISO-0/ISO-1
- The approved proposal follows prompt §4: seven-day weeks beginning Monday (day 1), 28 days per season, spring/year 1, waking at 06:00. Keep the existing overnight cutoff and time rate unless their own task changes them.
- Later ISO-6 targets two consecutive unwatered days before withering, rain watering, carrot 3 days, tomato 5 days with repeat harvest, turnip 4 days and corn 7 days with house-level-2 unlock. These require state/data/schema tests, not a visual migration shortcut. The precise tomato regrow interval, house-upgrade dependency and fertilizer behavior remain to be specified in that task; do not invent values.
- Later sample prices: carrot seed 20, tomato seed 35, turnip seed 25, fertilizer 15; carrot sale 35, turnip sale 45. Store prices in the project's item/economy Resources, growth rules in crop data; keep coins/quantities int. Values not specified remain existing values unless deliberately changed later.
- Existing crop yield 2 (D27), stable IDs, atomic transactions and full-inventory safety remain unchanged. The 8×5 inventory is a later ISO-5 capacity/compatibility change; ISO-1 must not silently resize the current inventory or rewrite saves.
- Existing menu/profile, NPC/dialogue, shop and weather systems remain playable. Prompt §6 defers their new mockup screens/content; it does not remove already working logic. ISO-0 adds no state, public runtime API, signal or save field.

### D36 — ISO-1 implementation and v4 coordinate compatibility (2026-11-02) — Status: LOCKED by approved ISO-1 scope; human playtest pending
- The owner approved the source allow list with “oke tiếp tục”, then explicitly added `scripts/view/pause_menu.gd` when its old Player path caused a regression. Other source additions/changes stay inside that list. No commit/push or archive deletion was authorized or performed.
- Active player/world/farm/NPC/scenery/weather nodes are 2D. Main is CanvasLayer 1 to retain existing direct UI paths; GrayBoxWorld wraps WorldCanvas 0 with follow_viewport_enabled. This intentionally adds the documented WorldCanvas path prefix. Objects and nested WorldArt2D use grounded y-sort; the player's child Camera2D is the only active camera. Existing UI modal/mouse routing remains in use.
- The actual pre-migration v4 format stores player.position.x/y/z, contrary to the older architecture sketch. Keep that wire schema and save version: convert the current view position to a logical cell, serialize its legacy XZ cell center, and restore through TileMapLayer. Old subcell offsets snap to the cell center; invalid numeric fields use data-owned defaults and out-of-bounds cells clamp. No pixel position or view node is saved.
- Retain GridMath's pure legacy converters and the existing WorldLocations Vector3 Resources/NpcSchedule. They are logical-data/wire adapters, not active 3D nodes or a second isometric projection. All canvas/grid conversion uses IsometricGrid/TileMapLayer. No domain file, schema, crop/price/yield rule, inventory capacity or state-owning service was refactored.
- Map/reach/zoom/colors/rain parameters live in IsometricWorldConfig; player movement speeds are in player_2d_config.tres. New code-generated TileSet/sprite/drawing placeholders replace active 3D generated art. Existing 3D assets, shaders, material/build/review helpers and their archive audits remain intact. This supersedes active 3D presentation requirements of D25/D26/D29–D31, preserving their gameplay/data constraints.
- Deliberately migrate old mesh/light/camera assertions to equivalent 2D sprite/tint/canvas/collision assertions. Preserve all domain, economy, save/golden, NPC and physical mouse/modal tests. A new seven-test regression script covers 2D tree/types, negative picking under transforms/zoom/pan, fixed UI, swept collision, legacy/corrupt position handling, movement normalization and config validation.
- The test runner now runs 16 domain/2D scripts headless and all 53 GUT scripts on the configured renderer, then main headless. Existing frame_post_draw tests still run with a renderer; no test was bypassed or weakened. The bounded helper hides windows, isolates user data and reliably propagates nonzero engine exits (confirmed with an intentionally missing test-script path).
- UI remains the C4 layout/Open Sans in ISO-1. The new wooden Theme, imported fonts, 8-slot visible toolbar, inventory 8×5, end-of-day UI and balance changes remain ISO-2–ISO-7. No human Gate A/B or editor playtest is claimed complete by automation.

### D37 — ISO-2 shared UI foundation (2026-11-03) — Status: LOCKED by approved ISO-2 plan; human editor acceptance pending
- The owner explicitly approved the plan/ALLOW_LIST with “Duyệt ISO-2, bắt đầu triển khai”. `ui/` was already approved by D34. Scope includes only the shared Theme, fonts, component/gallery scenes, specified view consumers, GUI theme configuration, related tests/localization and documentation. No new bus event, autoload, InputMap action, domain state or save field is introduced.
- `ui/theme/the_life_theme.tres` is now the single active Theme. UiLayout/root Controls/world labels use the same resource; native Control type variations supply palette/font/style states. The old scene Theme is retained as a historical compatibility asset. This supersedes runtime Theme duplication in D22/D32 while preserving tested C4 geometry, mouse routing and modal ownership.
- Import unchanged Google Fonts binaries with local SIL OFL 1.1 notices: Baloo 2 variable at weight 800 for headings, Nunito at 600 for body, Noto Serif Italic at 400 for secondary text. Keep Open Sans fallback. Tests verify primary-font Vietnamese glyphs as well as the fallback chain; renderer captures show the accented sample. Credits record authors, licenses and sources.
- Offline LifeThemeFactory/build_ui_theme generates the committed Theme, including exact D34 tokens, 3 px ink borders, downward shadows, four native button states, selected/locked slots and 28 px reusable wood-frame margins. Existing game panels use compact shared styles to retain their footprints. Runtime components must not mutate shared StyleBoxes.
- Seventeen requested reusable scenes plus one icon helper use native Controls and localized captions. Twenty-four missing final icon PNGs use 32 px circle/initial placeholders; final nine-slice/frame textures are absent. These are intentional asset placeholders under the owner's prompt, not gameplay feature substitutes. Gallery values are clearly labelled examples. Current key hints read existing bindings; contextual tabs/rebinding and actual HUD reconstruction remain later milestones.
- ISO-2 automation includes real mouse press/release, locked-slot rejection, toggle/slider/tab signals, read-only inventory comparison, integer coin localization, shared resource ownership and three-size vi/en gallery overflow/captures. Full runner passes; pre-existing inventory/pause GUT orphan Labels remain documented. Human F6/F5 playtest and commit remain pending; ROADMAP stays in review.

### D38 — ISO-3 modular mockup HUD (2026-11-03) — Status: LOCKED by approved ISO-3 plan; human editor acceptance pending
- The owner requested commit/continuation, small UI classes and fidelity to the supplied images, then explicitly approved “Duyệt ISO-3, bắt đầu triển khai”. ISO-2 was committed as bf8ed55; the owner's master-plan blank line remains outside our changes. This milestone covers HUD references 03/04, not all later mockup screens.
- Split active HUD into dedicated root, presenter, region layout, frame/parts, clock/arc, pinned quest, toolbar/slot, shortcut and toast stack/card classes under ui/hud. Each new script is below 250 lines. Main only adds wiring; existing public Main paths, adapter methods/signals, modal owner and gameplay services remain compatible. Old Label readouts and legacy hotbar child paths are retained hidden instead of renamed/deleted.
- Match reference regions with anchors/containers: upper-left pinned paper, upper-right wooden clock/weather/wallet, bottom-center eight slots/caption, bottom-left round shortcuts and max-two result toasts. Theme owns all styles; original code decoration and existing SVG/placeholder icons remain replaceable. Mockup PNGs are never runtime assets. World remains ISO-1 placeholder art; clock/weather values and night/rain simulation stay existing state.
- Mixed toolbar mapping is explicit: 1 hoe, 2 water, 3 harvest, 4–8 a five-stack window over real inventory. Selecting any inventory index from the existing panel moves the window; key 9 still selects legacy inventory index 8. Inventory capacity, quantities, IDs and save v4 are unchanged. Tool requests still call ToolActionController and item selection still emits slot_selected; no item operation is inferred from artwork.
- Implement approved B inventory migration while retaining I and documented Tab: remove B from open_build but preserve its unbound action ID. The actual project defaults lacked the previously documented Tab alias; add that alias now to satisfy the approved B/I/Tab behavior. J/H/Escape keep working screens reachable. Unsupported K/M/Q/E actions and map/calendar/stamina/event cards stay absent. Weekday is derived from existing day_index (day 1 Monday); season length/year/day come from existing clock/data, with no balance/calendar migration.
- Existing tutorial only stores completion booleans. Display real completed/7 and three relevant existing steps rather than inventing mockup 4/4 progress or rewards. All game feedback/quest completion/save messages feed the same max-two, 3-second view-only toast stack. Discarded cards are freed safely, with timer callbacks deferred; no orphan nodes are intentionally retained.
- Crop detail stays readable in the center of available map space, separate from quest/toolbar; while it is visible, suppress the underlying interaction prompt to avoid overlap. Modal backdrop/panels retain z80/81, result toasts z82. Physical clicks and B/I/Tab/number keys, modal/farming/save regressions, real-data assertions and vi/en three-size day/night/rain captures validate the change. Human acceptance/commit remain separate from automation.

### D39 — ISO-4 day-end report, journal and safe rollover (2026-11-03) — Status: LOCKED by approved ISO-4 plan; human editor acceptance pending
- Owner explicitly approved “Duyệt, commit ISO-3 và triển khai ISO-4”. Commit 8706dfb contains delivered ISO-3; the owner's master-plan blank line is preserved outside our work. This scope includes save v5 and the PROJECT_RULES migration-status notice only, without changing locked laws.
- Main owns LifeDayEndFlow; pure DayLedgerState/DayEndState implement serialize/deserialize immediately. Views are small independent sheet/ledger row/list/warning/tomorrow/weather/formatting/presenter classes. Theme remains shared; reference 13 is never loaded as an asset. No new autoload, Events-bus entry, InputMap action, price/growth/capacity change or future system is introduced.
- Actual signed wallet deltas form the journal. Starting/load balance is excluded; known refund/minh_rollback reverse expenses rather than count as income. Successful shop/bin metadata annotates already-recorded deltas without double counting; quantities stay generic if a refunded/partial operation cannot prove them. Native merchant/generic cash changes remain reported by localized reason. Integrity bounds mark incomplete history rather than lying about a truncated journal.
- Reachable bed interaction emits local bed_requested; a connected flow opens manual review, standalone world retains try_sleep. Clock cutoff emits local day_end_requested and falls back to old immediate rollover if no consumer claims it. Legal bedtime/cutoff holds block raw minute advancement/try_sleep/set_time. Manual Stay/Escape releases review without simulation; forced cutoff cannot cancel or switch modal.
- Confirm latches ADVANCING throughout one existing sleep_to_morning -> Main.day_started -> DaySimulator callback path. Existing sleep signals wrap this immediate application transition; the low-level accelerated try_sleep API is retained. Main suppresses writes while sleeping/advancing. After simulation and sleep completion, the ledger starts its new day, guard becomes idle, panel closes and autosave captures all completed state (including tutorial sleep completion). Direct/manual/forced three-night results are tested equivalent for farm/weather/clock/wallet/inventory.
- Save v5 adds day_ledger/day_end. v1–v4 migration preserves earlier payloads and marks prior transaction history unknown; it is not inferred from coins. Review can resume with its clock hold. Reconciliation prevents re-entrant/new-day replay while deliberately loading an older snapshot still restores its older timeline. Existing golden files stay unchanged; a v5 review golden is added.
- A reproduced newest-save bug truncated fractional UTC timestamps and selected old slot-1 review over slot-0 morning when times shared a second. Preserve fractional precision and prefer the later saved clock day on exact ties. Test both fractional and exact timestamps and forced review Continue after completion; atomic writes/backups are retained.
- Use actual unwatered/withered plot flags and forecast snapshots, with forced warning text that does not offer an unavailable return action. No invented wither countdown, XP/stamina/event card or numerical reward. Captions refresh both hidden/visible in vi/en. Renderer comparisons cover manual/incomplete/forced-rain states at three sizes; human editor acceptance and ISO-4 commit remain pending.

### D40 — ISO-5 modular inventory, contextual tabs and save v6 (2026-11-03) — Status: LOCKED by approved plan; human acceptance pending
- Owner approved “Duyệt, commit ISO-4 và triển khai ISO-5”. Delivered ISO-4 committed as c8b94f9; owner master-plan blank line remains untouched. No ISO-5 commit/push is implied.
- Explicit 8×5/40 requirement wins over the reference's pictured row count. InventoryConfig owns capacity/dimensions; explicit small-capacity constructor tests remain. Item resources add category/description metadata only, without prices/stack/id/art changes.
- Small native component scene/script pairs form the reference-06 wood/paper layout. InventoryPanel/Main paths and existing tool wiring remain. Filters retain original indices; details show real unit sell prices and supported descriptions. Current tool/material filters are empty; no fake tools, eating, stamina, quality or market bonus is added. Existing icon art uses trimmed AtlasTexture views.
- Five tabs visible; Bag and existing Quest journal enabled. Q/E cycles these two and consumes world E/Q. F explicitly selects the highlighted stack through existing toolbar APIs; it does not transfer storage or assign a fixed slot. Z sorts Bag only. Character/Calendar/Map remain disabled; B/I/Tab/J/Escape retained. Day-end sheet wins modal arbitration.
- Stateless InventoryActions delegates stable category/id sort and exact-stack discard to InventoryState. Revision/id/count/index are rechecked, quantity is positive integer and explicit confirmation required. Sort preserves individual stacks and returns selection mapping; removed earlier stacks remap the surviving toolbar item without another action. UI refresh is deferred so emitting controls are not freed mid-signal. Money/journal stay unchanged.
- Save v6 deep-copy migration floors old capacity to configured 40, keeps larger legacy capacity, and preserves slot order/IDs/quantities plus all prior fields. Deserialize retains valid oversized stacks/contents beyond declared capacity, rejects malformed shapes/unsafe aggregate with warnings, and drops invalid entries. v1–v5 goldens remain unchanged; v6 fixture added. New malformed-data tests intentionally exercise warnings.
- Native mouse/key, stable selection/full bag/old save/stale discard/economy/modal tests and vi/en three-size captures verify automation. Human editor acceptance remains separate; existing 3D icon artwork remains replaceable, not final 2D item artwork.

### D41 — ISO-6a daily crop care, day-boundary rain and save v7 (2026-11-03) — Status: LOCKED by approved ISO-6a plan; human editor acceptance pending
- Owner approved “Duyệt, commit ISO-5 và triển khai ISO-6a”. Commit 67c63a2 records ISO-5's exact 95-file manifest after fresh DataValidator PASS, excluding the owner's master-plan edit. No ISO-6a commit/push is authorized by that preceding-milestone commit request.
- Separate fully specified care from ISO-6b balance/regrow/fertilizer/house-unlock questions. Existing growth, yield 2, seasons, prices, IDs, art, InputMap and scenes stay unchanged. Do not bypass the existing longer-growth price validator or choose unspecified values just to ship the full ISO-6 label.
- CropData owns max_consecutive_dry_days, set to 2 in shipped Resources. FarmGridState owns consecutive_dry_days. First missed eligible care pauses growth and warns; manual/rain water resets the streak. The threshold marks terminal withering once. Ripe plants left in soil still require care; water-free crops grow without a dry streak. Already-withered crops cannot grow, receive water, revive or yield, even if their saved growth is mature. Clear/replant starts fresh.
- Main's existing day_started callback was applying the new day's rain before finishing yesterday. Resolve the finished day's care/current rain before the one DaySimulator call, then apply new-season withering, advance weather and water surviving morning plants. Clock signals, forced/manual review guard and safe saves remain the single existing application path. Test dry→rain/rain→dry and season boundaries, with exactly-once confirmation.
- Save v7 deep-copy migration initializes absent old counters to 0 because historic missed watering is unknown; preserve every prior field. v1–v6 fixtures stay unchanged; new v7 fixture covers threatened and terminal ripe crops. Restore validates new counters and malformed plot rows safely; malformed whole arrays retain previous farm. Integer-coordinate bounds protect Vector2i decoding, not gameplay expansion.
- CropInspector reuses its note Label and existing requests, shows the real remaining dry days in vi/en, clears the warning after water and refreshes locale changes. Terminal text describes withering without falsely attributing drought to the season; the ineffective needs-water readout is cleared. Summary's generic unwatered count/tree stays unchanged. No UI-owned state, new autoload, bus signal, InputMap action, scene or artwork. Automated native input/layout/save/weather/economy checks and human editor acceptance are reported separately.

### D48 — ISO-11 read-only Quest book (2026-11-03) — Status: LOCKED by approved plan; automated acceptance/render review delivered, human pending
- Owner approved commit ISO-10 and implement ISO-11. Commit b44c5d5 records51 files after fresh validator PASS; owner master-plan edit excluded. ISO-11 implementation is committed in 962bba9.
- Reference08 composes seven small scene pairs plus controller/presenter/snapshot. Existing NpcJournal root/public dialogue APIs stay; a documented journal-only internal branch shows real onboarding/registered quests/current bag/Resource rewards/NPC friendship. Original nearby NPC dialogue retains all acceptance/delivery/payout/atomic guards.
- Only transient filters/selection and deferred refresh; no domain/save/input-action change. Daily/pin/map/XP/deadlines/ranks unavailable. Native journal GUI pass-through is authorized in NpcSystem/UiCoordinator; modal locks/prior holds/day-end precedence remain. Core/domain/data/old scenes/renderers/art/Theme/v8/goldens/tools stay read-only; human acceptance separate.

### D47 — ISO-10 read-only character/relationships (2026-11-03) — Status: LOCKED by approved plan; automated acceptance/render review delivered, human pending
- Owner approved commit ISO-9 and implement ISO-10. Commit ec3c6d3 records exactly44 ISO-9 files after fresh validator PASS, excluding the owner master-plan edit. No ISO-10 commit/push implied.
- Reference07 uses seven small scene pairs plus flow/presenter/snapshot helpers. Actual saved profile/appearance and existing NPC friendship/caps/portraits only. Skill/XP/level/bonus/birthday/gift systems are unavailable; no invented progress, roles, benefits or remote interactions.
- Supersedes only D40's enabled-tab subset: Bag0/Character1/Quest2 now navigate via the existing Q/E actions and shared header; Calendar3/Map4 remain disabled. No new binding/action/project.godot change. Main creates a read-only character flow; UiCoordinator remains the modal/clock/world owner with day-end precedence and native GUI navigation.
- Five hearts floor the existing point/cap ratio for display only; raw values remain shown. All social/profile/domain/core/data/renderer/old scenes/art/Theme/v8/goldens/tools remain unchanged. Open/locale/scroll/close cannot mutate state or award friendship; human acceptance is separate from tests.

### D46 — ISO-9 presentation-only morning bulletin (2026-11-03) — Status: LOCKED by approved plan; automated acceptance/render review delivered, human pending
- Owner approved “Duyệt, commit ISO-8b và triển khai ISO-9”. Commit57008ab records the exact50-file ISO-8b handoff after fresh validator PASS, excluding owner's master-plan edit. No ISO-9 commit/push implied.
- Reference05 newspaper composition is six small scene pairs plus flow/presenter/snapshot helpers. Read actual saved three-day forecast, onboarding/farm status and current ItemData produce sell prices; no invented calendar events, price trends, rewards or extra weather rolls.
- Queue only after real day_started processing; wait until existing day-end advancement/panel/final save/sleep/modal clears. Begin/Escape dismisses only, never simulates/rolls/saves. View-only pending/last-shown guards reset on New Game/load/return-title; no new schema/dismiss flag or automatic bulletin on Continue/tutorial.
- UiCoordinator remains sole modal owner, restores prior hold, gives day-end precedence and native GUI navigation. Main wiring changes only; existing DayEndFlow/core/domain/data/saves/goldens/scenes/art/Theme/tools remain. Update prior post-sleep tests for presentation while preserving exactly-once/domain/save assertions.

### D45 — ISO-8b creation UI and shared player hairstyle rendering (2026-11-03) — Status: LOCKED by approved plan; automated acceptance/render review delivered, human pending
- Owner approved “Duyệt, commit ISO-8a và triển khai ISO-8b”. Commit a683feb records exactly42 delivered ISO-8a files after fresh DataValidator PASS, excluding owner's master-plan edit. No ISO-8b commit/push implied.
- Open only reference02: native two-panel creation form, six data-backed choices in each category, actual2D preview and existing profile/start/save owners. Replace internal OptionButton/AppearanceGrid controls with typed native choice rows; public form/StartMenu APIs and actual _name_box VBox stay.
- Existing2D avatar ignored hairstyle selection. Shared view-only AvatarHair2D renders the six catalogue IDs in preview and active player; NPCs without player customization retain legacy arc. Body/actions/movement/collision/data/saves unchanged. Arrow controls cycle hair rather than claim nonexistent rotation.
- Drafts do not touch world state; one UI submission latch forwards original normalized appearance before unchanged two-string Main callback. Native input/locale/Back retain drafts. Shared Theme/title art retained; no new bitmap/3D/pet/backend.
- Increase only the full graphics test call's bound120→180 seconds because the preceding full run took111.822s; preserve every test/error/exit gate and helper defaults. Automated/native/save/preview parity and vi-en three-size evidence remain separate from human acceptance.

### D44 — ISO-8a modular main menu with existing profile/save owners (2026-11-03) — Status: LOCKED by approved plan; automated acceptance/render review delivered, human pending
- Owner approved “Duyệt, commit ISO-7 và triển khai ISO-8a”. Commit4ccc8de records ISO-7's exact43-file manifest after fresh validator PASS, excluding owner master-plan edit. No ISO-8a commit/push is implied.
- Open only reference01 from prompt section6's deferred screens: five small scene/script pairs plus presenter/helpers, actual latest-save card, existing illustration/Theme and unchanged Main callback/state owners. Reference02 redesign and all other deferred systems/screens remain outside scope.
- Explicitly migrate script-created StartMenu/MarginContainer/Column internals to typed component fields; preserve Main/StartMenu, public configure/appearance APIs, _name_box/_settings_box references and form selector names. Update old tests' path lookups, retain behavior assertions.
- Settings reuses ISO-7's components for supported preference drafts; form retains original data-backed choices and normalization. Only read actual latest payload fields; omit unavailable playtime/house/portrait/version, no new save format or gameplay values.
- PROJECT_RULES migration notice is stale about ISO-7 planned; correct status only under this decision, leaving all locked rules unchanged. New ISO-8a roadmap row remains in progress/human acceptance pending until real review. No human gate passes from automation alone.

### D43 — ISO-7 modular pause/settings/save presentation (2026-11-03) — Status: LOCKED by approved plan; automated acceptance delivered, human pending
- Owner approved “Duyệt, commit ISO-6b1 và triển khai ISO-7”. Commit 4b3ca62 records the exact 73-file ISO-6b1 delivery after fresh DataValidator PASS, excluding the owner's master-plan edit. No ISO-7 commit/push is implied.
- Match reference14's two wood/paper cards, red pause ribbon, left actions and right four-tab settings with six small scene/script components and separate presenter/helpers. Reuse Theme, native Controls, UiCoordinator and existing Main/PauseMenu paths. No existing .tscn, InputMap, autoload, Events or gameplay/domain/data changes.
- Only supported music/effects volume and vi/en have transient drafts; Apply delegates existing Settings setters and Default edits the draft. Close/switch discards unapplied drafts. Music volume storage is not a music playback feature. Existing sound effects continue reading their volume. Other pictured preferences are explicitly unavailable, not fake active controls; controls tab reads actual InputMap bindings.
- Keep secondary manual Load despite its absence from the reference. Main's private save/load/menu callbacks return actual bool outcomes; no success after blocked/failed save and no return to title if its required save fails. Save schema remains8, atomic writes/backups and v1-v8 goldens unchanged. Preserve NPC/sleep/rollover safe points and day-end review precedence. Settings remain separate in settings.cfg.
- Allow native GUI Tab/Space/arrows before overlapping world-shortcut filtering inside pause; retain Escape/modal switching and lock. Verify both locales/three sizes/physical input/failed writes/draft cancellation/persistence and full regression suite; human editor acceptance remains separate.

### D42 — ISO-6b1 crop data, repeat harvest and v8 compatibility (2026-11-03) — Status: LOCKED by approved ISO-6b1 plan; human acceptance pending
- Owner explicitly approved “Duyệt, commit ISO-6a và triển khai ISO-6b1”, including the exact table, 2-day repeat, ceiling 80 and v8 old-plant preservation. Commit 7f7a429 records ISO-6a's exact 41 files after fresh DataValidator PASS, excluding the owner's master-plan edit; no ISO-6b1 commit/push is implied.
- New-sowing first growth: carrot3, tomato5, turnip4, corn7. Tomato regrow2 follows the historical starter-table interval, now explicitly approved with retained yield2. Prices (seed buy / produce unit sale): carrot20/35, tomato35/72, turnip25/45, corn35/100. Tomato sale72 and corn35/100 are explicit minimal additions needed to retain the existing monotonic price guard against cabbage/pumpkin; other crops/prices, seed resale, stack/yield/seasons/care/IDs/art stay unchanged. NPC quotes remain isolated and unchanged.
- Add a current dataset Resource ceiling80 for initial net / first-growth day and repeating gross / regrow day. This explicitly supersedes the historical starter-example crop ceiling18, not other economy/recipe limits. Use exact integer cross multiplication and safe input/product bounds; preserve all existing price guards and add negative/cap-breaking-data tests. Ideal 28-watered-day tomato return1693 is acknowledged as provisional balance; human playtest remains required. No saturation/quality/market system is invented.
- FarmGridState is still sole plot owner. Small stateless CropCycleRules/FarmSaveCodec extract cycle and wire validation responsibilities to keep it below250 lines. Each plant freezes growth_target; regrowing marks repeat phase. Ready tomato harvest retains the plant/care, resets elapsed growth and target to2 before signals, and yields exactly2 once. It does not water, reset drought or consume another seed. Full inventory blocks before mutation; terminal withered crops cannot regrow/yield. Single-harvest crops retain removal behavior. One existing DaySimulator path applies all care/rain/season rules.
- v8 deep-copy migration adds old first targets from an explicit historical Resource map and regrowing=false; original growth numbers/fields are not rewritten. v1–v7 goldens stay unchanged. Old mature/immature crops keep ripeness/remaining days even when the new sowing duration increases. New planting uses the approved current duration; a real tomato harvest starts a current2-day repeat. Validate targets against legitimate current/historical first durations or exact repeat duration; strict repeat booleans/defaults. All prior slots/quantities/wallet/clock/weather/social/profile/ledger/guard and atomic backup logic remain.
- Views query owner targets for visuals/countdown; the existing inspector note describes actual new-fruit growth, with dry warning precedence. Main reuses FarmView.configure after load to refresh all cells. Native physical seed/harvest/full-bag/no-duplicate tests, multi-cell restore, legacy/corrupt save checks and three-size vi/en captures cover behavior. No new scene, Theme, input, autoload, bus signal or artwork.
- Existing two-day-turnip checks are updated to approved durations while retaining care/stage/harvest assertions; the 112-day economy test now checks a second tomato pick and clears its retained withered plant before next-season sowing. JSON round-trip assertions normalize numeric wire types on both sides while preserving every field/value; native domain target ints are tested separately. No test is weakened or skipped to force a pass.
- Fertilizer and house-level corn gating remain explicitly unfinished; corn's existing availability remains in 6b1 until a specified usable upgrade system exists. This slice does not complete all ISO-6 or any human gate.

### D49 — Asset/UI/crop expansion baseline (2026-11-03) — Status: LOCKED for planning; implementation pending approval
- The next ISO sequence uses the supplied 128×64 ground atlas with Camera2D zoom0.5. The active presentation remains 2D isometric, while logical cells stay `Vector2i` and rendering continues to use `TileMapLayer` conversion APIs.
- Use Baloo 2 for headings and Nunito for body text, with the existing Open Sans as fallback; verify Vietnamese diacritics before claiming the font work complete. UI art remains replaceable placeholder content until the supplied source PNGs are integrated.
- Confirmed calendar baseline is a seven-day week beginning Monday, 28 days per season, and waking at06:00. Confirmed bindings are B/J/K/M/H/Escape, 1–8, E, Q/E, F, Z and T; any missing actions must be added only in the approved InputMap step and documented.
- Crop balance is data-owned by CropData: four evenly divided growth stages use the supplied crop table, rainy days count as watered, missed care withers at the current stage, watering clears wither, and two consecutive withered days kill the crop. Perennials occupy one logical cell, return to stage3 after harvest, and use their supplied regrow days. House-level unlock claims remain deferred until a real house system is specified.
- The new visual priority is harvest icons, player, house, NPCs (Linh, Minh, Cô Hoa), then shop. No UI may invent unavailable runtime values, and no asset import may delete the existing placeholders.

### D50 — ISO-12 imported ground/decor/object presentation (2026-11-03) — Status: LOCKED by owner approval; implementation in progress
- Owner approved the ISO-12 ALLOW_LIST after committing the planning documents. Restore the accidentally deleted `ui/ui_gallery.gd` and its UID from the last commit so the existing full test harness remains valid.
- Import the supplied `tiles`, `decor` and `objects` assets into the root `assets/` directories without deleting the retained source bundle. Use `ground_tileset_128x64.tres`, Camera2D zoom0.5 and the existing TileMapLayer conversion path.
- Remove the generated placeholder ground texture from active runtime. Ground variants are selected by a stable coordinate hash; the imported atlas has no authored grid lines, and Highlight remains the only hover-cell visualization.
- Do not add gameplay state, save fields, crop balance, object interactions or new collision behavior in ISO-12. Large-rock collision and other decor gameplay remain deferred to ISO-14.

### D51 — ISO-13 shared theme/font and HUD baseline (2026-11-03) — Status: LOCKED by owner approval
- Keep the existing shared `the_life_theme.tres` and modular native HUD as the presentation baseline. Baloo 2 is used for headings, Nunito for body text, and Open Sans remains the fallback; Vietnamese diacritics must be verified before acceptance.
- Why: ISO-2/ISO-3 already provide the requested replaceable Theme and real-state HUD, so rebuilding them would add risk without changing player-facing behavior.
- Consequence: ISO-13 is a validation/documentation completion of the existing implementation. No stamina, event, save, domain, InputMap or fabricated HUD values are added.
- Changeable until: before the next approved visual milestone.

### D52 — ISO-14 deterministic passive scenery (2026-11-03) — Status: LOCKED by owner approval
- Use coordinate hashing to place imported rocks and grass clumps outside the farm and interaction-anchor exclusion cells. Sprite roots stay at `TileMapLayer`-derived cell positions, and only large rocks use the existing `world_static` collision layer.
- Why: scenery must be stable across runs without becoming domain/save state, while large rocks need the approved passive boundary for future cleanup gameplay.
- Consequence: small/medium rocks and grass clumps remain non-colliding visuals; rock cleanup, harvesting and interaction are deferred.
- Changeable until: before ISO-14 gameplay interaction is separately approved.

### D53 — ISO-15 existing-domain crop visuals (2026-11-03) — Status: LOCKED by owner approval
- Import all 16 supplied crop visual sets and read their stages, wilted variants, canvas and pivots from `crops_manifest.json`. Connect only crop IDs already registered by the runtime when a matching asset basename exists.
- Why: the supplied art is complete, but the current domain has only nine crops and no approved balance/item table for the seven new crops. Visual integration can proceed without fabricating gameplay values.
- Consequence: unmatched existing crops retain explicit placeholders; new crop art is not plantable, purchasable or saved until a later approved data task.
- Changeable until: before full 16-crop gameplay data is approved.

### D54 — ISO-16 supported presentation screens (2026-11-03) — Status: LOCKED by owner approval
- Keep day-end, inventory and pause/settings as read-only/native presentation consumers of existing owners: DayEndFlow/SaveService, InventoryService/DataRegistry and Settings/UiCoordinator respectively.
- Why: these screens already satisfy the supported mockup subset; changing domain ownership or inventing unavailable calendar/events/house/dialogue state would violate the milestone boundary.
- Consequence: ISO-16 is accepted through focused and full automated verification without runtime rewrites. Human editor/render acceptance remains separate.
- Changeable until: before ISO-17 shop/remaining presentation is approved.

### D55 — ISO-17 existing data-driven planting-item shop (2026-11-03) — Status: LOCKED by owner approval
- Accept the existing `SeedShopPanel` as the ISO-17 shop surface: it reads registered planting items through `DataRegistry`, uses actual `ItemData` pricing/icons and preserves `EconomyService`/`InventoryService` atomic ownership.
- Why: the current runtime already provides truthful season filtering, reach/prompt, affordability, capacity and purchase behavior; adding unregistered crop/item data would invent gameplay values prohibited by the milestone scope.
- Consequence: ISO-17 is accepted through focused and full automated verification without runtime rewrites. Additional house/NPC/dialogue/calendar/event screens remain deferred until their domain systems and data exist; human editor/render acceptance remains separate.
- Changeable until: before a future approved data task adds new planting-item categories or remaining screen domains.

### D56 — ISO-18 supplied crop gameplay data and care rules (2026-11-03) — Status: LOCKED by owner approval
- Register every crop present in the supplied manifest using the owner's balance table; planting item type, prices, stages, perennial behavior and regrow days remain Resource data rather than script constants.
- Missed watering at a stage transition withers the crop without advancing it; watering or rain restores it; a second consecutive withered day removes the crop. A shovel clears a withered crop while preserving its tilled plot.
- Why: the playtest identified missing supplied-crop integration and no dedicated cleanup path. This preserves the DATA → DOMAIN → VIEW boundary and keeps legacy saves readable.
- Changeable until: before a separately approved balance or crop-care redesign.

### D57 — Phase 6.1 machine domain boundary and temporary processed-item IDs (2026-11-04) — Status: LOCKED by owner approval
- Implement `MachineData`, `RecipeData` and serializable `MachineState` only. Jobs advance by completed game days, consume inputs atomically, buffer one completed output, and become `blocked` rather than losing output when the buffer is unavailable.
- Keep supplied machine art as manifest-backed asset paths for the later VIEW milestone. Do not add machine scenes, UI, placement, effects, audio, shop flow or final processed-item `ItemData` until those scopes are approved.
- Use `temp_*` output IDs in recipe resources and machine buffers until the owner confirms the final Vietnamese/English item names and icons.
- Why: this delivers the production domain contract without inventing player-facing item content or coupling state to nodes.
- Consequence: recipes can be tested and saved now, but processed outputs are not yet valid inventory items and cannot be shown in UI.
- Changeable until: before the processed-item content/data milestone.

### D58 — Machine Shop domain-only ownership (2026-11-04) — Status: LOCKED by owner approval
- Sell stove, mill, press, barrel, oven, dryer and roaster through a future separate shop UI, using the approved temporary prices and house unlock levels in `MachineData`. Each confirmed purchase removes one price through `WalletState` and adds one count to a separate unlimited `MachineInventory`.
- Save machine ownership under `machine_inventory` in the existing payload; old saves default to empty ownership and save version remains unchanged.
- Why: machine ownership must exist before Phase 6.3 placement, while UI and placement are separate milestones.
- Consequence: purchased machines cannot yet be placed or displayed in a shop; no resale/refund exists.
- Changeable until: before Machine Shop UI or placement work.

### D59 — Phase 6.2 machine placement footprint and rotation (2026-11-04) — Status: LOCKED by owner approval
- All seven supplied machines occupy one logical cell. Placement rejects locked parcel cells and any occupied footprint, consumes one machine from `MachineInventory`, and removal returns one machine.
- Save `rotation` as one of `0`, `90`, `180` or `270` degrees. Current machine sprites remain in their supplied single direction; future directional art may change VIEW only.
- Why: establish safe logical placement before UI/build mode, while preserving the asset limitation and DATA → DOMAIN → VIEW boundary.
- Consequence: placement has no scene, preview, directional rendering or effect yet.
- Changeable until: before Phase 6.3 build mode.

### D60 — Phase 6.3 logical build commands (2026-11-04) — Status: LOCKED by owner approval
- Build mode exposes domain commands for place, rotate, move and remove through `MachineBuildService`; all seven machines remain `1x1`, rotation remains saved metadata, and UI/ghost presentation is deferred.
- A placement consumes one machine, a successful removal returns one machine to `MachineInventory`, and move/rotate failures restore the original occupancy and placement.
- Why: deliver the approved build-mode logic without inventing input bindings, scenes, previews, prices or additional machine content.
- Consequence: no visible build mode exists yet; the future UI must call these commands and render their explicit results.
- Changeable until: before Phase 6.3 UI/ghost implementation.

### D61 — Phase 6.4 script-built machine test UI (2026-11-04) — Status: LOCKED by owner approval
- Use the existing `interact` action and a `GrayBoxWorld` marker created in code for the first machine-shop test. Build the shop and operation controls as script-created UI; do not edit `.tscn` or add an input binding.
- `MachineOperationService` owns serialized machine jobs. The view delegates purchase, test placement, recipe start, day progression and output collection to existing data/domain services.
- Why: provide a playable test path without inventing a scene contract or replacing the existing seed-shop interaction.
- Consequence: the first UI uses a temporary test-placement button and supplied machine data; dedicated machine scenes, ghost previews and final product icons remain deferred.
- Changeable until: before dedicated machine presentation work.

### D72 — 2D Isometric Camera Pan/Zoom & Cozy Visual Polish (2026-11-05) — Status: LOCKED by owner approval
- Camera zoom levels in `data/isometric_world_config.tres` expand to `PackedFloat32Array(0.35, 0.5, 0.75, 1.0, 1.25)` with default `zoom_index = 1` (`0.5`), allowing wide map overview (`0.35`) and close-up (`1.25`).
- Mouse Wheel over the map zooms `CameraRig`; `HotbarPanel` only consumes Mouse Wheel (`tool_next` / `tool_prev`) when hovering the hotbar or holding `Shift`.
- Right/Middle Mouse drag pans `CameraRig` (`_pan_offset` clamped to `Vector2(-1400, -800)..Vector2(1400, 800)` scaled by zoom) without interfering with Left Mouse tile hover/farming; moving the player or double-right-clicking smoothly resets pan to `Vector2.ZERO`.
- 2D isometric character (`PlaceholderAvatar2D`, `AvatarHair2D`), buildings/trees (`PlaceholderWorld2D`), crops (`FarmView`), working machines (`MachinePresentation`), and wood UI frames (`LifeHudFrame`, `LifePanelWood`) render detailed 2D isometric art and live animations when `not GameClock.paused` while remaining deterministic when paused for snapshot tests; PNG sprite sheets/buildings are generated by `tools/build_isometric_2d_assets.gd` under `assets/buildings/`, `assets/characters/`, and `assets/ui/`.
