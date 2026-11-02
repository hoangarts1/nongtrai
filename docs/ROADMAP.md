# ROADMAP — THE LIFE

Each row is ONE task for the agent. Move to the next row only after acceptance + commit. Status column: `[ ]` todo, `[~]` in progress, `[x]` done (the human ticks it; the agent mirrors it in `docs/PROGRESS.md`).
Hour estimates are the HUMAN's working hours incl. review, testing and fixes — rough guesses, re-measure after 4 weeks.

**Gates**: GATE A after Phase 4 (is the plant→harvest loop fun? play 10–15 min). GATE B after Phase 9 (3–5 strangers play 30 min; ≥ ~60% want to continue). Do not pass a gate on hope.

## Active override — 2D isometric migration (D33–D35, 2026-11-02)

This sequence takes precedence over the historical 3D presentation tasks below. Existing implemented domain systems are reused; the unchecked historical boxes are not a reliable inventory of missing code. ISO-0 documented the specification; ISO-1 runtime automation is complete, with human editor acceptance pending. Each code milestone needs an explicit allow list and its own acceptance.

| ID | Task | Acceptance | Status |
|---|---|---|---|
| ISO-0 | Reconcile specification, reference inventory and migration contracts | D33–D35 recorded; all sixteen references accounted for; target/current API distinction and source-scope proposal documented | [~] |
| ISO-1 | Convert active gameplay to 2D isometric placeholders (automated checks delivered; human playtest pending) | 64×32 TileMapLayer picking works at negative cells and zoom; CharacterBody2D/Camera2D movement and collisions work; eight 2D layers; no active gameplay 3D nodes; existing farm/NPC/weather/transaction/save/modal behavior preserved; autoloads/InputMap/GUT/fonts retained; full tests, data gate, parse and main headless pass | [~] |
| ISO-2 | Shared Theme, fonts and reusable UI gallery | Native Control components cover prompt §2.3 states; one theme; licenses/Vietnamese checked; placeholders replaceable; gallery visually compared with reference 15 | [ ] |
| ISO-3 | Basic mockup HUD | Clock/date/coins/tool slots and max-two toasts show real state; unavailable stamina/event data hidden; anchors/containers work at three sizes, vi/en; physical input/modal regression tests pass | [ ] |
| ISO-4 | End-of-day summary and sleep UI | Existing simulation path retained; real income/expense/profit and unwatered-crop warning; one next-day action; save/load and repeated sleep equivalence verified | [ ] |
| ISO-5 | Inventory and common five-tab shell | 8×5 capacity change explicitly tested with old saves; filters/details and supported eat/store/discard requests are validated; Q/E contextual tabs; no fake future screens | [ ] |
| ISO-6 | Farming/data changes from prompt §4 | Resource-owned growth/prices; clarify regrow/unlock/fertilizer gaps first; watering/wither/rain/harvest/full-inventory tests and migration if schema changes | [ ] |
| ISO-7 | Pause/settings/save UI | Mockup 14 connected to existing settings/save APIs; old golden saves and atomic writes retained; modal input, vi/en and layout tests pass | [ ] |

Mockup redesigns 01 main menu, 02 character creation, 05 morning bulletin, 07 character/relationships, 08 quest book, 09 calendar/events, 10 shop, 11 house upgrade and 12 dialogue remain later work after their corresponding domain requirements are ready. Existing implementations are preserved during migration. Night/rain attachment points belong in ISO-1; full 2D visual polish must use existing weather state rather than invent a replacement simulation. No human gate is passed by this plan.

## Phase P — Preparation (no gameplay code)  ~20–40 h

| ID | Task | Acceptance | Status |
|---|---|---|---|
| P-1 | Fill and confirm `docs/DECISIONS.md` (D01–D18, esp. D01, D02, D03, D08, D13) | no `<<FILL>>` left in DECISIONS; boxes ticked | [ ] |
| P-2 | 1-week asset spike (Master Plan 10.9) | record PASS/FAIL; choose 3D or 2D fallback | [ ] |
| P-3 | Install tools, create repo, place these docs, set agent rules | checklist in `START_HERE_VN.txt` complete | [ ] |

## Phase 0 — Foundations  ~15–30 h

| ID | Task | Acceptance | Status |
|---|---|---|---|
| 0.1 | Repo + project config + headless test runs | smoke test PASSES by command line; parse check exits 0; `tools/run_tests.*` works and fails when a test fails | [ ] |
| 0.2 | InputMap + layer names + folder skeleton + autoload stubs + Vietnamese font test | docs match `project.godot`; Label shows `Thung Lũng Sống ẩn ệ ữ ợ ỡ ằ ẫ` correctly | [ ] |
| 0.3 | `GridMath` (pure) + unit tests | negative coords, boundary 0.999 vs 1.0, cell centers, even/odd footprints, 90° rotation | [ ] |
| 0.4 | Gray-box: plane + locked ortho camera (D13) + debug grid + `pick_cell` | click picks the right cell; cell (0,0) in the right place; highlight follows mouse | [ ] |
| 0.5 | `DetRandom` + golden tests | seed X → sequence Y fixed | [ ] |
| 0.6 | `Log` utility + debug overlay skeleton (`toggle_debug`) | warn/error carry context; overlay toggles | [ ] |

## Phase 1 — Character  ~20–40 h

| ID | Task | Acceptance | Status |
|---|---|---|---|
| 1.1 | Camera-relative movement (no collision yet) | "up" moves toward screen top; diagonal not faster | [ ] |
| 1.2 | Collision with static obstacles | no tunnelling; slides along walls; not stuck in corners | [ ] |
| 1.3 | Smooth camera follow + bounds + 2–3 zoom levels | no jitter; no overshoot at edges; zoom keeps the angle | [ ] |
| 1.4 | Node-based state machine Idle/Move | adding a state does not edit `player.gd` | [ ] |
| 1.5 | `Interactable` + nearest-target detector + prompt | correct prompt; picks correctly among several | [ ] |
| 1.6 | (optional, needs assets) dither/fade for occluders | player always visible behind tall objects | [ ] |

## Phase 2 — Time  ~10–20 h

| ID | Task | Acceptance | Status |
|---|---|---|---|
| 2.1 | `GameClock` + signals + pause + `sleep_to_morning()` | tests: day/season/year roll; pause holds time | [ ] |
| 2.2 | HUD date/time/season (view) | matches the clock; no logic | [ ] |
| 2.3 | Basic debug console: `set_time`, `set_day`, `speed N` | commands work; debug builds only | [ ] |

## Phase 3 — Inventory & data  ~25–45 h

| ID | Task | Acceptance | Status |
|---|---|---|---|
| 3.1 | `ItemData` + `DataRegistry` + `DataValidator` | validator reports bad/duplicate/missing ids, icons, keys | [ ] |
| 3.2 | `InventoryState` + tests | add/remove/stack; full inventory returns correct remainder; negative qty rejected; serialize round-trip | [ ] |
| 3.3 | Hotbar + inventory UI (view) | matches state; drag/drop goes through the service (no duplication) | [ ] |
| 3.4 | Localization wiring (`tr()`, CSV vi/en) | switching language changes all UI; script reports missing keys | [ ] |

## Phase 4 — Farming (the heart)  ~50–90 h

| ID | Task | Acceptance | Status |
|---|---|---|---|
| 4.1 | `CropData` (1 crop) + `FarmGridState` (pure): till/plant/water/advance/harvest | lifecycle test; no water → no growth; rain → grows; out of season → dormant | [ ] |
| 4.2 | `FarmView` with placeholders | state change → visual change; view holds no rules | [ ] |
| 4.3 | `ToolAction` (Hoe, Water, Seed) + target highlight + `tool_hit` (placeholder) | tool acts on the right cell; out of reach is refused with feedback | [ ] |
| 4.4 | Harvest → inventory via `Events` | no double harvest; full inventory blocks and the crop stays | [ ] |
| 4.5 | `DaySimulator` v0 | sleep N times == `simulate_day` N times; order as in ARCHITECTURE §5 | [ ] |
| 4.6 | Save/Load v1 (clock, player, inventory, farm) + migration skeleton + backups + fuzz test | save→load→save identical; corrupted file doesn't crash; golden save v1 | [ ] |
| 4.7 | Game-feel pass (tool sounds, dust, number pops, animation timing) | you want "one more loop" | [ ] |

### ===== GATE A =====

## Phase 5 — Economy  ~40–70 h

| ID | Task | Acceptance | Status |
|---|---|---|---|
| 5.1 | `EconomyService` + ledger | coins int, never negative, reason required, atomic with inventory | [ ] |
| 5.2 | Shop buy/sell + saturation pricing + basic seeds always buyable | no softlock; buy price ≥ sell price; edge tests | [ ] |
| 5.3 | Order board by formula (seeded) | rewards within cap; expiry without penalty; load doesn't re-roll | [ ] |
| 5.4 | `tools/sim_economy.gd` headless | table of coins/day for 4–5 strategies; invariants hold | [ ] |
| 5.5 | Shop / order UI + save integration | purchases via UI correct; save/load keeps coins, pressure, orders | [ ] |
| 5.6 | Balance pass from sim results (data only, no code) | time to land expansion #1 within stage-1 target | [ ] |

## Phase 6 — Production & building  ~60–100 h

| ID | Task | Acceptance | Status |
|---|---|---|---|
| 6.1 | `RecipeData` + `MachineState` (finish by `total_minutes`, also across sleep) | completes after N days; buffer full → pauses, never breaks | [ ] |
| 6.2 | `OccupancyMap` + footprint check | no overlap; no placing on locked land; 90° rotation correct | [ ] |
| 6.3 | Build mode: place/rotate/move/remove + refund + save | reload keeps buildings; refund correct; ghost green/red correct | [ ] |
| 6.4 | Land expansion by parcel | locked parcel not tillable; cost by formula; saved | [ ] |
| 6.5 | Upgrades: inventory, watering can | new limits effective; serialized | [ ] |
| 6.6 | Chicken coop + eggs (daily, domain only) | not fed → no egg, hen never dies | [ ] |
| 6.7 | Validator: profit caps for crops/recipes | a deliberately "money-printing" recipe makes the validator FAIL | [ ] |

## Phase 7 — Living world  ~70–120 h

| ID | Task | Acceptance | Status |
|---|---|---|---|
| 7.1 | `WeatherService` seeded (sunny/rain) + 3-day pre-roll + save | golden sequence for a seed; load doesn't re-roll; rain waters plots | [ ] |
| 7.2 | Day/night lighting + rain VFX + ambience (views listen to signals) | smooth transitions; no logic in views | [ ] |
| 7.3 | `EcologyState` (read-only) | metrics respond to actions; eased; thresholds fire once | [ ] |
| 7.4 | Visual ecology feedback (butterflies, birds, clearer water) | visible change at thresholds; no heavy loading | [ ] |
| 7.5 | `EventDirector` v0: 3 events + decision trace + debug panel + sim harness | golden test; 1000-day invariants; off-switch works | [ ] |
| 7.6 | Forecast + ecology journal ("telegraph / explain / counter") | every negative event has forecast + explanation + counter hint | [ ] |

## Phase 8 — NPCs & quests  ~60–110 h

| ID | Task | Acceptance | Status |
|---|---|---|---|
| 8.1 | `DialogueData` + `DialogueService` | read from data; conditions/actions work | [ ] |
| 8.2 | Quest state machine (1 quest) + save | state saved/loaded; objectives measured by events | [ ] |
| 8.3 | NPC schedules on `AStarGrid2D` | right place at the right time; no stuck NPCs, also after load | [ ] |
| 8.4 | NPC shop + merchant Minh by schedule | appears on the right days/hours; stock varies (seeded) | [ ] |
| 8.5 | Dog (follow, name it) | follows, never stuck, no perf impact | [ ] |
| 8.6 | Chapter I + M2.1–M2.4 as quest/dialogue/moment data | playable from day 1 to "station wakes up" without blockers | [ ] |

## Phase 9 — Vertical slice  ~80–140 h

| ID | Task | Acceptance | Status |
|---|---|---|---|
| 9.1 | 3-minute onboarding (beat chain) | a stranger completes it without asking | [ ] |
| 9.2 | Village + forest (slice size) + regional audio | — | [ ] |
| 9.3 | Replace gray-box with real assets (tiered sources, one style) | consistent look; license manifest updated | [ ] |
| 9.4 | Settings + basic accessibility + notebook/journal | — | [ ] |
| 9.5 | Bug bash: full playthrough; save across every milestone | no blockers | [ ] |
| 9.6 | Windows export build + install notes | runs on a clean machine | [ ] |
| 9.7 | Playtest with 3–5 strangers (see Master Plan 16.6) | record metrics | [ ] |

### ===== GATE B =====

## Phase 10 — Async social (only if GATE B passed)  ~80–150 h

10.1 `NetworkGateway` + `MockBackend` (game runs with no server) · 10.2 sign-in + friend code + gift inbox (idempotent, capped) · 10.3 friend farm snapshot (versioned; placeholders for missing cosmetics) · 10.4 community project ledger (finishes once; solo can finish; per-person cap) · 10.5 "casual" leaderboard + report/filter (server validates; no client scores) · 10.6 privacy policy + account deletion + server-down handling.

## Phase 11+ — Expansion & polish

11.1 optional offline progress (loop `simulate_day`, capped, negatives off, clock-rewind detection) · 11.2 four full seasons + festivals · 11.3 extended weather + 15–25 director events · 11.4 fishing + foraging + collections · 11.5 crop quality, fertilizer, soil, irrigation automation · 11.6 remaining NPCs (6–8), outfits, deep decoration · 11.7 Chapter III + post-game (Director maintenance mode) · 11.8 gamepad + full accessibility + achievements · 11.9 performance profiling · 11.10 full localization pass.

## Phase 12 — Release

Store page + trailer · closed beta (20–100 players, 2–4 weeks, no new features) · legal/privacy done · release · post-launch patches and free content updates.

## If you are late — cut in this order

(1) outfits (2) fishing (3) two of the four slice NPCs (4) the second crafting chain (5) weather beyond sunny/rain. NEVER cut: the plant→harvest loop, save/load, DataValidator, tests, onboarding.
