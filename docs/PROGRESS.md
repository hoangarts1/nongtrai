# PROGRESS — THE LIFE  (agent memory: read first, update last)

Last updated: 2026-11-03 (ISO-11 committed 962bba9; next ISO plan pending approval)

## Proposed next scope — new asset/UI/crop ISO sequence (NOT APPROVED)

Owner decisions recorded in D49: use the supplied 128×64 ground atlas with Camera2D zoom0.5; Baloo 2 + Nunito with Open Sans fallback; Monday-start seven-day weeks, 28-day seasons and 06:00 wake time; the confirmed B/J/K/M/H/Escape, 1–8, E, Q/E, F, Z and T bindings; one-cell perennials; the supplied CropData balance table; and the approved wither/recovery/death rules. ISO-11 is complete in commit `962bba9`; the focused quest-book tests pass. The full harness is currently blocked by unrelated worktree deletion of `ui/ui_gallery.gd`, which is intentionally excluded from that commit.

The following is a plan only. No implementation, asset import, InputMap edit or gameplay-data change is authorized until the owner approves this scope and the per-step allow list:

1. **ISO-12 ground/assets:** inspect the supplied files, validate/rebuild the 128×64 Isometric TileSet, preserve placeholders, and wire deterministic ground/decor presentation.
2. **ISO-13 theme/HUD:** verify fonts and diacritics, then align existing native UI/HUD components to the selected tokens without adding unsupported state.
3. **ISO-14 world decor:** add deterministic rocks/grass/decor visuals with the approved collision boundary; no cleanup gameplay.
4. **ISO-15 crops:** expand CropData from the approved table, read manifest pivots, connect stage/wilted/perennial presentation to existing FarmGridState/DaySimulator owners, and preserve saves.
5. **ISO-16 supported screens:** align day-end, inventory planting-item display, and pause/settings before any screen whose domain state is absent.
6. **ISO-17 shop/remaining presentation:** add data-driven planting-item purchasing and only then screens backed by real systems.

### Proposed ISO-12–17 ALLOW_LIST (pending owner approval)

Planning/document files:
~~~text
docs/PROGRESS.md
docs/ROADMAP.md
docs/DECISIONS.md
docs/API_INDEX.md
docs/ARCHITECTURE.md
docs/CREDITS.md
docs/SCENE_CONTRACTS/
docs/UI_LAYOUT.md
docs/INPUT_MAP.md
~~~

Asset/data files, only when the corresponding ISO is approved:
~~~text
assets/tiles/
assets/decor/
assets/objects/
assets/rocks/
assets/grass_clumps/
assets/crops/
data/crops/
ui/theme/
~~~

Runtime/view/test files, only when explicitly named by the approved step:
~~~text
scripts/view/
scripts/domain/
scripts/data/
ui/
tests/unit/
~~~

Everything else remains DO NOT TOUCH, especially existing placeholder art until replacement assets pass validation, old scenes unless explicitly listed, save/core systems outside the named crop integration, and the user's master prompt files.

## Approved task — ISO-11 quest book (automated acceptance delivered)

Owner approved “Duyệt, commit ISO-10 và triển khai ISO-11”. Fresh DataValidator PASS preceded commit **b44c5d5**, exactly the51-file ISO-10 handoff including this plan, excluding/preserving owner's master-plan leading blank line. ISO-11 implementation, automated acceptance and render review are delivered under this scope; exact handoff below. Human F5 acceptance pending. No ISO-11 commit/push.

### MILESTONE / TASK / ACCEPTANCE

MILESTONE: ISO-11 — modular Quest book from reference08, reusing current onboarding/QuestManager/NpcJournal. Approved roadmap row/D48/contract recorded before coding; no daily quest, pin, map, event or XP system.

- Rebuild the existing NpcJournal's script-created presentation into reference08's common tabs, wood/paper two-page layout, left filters/selectable quest list and right title/giver/description/objectives/rewards with fixed footer. Split seven scene pairs (quest_book, filter_bar, quest_list, quest_row, quest_detail, objective_row, reward_card) plus book_controller/book_presenter/book_snapshot, aim <=250 lines each. Shared Theme/icons/actual2D giver portrait may be reused read-only. Never use reference PNG as texture or modify existing scenes/art/Theme.
- Use only registered domain data: current TutorialQuestState has seven boolean farming steps; current QuestManager registers one turnip-delivery QuestData for Minh. Represent onboarding as one actual progress entry with all seven completed flags/STEP_KEYS, not the mockup's fictional four-step counts or rewards. Delivery rows read actual QuestData/get_quest/active/completed state, item requirement/current inventory quantity and Resource coin/item reward. Enumerate future registered quests through existing APIs; do not add quests/data/IDs.
- Offer truthful All/Active/Completed filters with actual counts; unaccepted delivery quests remain visible in All with their actual New status. Daily filter is visibly unavailable, not a fake daily count. Selection/filter/scroll are transient UI values; preserve valid selection during deferred refresh, handle empty lists/missing selection and reset on New Game/load/title. No saved selection/filter/pinned flags or save migration.
- Detail shows real title/description/giver if known, existing shared2D NPC portrait, actual requirement/current bag quantity and completion state. Distinguish current possession from confirmed delivery: a completed quest may have consumed its items, so do not claim current bag progress equals historical delivery. Rewards show current QuestData values as task terms, never a new payout or fabricated historical amount. Onboarding has no reward data: show a truthful no-listed-reward note, no XP/coins/seed gift invented. Preserve actual NPC friendship information formerly shown by the journal through a compact read-only summary.
- All completion flags/checks are read-only. Accept/deliver/payout remain exclusively in the original nearby NPC dialogue/QuestManager transaction path; the book does not add remote accept/deliver/claim/talk actions. Show a localized note to visit the actual giver where relevant. Tracking/pin/map/daily/XP/deadline/category/rank features absent from data stay unavailable/omitted, with no T binding or fake countdown/quest-tier badge. Existing HUD onboarding tracking is unchanged.
- Explicitly authorize replacing only the journal's script-created legacy content branch. Preserve Main/NpcJournal root, NpcPanel class, existing column/title_label/close_button compatibility fields and show_content/enable_tabs/close_requested APIs for dialogue/standalone callers. Add typed journal-only enable_quest_book(main)/show_quest_book APIs and book/controller fields; common tabs reference continues to point at the actual header. Hide legacy journal content when the new view is attached; dialogue tree/buttons/behavior remain unchanged. Record internal-tree migration in the new contract before coding.
- NpcSystem.open_journal keeps its current can-open/lock/close/save guards and delegates journal display to the new book, with old show_content fallback when no book is attached. InventoryController.attach_main wires the journal-only adapter before connecting its common header. Main resets transient book view state on New Game/load/title. No existing public method/signal/ID/path rename; no separate journal modal, new autoload/bus/input action or world-state owner.
- Keep Q/E Bag0/Character1/Quest2 and J/B/I/Tab/Escape behavior. UiCoordinator remains the single modal/clock/world owner, with prior-hold restoration and day-end precedence. Native Tab/Enter/Space/mouse/scroll must reach the book's filter/list/header Controls. Read-only review found NpcSystem._input currently consumes Space as use_tool; authorize a journal-only native ui_* pass-through so the new UI works, keeping dialogue/world gating intact. Title/tutorial/sleep/manual/forced review cannot be bypassed.
- Controller reads existing inventory/social/step signals and queues render after the emitting stack, so a quest reward transaction finishes before UI refresh and emitting Buttons are not freed during clicks. Opening/filtering/selecting/refreshing/locale/scroll/closing never accepts/completes quests, grants rewards/friendship, spends/removes items, rolls weather or advances a day. NPC delivery retains atomic capacity/shortage/reentry/once-only protections. v8/v1-v8 goldens/core/domain/data are read-only.
- Add meaningful native filter/row/tab/focus/scroll/close and no-mutation coverage: new/active/shortage/ready/completed quests, partly/fully completed onboarding, zero/missing reward, empty filter, real NPC giver, long vi/en text, live owner changes and legacy saves. Verify original nearby accept/deliver still pays once and updates the book, with full-bag/insufficient-items/duplicate failures unchanged. Older NPC/tab tests may migrate targeted journal-only internals while retaining all reach/time/quest/wallet/bag/save/lock assertions; dialogue selectors stay compatible.
- Parse/DataValidator/focused/full official suite pass with unchanged180s graphics bound/error gates. Capture/review vi/en at1152x648,1280x720,1920x1080 for actual states/long text/scroll/fixed controls; UI-only overflow fixtures must not add fake runtime quests. Record exact diff/manifest/logs/manual F5 cases and retain pending human acceptance. Current full suite takes148.329s; do not skip checks or silently extend the bound.

### READ-ONLY CONTEXT / DO NOT TOUCH

AGENTS; PROJECT_RULES/PROGRESS/ROADMAP/API_INDEX/ARCHITECTURE/DECISIONS/DATA_SCHEMA/CODE_PATTERNS/INPUT_MAP/STYLE_GUIDE/UI_LAYOUT; contracts inventory/character/hud/ui_components/day_end/morning_bulletin; reference08; TutorialQuestState/QuestPanel.STEP_KEYS/QuestData/QuestManager/NpcSocialState/DataRegistry/InventoryState APIs and current NPC delivery/save/native-input tests. Actual current content: seven onboarding steps, one registered delivery quest, Minh/Linh social NPCs. No daily/XP/pin/deadline/map data exists.

Everything outside the following ALLOW_LIST is read-only: core/domain/data, all old .tscn, appearance/avatar/hair renderers, ui/character/title/profile/pause/morning/day_end/theme, art, project.godot/InputMap bindings, goldens, tools/timeouts/error gates and owner's master plan. If another file is needed, request that exact extension before editing.

### Approved ISO-11 ALLOW_LIST

Existing files:
~~~text
scripts/view/main.gd
scripts/view/npc_panel.gd
scripts/view/npc_system.gd
scripts/view/ui_coordinator.gd
scripts/view/ui_layout.gd
ui/inventory/inventory_controller.gd
localization/strings_vi.csv
localization/strings_en.csv
tests/unit/test_npc_ui.gd
tests/unit/test_inventory_screen.gd
tests/unit/test_character_screen.gd
tests/unit/test_ui_layout.gd
tests/unit/test_ui_mouse.gd
docs/PROGRESS.md
docs/API_INDEX.md
docs/ARCHITECTURE.md
docs/DECISIONS.md
docs/ROADMAP.md
docs/PROJECT_RULES.md
docs/UI_LAYOUT.md
docs/SCENE_CONTRACTS/inventory.md
docs/SCENE_CONTRACTS/hud.md
docs/SCENE_CONTRACTS/ui_components.md
~~~

New files (each named .gd also permits its matching .gd.uid):
~~~text
ui/quests/quest_book.gd
ui/quests/quest_book.tscn
ui/quests/filter_bar.gd
ui/quests/filter_bar.tscn
ui/quests/quest_list.gd
ui/quests/quest_list.tscn
ui/quests/quest_row.gd
ui/quests/quest_row.tscn
ui/quests/quest_detail.gd
ui/quests/quest_detail.tscn
ui/quests/objective_row.gd
ui/quests/objective_row.tscn
ui/quests/reward_card.gd
ui/quests/reward_card.tscn
ui/quests/book_controller.gd
ui/quests/book_presenter.gd
ui/quests/book_snapshot.gd
tests/unit/test_quest_book.gd
tests/unit/test_quest_book_layout.gd
docs/SCENE_CONTRACTS/quest_book.md
~~~

### Order / assumptions / risks

1. After approval, verify ISO-10 exact51-file handoff plus excluded owner edit; fresh DataValidator PASS; commit that manifest only. Suggested commit: feat: add modular character profile and real npc relationships.
2. Record D48/roadmap/contract/internal journal branch migration; build small native views/snapshots/presenter/controller and journal-only adapter. Preserve the original NPC dialogue/transactions and all domain/save owners.
3. Wire current modal/header/native key behavior, live deferred refresh and transient reset; add meaningful no-mutation/old-save/once-only payout/keyboard/mouse/three-size tests without weakening old assertions.
4. Run focused/official checks, inspect clean captures and record exact diff/manifest/logs/manual F5/API/memory. Leave ISO-11 uncommitted until later explicit instruction.

Risks: one live delivery quest is less content than the reference; never duplicate it in production to fill space. Onboarding flags are booleans, not daily quantitative counters. Current bag amount is not delivered history. Journal/NpcSystem input and existing lock timing must preserve native GUI routing/prior holds and day-end priority. Deferred refresh must not clear the selected quest or free an emitting button. Missing daily/pin/map/XP systems remain explicit, not scope expansion. Human playtest is separate from automated acceptance.

## Approved task — ISO-10 character/relationships (automated acceptance delivered)

Owner approved “Duyệt, commit ISO-9 và triển khai ISO-10”. Fresh DataValidator PASS preceded commit **ec3c6d3**, exactly the44-file ISO-9 handoff including this plan, excluding/preserving owner's master-plan leading blank line. ISO-10 implementation, automated acceptance and render review are delivered under the following scope; exact handoff below. No ISO-10 commit/push. Human F5 acceptance remains pending.

### MILESTONE / TASK / ACCEPTANCE

Proposed MILESTONE: ISO-10 — modular Character screen from reference07, with real saved profile/appearance and existing NPC friendship only. Add this approved row/D47 before implementation; no other deferred screen or skill system is opened.

- Recreate reference07's common five-tab wood/paper shell, left framed farmer portrait/name/farm card, right skills area and relationship cards using native Controls/shared Theme. Split seven scene/script pairs: sheet, identity card, avatar portrait, skills panel, skill row, relationship list, relationship card; separate flow/presenter/snapshot helpers, aim <=250 lines each. Existing reference PNG/art/Theme/old scenes are read-only, never runtime mockup textures.
- Left reads Main.profile's actual player_name/farm_name/appearance, with existing localized legacy-name fallback where absent. Reuse the actual PlaceholderAvatar2D renderer/CharacterAppearanceCatalog/AvatarHair2D for UI-local player and NPC portraits. Match saved player choices and actual NPC recipes; no new hairstyle/color/portrait data, rotation, cosmetic editing or independent character renderer.
- No domain supports skill levels/XP/fishing/upgrades/bonuses yet. Preserve the five pictured skill labels as presentation rows marked localized unavailable; do not display invented levels/XP/percentages, working progress bars, yield/speed/price bonuses or upgrade buttons. The identity card omits fictitious farmer level/XP. Mockup's decorative equipment/gift icons must not become unsupported actions.
- Relationship list enumerates the real NpcSocialState.content.npcs, not the mockup's invented roster. Read actual display_name_key, friendship and per-NPC friendship_max. Show raw points/cap plus the shared five-heart row as a view-only floor of the normalized ratio, not gameplay tiers/unlocks. Portraits use each existing NPC appearance. All registered NPCs appear via scroll/wrap; no fake birthdays/gift preferences/discounts/roles/remote talk or gifting actions. Unknown/empty legacy profile/social values use the existing owner defaults rather than fabricated progress.
- Enable Character tab index1 in the common header; Bag0/Character1/Quest2 are enabled, Calendar3/Map4 remain unavailable. Explicitly authorize extending the previous Bag/Quest-only navigation: existing Q/E actions cycle these three in order, native mouse tabs/Close work in all three headers. Preserve J's existing journal and B/I/Tab's inventory shortcuts; add no direct character hotkey, InputMap action, project.godot change or new HUD shortcut. INPUT_MAP edits are descriptive only.
- Main constructs a small view-only character flow before inventory attach/UiCoordinator configure. InventoryController remains the shared header/Q/E request router, extended to the new panel without owning profile/social state. Document typed APIs/tree before coding. No NpcSystem/NpcPanel/domain/public existing API rename or scene edit. Character opening refreshes actual profile/social values; no stale portrait after new game/load.
- UiCoordinator remains the sole modal owner: centered wide bounds, clock held/world locked, prior pause restored, normal modal replacement/native Tab/Enter/Space/mouse routing, title/tutorial/sleep guards and day-end precedence. Character cannot bypass bedtime review/start flow. Begin/dismiss morning bulletin, pause, journal and bag keep their existing behavior; no duplicate modal stack or world E/Q/Space action.
- Opening/scrolling/locale changes/tab switches/dismissal only read state. Never call talk/get_dialogue as a simulated conversation, roll weather, grant friendship, accept/deliver quests, spend/grant coins/items or advance a day. No new domain fields, save schema/version/flags; v8/v1-v8 goldens remain read-only. Existing authoritative normalization/daily-talk cap remain unchanged.
- Extend old inventory/tab tests only for the approved third enabled tab and Q/E traversal, retaining all inventory/sort/discard/selection/clock/world/day-end assertions. Add focused native tab/key/scroll/close/portrait/real friendship and no-mutation tests; exercise zero/partial/max friendship, all real NPCs, old saves, new-game/load resets, prior holds and forced/manual review precedence.
- Parse/DataValidator/focused/full official suite pass under the unchanged180s graphics bound/error gates. Review clean vi/en captures at1152x648,1280x720,1920x1080 with long names/farm names, all six player choices, all NPCs and friendship/empty states. Record exact files/diff/logs/manual F5 cases; human acceptance remains pending.

### READ-ONLY CONTEXT / DO NOT TOUCH

AGENTS; PROJECT_RULES/PROGRESS/ROADMAP/API_INDEX/ARCHITECTURE/DECISIONS/DATA_SCHEMA/CODE_PATTERNS/INPUT_MAP/STYLE_GUIDE/UI_LAYOUT; contracts inventory/hud/ui_components/character_creation/player/day_end/morning_bulletin; reference07; current profile/appearance catalogue/PlaceholderAvatar2D and social/NpcData APIs. Read-only inspection confirmed NpcData.friendship_max/talk_friendship and NpcSocialState.friendship/content.npcs; no skill/XP/birthday/gift domain exists. Existing inventory controller/header currently hard-code enabled[0,2], and test_inventory_screen expects E from Bag to Quest; the above navigation change explicitly authorizes their targeted migration.

Everything outside the following ALLOW_LIST is read-only: all core/domain/data, NpcSystem/NpcPanel, old .tscn, avatar/appearance/hair renderers, art/Theme, title/profile/pause/morning/day-end source, project.godot, save goldens, tools/timeouts/error gates and owner's master plan. If another file proves necessary, request that exact extension before editing.

### Approved ISO-10 ALLOW_LIST

Existing files:
~~~text
scripts/view/main.gd
scripts/view/ui_coordinator.gd
scripts/view/ui_layout.gd
ui/inventory/common_tabs.gd
ui/inventory/inventory_controller.gd
localization/strings_vi.csv
localization/strings_en.csv
tests/unit/test_inventory_screen.gd
tests/unit/test_inventory_ui.gd
tests/unit/test_ui_layout.gd
tests/unit/test_ui_mouse.gd
docs/PROGRESS.md
docs/API_INDEX.md
docs/ARCHITECTURE.md
docs/DECISIONS.md
docs/ROADMAP.md
docs/PROJECT_RULES.md
docs/UI_LAYOUT.md
docs/INPUT_MAP.md
docs/SCENE_CONTRACTS/inventory.md
docs/SCENE_CONTRACTS/hud.md
docs/SCENE_CONTRACTS/ui_components.md
~~~

New files (each named .gd also permits its matching .gd.uid):
~~~text
ui/character/character_sheet.gd
ui/character/character_sheet.tscn
ui/character/identity_card.gd
ui/character/identity_card.tscn
ui/character/avatar_portrait.gd
ui/character/avatar_portrait.tscn
ui/character/skills_panel.gd
ui/character/skills_panel.tscn
ui/character/skill_row.gd
ui/character/skill_row.tscn
ui/character/relationship_list.gd
ui/character/relationship_list.tscn
ui/character/relationship_card.gd
ui/character/relationship_card.tscn
ui/character/character_flow.gd
ui/character/character_presenter.gd
ui/character/character_snapshot.gd
tests/unit/test_character_screen.gd
tests/unit/test_character_layout.gd
docs/SCENE_CONTRACTS/character.md
~~~

### Order / assumptions / risks

1. After approval, verify ISO-9 exact44-file handoff manifest plus excluded owner edit; fresh DataValidator PASS; commit that manifest only. Suggested commit: feat: add modular morning bulletin after completed day rollover.
2. Record D47/roadmap/contract and the enabled-tab migration. Implement read-only small views/portraits/snapshots, Main wiring, shared tab routing and modal layout. Preserve authoritative profile/social/save/simulation owners.
3. Add meaningful no-mutation/real-friendship/player-NPC portrait/native three-tab/input/legacy-save/guard coverage; adjust only old third-tab expectations, keeping their behavioral checks.
4. Run focused/official checks, inspect clean captures and record full diff/manifest/logs/manual F5/API/memory. Leave ISO-10 uncommitted until later explicit instruction.

Risks: reference07 includes unsupported progression and some fictional NPC details; copying them would misrepresent game state. Five hearts must describe the existing numeric ratio only. The current world registers two NPCs (Minh/Linh); the appearance catalogue also has other recipes, which are not extra social-state NPCs. Long names/six-choice portraits and a growing list require responsive scrolling at1152. Q/E must move through three panels without leaking world interaction or losing prior clock hold. Native Tab/Space must work in the new modal without opening Bag/using tools. Existing journal/quest actions remain untouched. No promise of skill/XP/gift/calendar/house/fertilizer implementation is included.

## Approved task — ISO-9 morning bulletin (automated acceptance delivered)

Owner approved “Duyệt, commit ISO-8b và triển khai ISO-9”. Fresh DataValidator PASS preceded commit **57008ab**, exactly the50-file ISO-8b handoff (including the approved proposal), excluding/preserving owner's master-plan leading blank line. ISO-9 implementation, automated acceptance and render review are delivered under this scope; exact handoff follows below. No ISO-9 commit/push. Human F5 acceptance remains pending.

### MILESTONE / TASK / ACCEPTANCE

MILESTONE: ISO-9 — modular morning bulletin from reference05, using existing weather/farm/quest/item APIs. Only this deferred screen is opened.

- Recreate the newspaper/paper composition with shared Theme/native Controls: actual date/season/year masthead, three columns, forecast row, real to-do strip and green Begin Day button. Split sheet/weather/garden/market/price-row/task-strip scene pairs plus small flow/presenter/snapshot helpers (aim <=250 lines each). Never load the reference PNG as a runtime texture; no new artwork/Theme resource.
- Left: actual WeatherState.today, localized weather/care explanation and the existing three saved forecast days, not fabricated extra predictions to fill reference's five pictured icons. Read saved forecast only; rendering/open/close/load never rolls weather, advances time or waters crops.
- Middle: existing tutorial/quest progress and actual garden status. Reference birthdays/festivals/calendar are not implemented: show a localized unavailable note rather than fictitious events, gifts or dates. Header can say Today rather than imply an event service. Empty/completed garden/quest states remain truthful.
- Right: current produce unit sale prices from unchanged ItemData, the same prices ShippingBinPanel actually reads. List actual registered sellable produce with existing item names/icons, scroll if needed. No fake crossed-out prices, up/down trends, discounts, saturation or merchant quote presented as general shipping-bin price. Prices are informational; no trade or wallet/inventory mutation.
- Footer: actual harvestable/living-needs-water/tilled-empty plot information via current farm APIs, plus supported quest hints. No automatic actions, invented rewards/stamina/XP or unavailable gifting/sowing claims. Rain/wither/repeat-crop handling follows the completed real morning snapshot.
- Open once per real completed day rollover, through a view-only pending-day flow owned by Main. Main's existing day_started callback queues it after the one DaySimulator/weather/ledger path; actual presentation waits until day-end advancement/panel/other modal and sleep guards clear, after completed-morning save. Direct/manual/forced day transitions use the same existing path; no second simulation callback.
- Begin Day/Escape dismisses the bulletin only and restores the modal owner's prior clock/input hold. Normal modal switching remains exclusive and day-end keeps precedence. While bulletin is visible, world input is locked and clock held. A view-only last-shown/pending-day guard deduplicates same-day/reentrant notifications without becoming gameplay state.
- Deliberate lifecycle: do not auto-open on new-game/tutorial or merely loading a save/Continue. Reset pending bulletin on New Game/load/return-to-title to avoid stale popups. No saved bulletin-dismissed flag, SaveService/schema migration or fabricated old notifications; loading a completed morning simply resumes that saved game. Existing day-end review restoration remains primary.
- Existing Main/DayEndFlow/Clock/public save/domain behavior and v8/goldens remain. DayEndFlow and all domain/core/data are read-only; integrate only Main wiring plus UiCoordinator/UiLayout. Update older day-end/UI tests only for the new post-rollover modal, keeping all exactly-once/time/crop/wallet/save/guard assertions and checking resume after dismiss.
- Parse/DataValidator, focused morning/weather/save/day-end/input tests and full official suite pass with existing180s graphics bound/error gates unchanged. Capture/review vi/en at1152x648,1280x720,1920x1080 for dry/rain/empty/ready/withered/repeat crops, quest states, price rows, long text/scroll. Before/after bulletin display/dismiss, domain snapshots remain identical; no reroll, coin/item mutation or extra day. Human editor acceptance remains pending.

### READ-ONLY CONTEXT / DO NOT TOUCH

AGENTS; PROJECT_RULES/PROGRESS/ROADMAP/API_INDEX/ARCHITECTURE/DECISIONS/DATA_SCHEMA/CODE_PATTERNS/INPUT_MAP/STYLE_GUIDE/UI_LAYOUT; contracts day_end/hud/ui_components; reference05; existing WeatherState/FarmGridState/TutorialQuestState/DataRegistry/ItemData/ShippingBinPanel APIs; day-end/clock/save tests and flow. Everything outside the following ALLOW_LIST is read-only, including all core/domain/data, DayEndFlow source, existing .tscn, artwork/Theme, title/profile/pause source, project.godot, v1-v8 goldens, tools/error gates and owner's master plan.

### Approved ISO-9 ALLOW_LIST

Existing files:
~~~text
scripts/view/main.gd
scripts/view/ui_coordinator.gd
scripts/view/ui_layout.gd
localization/strings_vi.csv
localization/strings_en.csv
tests/unit/test_day_end_flow.gd
tests/unit/test_day_end_save.gd
tests/unit/test_ui_layout.gd
tests/unit/test_ui_mouse.gd
tests/unit/test_weather.gd
docs/PROGRESS.md
docs/API_INDEX.md
docs/ARCHITECTURE.md
docs/DECISIONS.md
docs/ROADMAP.md
docs/PROJECT_RULES.md
docs/UI_LAYOUT.md
docs/SCENE_CONTRACTS/day_end.md
docs/SCENE_CONTRACTS/hud.md
docs/SCENE_CONTRACTS/ui_components.md
~~~

New files (each named .gd also permits its matching .gd.uid):
~~~text
ui/morning/morning_sheet.gd
ui/morning/morning_sheet.tscn
ui/morning/weather_column.gd
ui/morning/weather_column.tscn
ui/morning/garden_column.gd
ui/morning/garden_column.tscn
ui/morning/market_column.gd
ui/morning/market_column.tscn
ui/morning/price_row.gd
ui/morning/price_row.tscn
ui/morning/task_strip.gd
ui/morning/task_strip.tscn
ui/morning/morning_flow.gd
ui/morning/morning_presenter.gd
ui/morning/morning_snapshot.gd
tests/unit/test_morning_flow.gd
tests/unit/test_morning_layout.gd
docs/SCENE_CONTRACTS/morning_bulletin.md
~~~

### Order / assumptions / risks

1. After approval, verify ISO-8b exact50-file manifest plus excluded owner edit; fresh validator; commit that manifest only. Suggested commit: feat: add modular farmer creation and shared 2d hair preview.
2. Record D46/roadmap/scene contract and the presentation-only queue/dismiss lifecycle, then implement small views/snapshots and Main wiring. Keep the existing day simulator/weather/save path unchanged.
3. Integrate one modal/viewport layout and add native click/keyboard, pending/dedup/reset/day-end precedence, no-mutation/no-reroll/save compatibility tests. Update existing post-sleep modal expectations without weakening domain assertions.
4. Run focused and official full checks, inspect clean screenshots, record exact files/diff/logs/manual F5 checklist/API/memory. Leave ISO-9 uncommitted until later explicit instruction.

Risks: day_started occurs synchronously while day-end guard is advancing, so opening immediately would be rejected or race the final save; defer presentation until the existing flow completes. New modal must restore prior pause/input and not leak stale pending state across load/title. Forecast has three future entries, not five; price trends/event calendar do not exist. Small-screen three-column/long vi-en text needs scrolling around fixed action/footer. No new playtime/day simulation/save state is implied. Request an exact scope extension before touching any other file.

## Approved task — ISO-8b character creation (automated acceptance delivered)

Owner approved “Duyệt, commit ISO-8a và triển khai ISO-8b”. ISO-8a committed **a683feb** after fresh DataValidator PASS, exactly its42-file handoff manifest below, excluding/preserving owner's master-plan leading blank line. ISO-8b implementation/automated acceptance/render review are delivered under this scope. No ISO-8b commit/push. Human F5 acceptance remains pending.

### MILESTONE / TASK / ACCEPTANCE

Proposed MILESTONE: ISO-8b — modular reference02 creation UI and matching 2D preview. Only this deferred screen is opened; Main's existing profile/new-world/save owners remain unchanged.

- Rebuild profile mode into reference02's two-panel composition: left wood/paper form with red title ribbon, paired name/farm fields, hairstyle buttons and skin/hair/outfit swatches; right framed 2D avatar preview plus actual draft name/farm captions. Back and green Start stay fixed while form choices scroll if necessary. Keep shared Theme and existing title illustration, no reference PNG/runtime crop/new bitmap.
- Use small scene/script components for name fields, choice rows, swatch buttons, preview and presenter/helpers. Keep all six current data-backed choices in each category rather than truncating them to the reference's pictured3/5. Colors/styles come from the unchanged CharacterAppearanceCatalog. No new selection IDs/colors/gender/pet/house/bonus/name-validation rules or gameplay data.
- Preview uses the real PlaceholderAvatar2D renderer in a UI-local2D stage, not a 3D model or a separate invented portrait. Read-only inspection found configure_profile already resolves colors but _draw ignores the selected hairstyle. Add a small shared VIEW-only hair drawing helper and apply normalized player hairstyle selections in that existing renderer. Preview and actual player must show the same six distinct hair silhouettes and colors. NPCs without a player customization keep their existing hair rendering; no movement/collision/timing/action geometry or domain changes.
- Preview arrows cycle the existing hairstyle choices, with localized tooltips/caption explaining that action. Do not claim rotation or invent facing frames/input actions. Draw only replaceable decorative UI scenery; no pet/game entity is introduced. Body rendering remains the existing replaceable2D avatar art.
- Explicitly authorize replacing profile form's script-created AppearanceGrid/OptionButton internals with typed choice components, and updating related tests' selection/lookups while retaining all six-choice/normalization/form-dispatch assertions. Preserve Main/StartMenu, configure callbacks, appearance_selected, get_appearance_selection, form get_selection/submitted/cancelled and actual _name_box VBox reference. No data ID/public flow/signal rename; document the new tree/APIs before coding.
- Name text/selected choices remain transient until the original Submit request. Back/reopen preserves drafts as in ISO-8a; locale changes update captions without clearing typed values. Start emits normalized appearance before the unchanged two-string New Game callback exactly once per confirmation. Existing clean-world/wallet/starter-seed behavior, saved profile shape and v1-v8 goldens remain. No SaveService/Main/domain migration changes.
- Keep UiCoordinator as single modal owner. Profile gets a wide viewport-bounded rectangle while title/settings stay compatible. Native clicks/swatches/arrows, Tab/Enter/Space/LineEdit typing and Escape/Back work without world actions. No new InputMap, autoload, bus signal or old scene edits.
- Extend only the full graphics GUT invocation's bounded timeout from default120s to180s: the current full suite already takes111.822s. Preserve every parse/data/headless/full test, error-text check and exit-code gate; no skipped tests or altered helper defaults.
- Run focused native/form/save/preview tests and official full suite; compare vi/en captures at1152x648,1280x720,1920x1080 and all six hairstyles/colors, verify preview/player parity and no gameplay mutation before Start. Record real logs, exact diff/manifest and manual F5 cases. Human editor acceptance remains pending.

### READ-ONLY CONTEXT / DO NOT TOUCH

AGENTS; PROJECT_RULES/PROGRESS/ROADMAP/API_INDEX/ARCHITECTURE/DECISIONS/DATA_SCHEMA/CODE_PATTERNS/INPUT_MAP/STYLE_GUIDE/UI_LAYOUT; contracts start_menu/player/gray_box_world/hud/ui_components; reference02; CharacterAppearanceCatalog/Data APIs and resources; Main/WorldPresentation profile wiring; current title/profile/appearance/input/save tests. Everything outside the proposed ALLOW_LIST is read-only, including Main, core/domain/data, all existing .tscn, source art/Theme/ui-pause resources, project.godot, goldens and owner's master plan.

### Proposed ISO-8b ALLOW_LIST

Existing files:
~~~text
ui/title/profile_form.gd
ui/title/title_screen.gd
ui/title/title_presenter.gd
scripts/view/start_menu.gd
scripts/view/ui_layout.gd
scripts/view/ui_coordinator.gd
scripts/view/placeholder_avatar_2d.gd
localization/strings_vi.csv
localization/strings_en.csv
tests/unit/test_title_flow.gd
tests/unit/test_title_layout.gd
tests/unit/test_chibi_characters.gd
tests/unit/test_ui_layout.gd
tests/unit/test_ui_mouse.gd
tools/run_tests.bat
docs/PROGRESS.md
docs/API_INDEX.md
docs/ARCHITECTURE.md
docs/DECISIONS.md
docs/ROADMAP.md
docs/PROJECT_RULES.md
docs/UI_LAYOUT.md
docs/SCENE_CONTRACTS/start_menu.md
docs/SCENE_CONTRACTS/player.md
docs/SCENE_CONTRACTS/gray_box_world.md
docs/SCENE_CONTRACTS/hud.md
docs/SCENE_CONTRACTS/ui_components.md
~~~

New files (each named .gd also permits its matching .gd.uid):
~~~text
ui/profile/name_fields.gd
ui/profile/name_fields.tscn
ui/profile/profile_choices.gd
ui/profile/profile_choices.tscn
ui/profile/choice_row.gd
ui/profile/choice_row.tscn
ui/profile/choice_swatch.gd
ui/profile/choice_swatch.tscn
ui/profile/avatar_preview.gd
ui/profile/avatar_preview.tscn
ui/profile/profile_presenter.gd
ui/profile/profile_parts.gd
scripts/view/avatar_hair_2d.gd
tests/unit/test_profile_creation.gd
tests/unit/test_profile_preview.gd
docs/SCENE_CONTRACTS/character_creation.md
~~~

### Order / assumptions / risks

1. After approval, verify ISO-8a exact42-file manifest plus excluded owner edit, fresh validator, commit that manifest only. Suggested commit: feat: add modular main menu with live save summary.
2. Record D45/roadmap/scene contract and explicit internal-control migration. Build small components and shared hair renderer, then wire the existing StartMenu profile adapter without changing Main/data.
3. Add native six-choice/normalization/name/draft/one-submit/preview-player-parity coverage and update old lookups. Raise only graphics-suite timeout as specified; keep all error gates.
4. Run focused/official full checks, inspect clean screenshots, update API/memory with manifest/diff/logs/manual steps; leave ISO-8b uncommitted pending later instruction.

Risks: current avatar is placeholder art; hairstyle silhouettes must remain readable at normal in-game scale and match enlarged preview. Existing NPC visuals must remain stable. Six choices/long vi-en labels and paired name fields need responsive wrapping/scroll at1152. Avoid emitting selection while rebuilding controls or losing keyboard focus. Existing profile API migration needs all normalization/data-choice assertions retained. No claimed camera rotation or new name restrictions. If another file is needed, request that exact scope extension before editing.

## Approved task — ISO-8a main-menu presentation (automated acceptance delivered)

Owner approved “Duyệt, commit ISO-7 và triển khai ISO-8a”. ISO-7 committed **4ccc8de** after fresh DataValidator PASS, exactly its43-file handoff manifest below, excluding the preserved owner master-plan blank-line edit. ISO-8a implementation/automated acceptance/render review are delivered under the following approved scope. No ISO-8a commit/push; human playtest still pending. Historical unchecked roadmap entries are not treated as missing systems.

### MILESTONE / TASK / ACCEPTANCE

Proposed MILESTONE: ISO-8a — modular main menu from reference01, using existing start/profile/save/settings APIs. This deliberately opens one of prompt section6's deferred screens after owner approval; no other deferred screen/domain is included.

- Match reference01's composition with native Controls/shared Theme: left wood/paper card, green THE LIFE banner, tagline, recent-save card, prominent Continue, side-by-side New Game/Settings, red Exit and footer. Keep the existing assets/ui/title_valley.png illustration via TitleBackdrop; it is a reusable placeholder, not a claim of newly matching final background art. Never load/crop the reference PNG as a runtime asset. No bitmap generation, asset replacement or Theme-resource edits.
- Separate small scene/script components: title screen, actions, latest-save card, existing profile form, settings wrapper; separate presenter/construction helpers. New scripts aim <=250 lines. StartMenu remains the Main child/public adapter; preserve configure callbacks, appearance_selected, get_appearance_selection, refresh_continue, apply_chibi_style and the actual new-game/continue/exit lifecycle.
- Latest-save card reads SaveService's existing validated latest payload/summary, not live world defaults: farm/player name, saved day and coins where present; empty/corrupt/old-save fallback is localized and safe. Continue is enabled only for an actual valid latest slot0/1 and keeps Main's existing newest-save selection. No invented playtime, house level, portrait or economy rewards. Show version only if real metadata/config supplies it; omit unavailable fields.
- Preserve current clean-world/profile/customization behavior. Extract the existing name/farm/appearance form without redesigning it to reference02, changing selectable data or save shape. Keep _name_box/_settings_box compatibility references and ConfirmNewGame/AppearanceGrid selector names. Repeated New Game does not duplicate controls or grant items; initial seeding and name/appearance normalization remain in existing owners.
- Settings reuses ISO-7's existing LifeSettingsPanel/audio/game pages and only supported locale/music/effects preferences, with Apply/Default/draft cancellation; Back returns to title without entering gameplay. No pause overlay or second modal owner is opened behind StartMenu. Native focus/Enter/Space/Tab and mouse dispatch work while world shortcuts stay blocked. Existing start/settings/form clocks/locks remain. Main callbacks, save version8/atomic backups and v1-v8 goldens are read-only.
- Explicit internal-layout change authorized by this plan if approved: replace old StartMenu/MarginContainer/Column layout paths (including NewGame/Continue Button paths) with typed screen/component references documented in new start_menu.md; update the relevant old layout/focus tests to those references while retaining all behavior assertions. Main/StartMenu, public callbacks/signals, data IDs, InputMap and existing .tscn nodes are not renamed/moved/deleted. This permission is limited to script-created internal menu controls.
- Update PROJECT_RULES migration notice only: it still incorrectly says ISO-7 planned despite D43/PROGRESS delivery. Add D44 explaining the status correction and approved new row; do not change locked engine/gameplay/architecture rules. Human editor gates remain pending.
- Parse/DataValidator, meaningful save/start/profile/settings/physical-input regressions and official full renderer suite pass. Capture/review vi/en at1152x648,1280x720,1920x1080 for valid/no/corrupt save, long names, profile form and settings. Record real logs, exact diff/manifest and F5 checklist. Do not claim human acceptance or commit ISO-8a automatically.

### READ-ONLY CONTEXT / DO NOT TOUCH

AGENTS.md; PROJECT_RULES/PROGRESS/ROADMAP/API_INDEX/ARCHITECTURE/DECISIONS/DATA_SCHEMA/CODE_PATTERNS/INPUT_MAP/STYLE_GUIDE/UI_LAYOUT; scene contracts hud/ui_components/pause_menu; references01/02; scripts/view/main.gd and title_backdrop.gd; Settings/SaveService/appearance catalogue APIs; existing ui/pause components and title/profile/mouse/focus tests. Everything outside the following proposed ALLOW_LIST is read-only, including all existing .tscn, core/domain/data, source art, Theme, ui/pause, project.godot, goldens and docs/reference/THE_LIFE_MASTER_PLAN.txt.

### Proposed ISO-8a ALLOW_LIST

Existing files:
~~~text
scripts/view/start_menu.gd
scripts/view/ui_layout.gd
scripts/view/ui_coordinator.gd
localization/strings_vi.csv
localization/strings_en.csv
tests/unit/test_ui_layout.gd
tests/unit/test_ui_mouse.gd
tests/unit/test_chibi_ui.gd
tests/unit/test_chibi_characters.gd
docs/PROGRESS.md
docs/API_INDEX.md
docs/ARCHITECTURE.md
docs/DECISIONS.md
docs/ROADMAP.md
docs/PROJECT_RULES.md
docs/UI_LAYOUT.md
docs/SCENE_CONTRACTS/hud.md
docs/SCENE_CONTRACTS/ui_components.md
~~~

New files (each named .gd also permits its matching .gd.uid):
~~~text
ui/title/title_screen.gd
ui/title/title_screen.tscn
ui/title/title_actions.gd
ui/title/title_actions.tscn
ui/title/latest_save_card.gd
ui/title/latest_save_card.tscn
ui/title/profile_form.gd
ui/title/profile_form.tscn
ui/title/title_settings.gd
ui/title/title_settings.tscn
ui/title/title_presenter.gd
ui/title/title_parts.gd
tests/unit/test_title_flow.gd
tests/unit/test_title_layout.gd
docs/SCENE_CONTRACTS/start_menu.md
~~~

### Order / assumptions / risks

1. After approval, verify ISO-7 dirt against its43-file delivered manifest plus excluded owner edit; fresh validator; commit only that manifest (including this PROGRESS proposal). Suggested commit: feat: add modular pause settings and reliable save feedback.
2. Record D44/new roadmap row/component contract and the internal-path migration, then implement the small views and thin StartMenu adapter. Keep existing TitleBackdrop, Main callbacks and profile/appearance owners.
3. Adjust only StartMenu geometry/style exemptions and GUI input handling; write physical click/focus and state-preservation regressions, including settings close/reopen and invalid/empty/old save.
4. Focused checks, official full suite, clean screenshot inspection, exact handoff/API/memory update. ISO-8a remains uncommitted pending later explicit instruction.

Risks: narrow title card at1152 and long vi/en names need wrapping/scroll without hiding buttons; settings needs the wide layout while retaining StartMenu as sole modal; old private-path tests must migrate explicitly without weakening assertions; extracting profile form must preserve selected appearance/name state and avoid duplicate signals. Existing background is intentionally retained and is not pixel-identical to reference01. Missing playtime/house data is omitted; no new game system or save migration is implied. Stop for an exact scope extension if another file is required.

## Approved task — ISO-7 pause/settings/save UI (automated acceptance delivered)

Owner approved “Duyệt, commit ISO-6b1 và triển khai ISO-7”. Fresh DataValidator PASS preceded commit **4b3ca62**, exactly the delivered 73-file ISO-6b1 manifest; the owner's existing master-plan edit is excluded and preserved. ISO-7 implementation and automated acceptance/render review are delivered under the following approved plan/ALLOW_LIST. No ISO-7 commit/push; human editor acceptance remains pending.

### Task and acceptance

- Rebuild the existing PauseMenu as the reference-14 two-panel wood/paper composition: red pause ribbon, left action list, right settings tabs, close control and footer hints. Reuse the shared Theme/native Controls and existing InputMap; never load the reference PNG at runtime. Preserve Main/PauseMenu and configure/open/close/toggle compatibility, including the existing _toggle_settings test adapter.
- Split presentation into small scene/script components under ui/pause: shell, action list, settings panel, audio page, game page and controls help. Separate presenter and construction helpers; aim for each new script <=250 lines. Views own only transient tab/draft/focus state, never gameplay/settings truth.
- Resume, manual Save, existing manual Load and Return to menu remain reachable. Keep Load as a secondary action because the reference omits this existing feature. Save status comes from real save metadata/outcomes. Propagate Main's actual save/load result to the view; a blocked/failed write must not show success. Return to menu stays in the game with feedback when its required save fails. Retain NPC/sleep/day-rollover safe-point guards, automatic saves, v8 schema, atomic writes/backups and all v1-v8 goldens.
- Four reference tabs: Audio, Graphics, Controls, Game. Audio edits existing music/effects preferences with actual numeric percentages; Game edits vi/en. Apply commits only these supported preferences through existing Settings setters; Default resets only their draft to existing defaults (vi, music/effects 1.0). Closing discards unapplied drafts. Existing sound effects consume their preference; storing music volume does not imply an implemented music player.
- Controls displays current InputMap bindings read-only. Graphics/fullscreen, separate rain/wind volume, key-hint visibility, morning-autosave switch, harvest screen shake and S/M/L font sizing are visibly unavailable with a localized explanation. Do not invent backends, override current autosave behavior or display arbitrary active settings. Layout/chrome follows reference 14; this is explicitly a supported-controls implementation, not completion of every pictured preference.
- Existing UiCoordinator remains the sole modal owner. Keep clock/player/world locking, day-end precedence, modal switching, focus, Escape, mouse dragging and keyboard slider navigation correct. Apply locale refreshes visible/hidden captions without rebuilding controls during their emitting signal. Fixed close/action/footer controls remain visible while settings content scrolls.
- Pass parse/data gates, focused native save/settings/input tests and the official full suite. Render/review both vi/en at 1152x648, 1280x720 and 1920x1080, including all four tabs, dirty/apply/default/cancel states and save/load failure feedback. Retain old goldens, run meaningful compatibility tests, record real logs and human editor checklist. Human acceptance remains pending until the owner tests it.

### READ-ONLY CONTEXT / DO NOT TOUCH

Read: AGENTS.md; docs/PROJECT_RULES.md; docs/ROADMAP.md; docs/API_INDEX.md; docs/ARCHITECTURE.md; docs/DATA_SCHEMA.md; docs/CODE_PATTERNS.md; docs/DECISIONS.md; docs/INPUT_MAP.md; docs/STYLE_GUIDE.md; docs/SCENE_CONTRACTS/{hud,ui_components,day_end}.md; docs/UI_LAYOUT.md; docs/ui_reference/14-tam-dung-cai-dat.png; existing Settings, SaveService, AudioService, Theme and component APIs; existing modal/save/input tests. Everything outside the following list is read-only, including project.godot, all gameplay/domain/data files, existing .tscn scenes, source art, historical goldens and docs/reference/THE_LIFE_MASTER_PLAN.txt. Fertilizer, house upgrades/corn gating and other mockup screens remain outside this task.

### Proposed ALLOW_LIST

Existing files to modify:
~~~text
scripts/view/pause_menu.gd
scripts/view/main.gd
scripts/view/ui_layout.gd
scripts/view/ui_coordinator.gd
localization/strings_vi.csv
localization/strings_en.csv
tests/unit/test_pause_menu.gd
tests/unit/test_ui_layout.gd
tests/unit/test_ui_mouse.gd
docs/PROGRESS.md
docs/API_INDEX.md
docs/ARCHITECTURE.md
docs/DECISIONS.md
docs/ROADMAP.md
docs/UI_LAYOUT.md
docs/SCENE_CONTRACTS/hud.md
docs/SCENE_CONTRACTS/ui_components.md
~~~

New files allowed (each named .gd also permits its matching .gd.uid):
~~~text
ui/pause/pause_shell.gd
ui/pause/pause_shell.tscn
ui/pause/pause_actions.gd
ui/pause/pause_actions.tscn
ui/pause/settings_panel.gd
ui/pause/settings_panel.tscn
ui/pause/audio_settings.gd
ui/pause/audio_settings.tscn
ui/pause/game_settings.gd
ui/pause/game_settings.tscn
ui/pause/controls_help.gd
ui/pause/controls_help.tscn
ui/pause/pause_presenter.gd
ui/pause/pause_parts.gd
tests/unit/test_pause_settings.gd
tests/unit/test_pause_layout.gd
docs/SCENE_CONTRACTS/pause_menu.md
~~~

### Implementation order / assumptions / risks

1. After approval, verify current dirt matches the delivered ISO-6b1 manifest plus the owner's excluded master-plan edit; fresh validator; commit only that manifest. Proposed commit: feat: add repeat crop cycles and save v8 compatibility.
2. Document the new component tree/APIs and D43, then build the small scenes/scripts and wire the existing PauseMenu adapter. Reuse existing Theme button/frame/slider/tab/toggle presentation; no Theme resource edits or new input actions.
3. Connect draft settings and save results, adjust only pause modal geometry/styling exemptions, preserve existing Main callbacks and modal arbitration. Add failure, persistence, cancel/default, locale, physical-input and three-size layout coverage.
4. Run focused checks and official tools/run_tests.bat, inspect clean screenshots, update API_INDEX/PROGRESS with exact diff/manifest/logs and manual F5 cases. Do not commit ISO-7 without an explicit later instruction.

Risks: English text and the two-panel composition need scrolling at the smallest size; native settings keyboard focus must not leak into world actions; load can restore a paused day-end review; existing ConfigFile setters have no success return, so preference persistence is verified by reload tests rather than a claimed atomic multi-setting transaction. No new music/weather audio playback is included. Unsupported pictured controls remain explicit until separately scoped. If any required implementation needs a file outside this list, stop and request that exact scope extension.

## Current milestone

`ISO-11 (Quest book)` — owner approved commit ISO-10 and implement ISO-11. ISO-10 committed **b44c5d5** after fresh validator PASS, exact51-file manifest, owner edit excluded. Seven small scene pairs/three helpers under the existing NpcJournal show actual onboarding/delivery status/current quantities/Resource reward terms, with transient filters/selection and real NPC friendship. Native GUI keys work, original nearby dialogue retains atomic/once-only payout, and modal/clock/day-end guards remain. No domain/core/data/old scene/Theme/renderer/InputMap/save-v8 changes. Official renderer289/289 (14259 asserts), official headless62/62 (879), focused headless40/40 (2957), clean renderer8/8 (876); parse/data/main PASS.42 vi/en/three-size captures reviewed. ISO-11 uncommitted, human F5 acceptance pending. Other deferred systems remain outside scope. Historical handoffs retain delivery-time status; ISO-10 is now committed.
## ISO-6b1 final automated acceptance (2026-11-03, D42)

Delivered within the approved scope: exact crop/price table, data-owned 80-coin initial/repeat return ceiling with retained price guards; first/repeat crop targets owned by FarmGridState; small stateless cycle/codec/economy helpers; one-time seed consumption, no free water/dry-streak reset, full-bag/no-repeat-harvest guards; real cycle-aware stage/countdown; v8 old-plant compatibility and multi-cell view refresh. Existing old fields/goldens, crop IDs/yields/seasons/care, input/scenes/art/autoloads/bus, atomic saves and owner edit remain. ISO-6a committed **7f7a429**; ISO-6b1 is uncommitted, no push. Fertilizer/house unlock and human editor acceptance remain pending; this does not mark all ISO-6 complete.

Real final output, Godot 4.7.2 / GUT 9.7.1, isolated APPDATA:

~~~text
[check_parse] OK
[validate_data] PASS

Official headless subset:
Totals
------
Scripts              16
Tests                62
Passing Tests        62
Asserts             879
Time              3.682s


---- All tests passed! ----

Focused balance/cycle/save/care/year headless:
Totals
------
Scripts               6
Tests                24
Passing Tests        24
Asserts             546
Time              0.505s


---- All tests passed! ----

Native cycle + prior care/social/save headless (before adding multi-cell restore regression; the final full run includes it):
Totals
------
Scripts               4
Tests                14
Passing Tests        14
Asserts             503
Time              13.653s


---- All tests passed! ----

COMPLETE graphics-renderer suite:
Totals
------
Scripts              71
Tests               238
Passing Tests       238
Asserts            8411
Time              89.788s


---- All tests passed! ----

[run_tests] starting main scene headless
[run_tests] PASS

Separate clean-render cycle/legacy-view suite:
Totals
------
Scripts               2
Tests                 6
Passing Tests         6
Asserts             252
Time              11.089s


---- All tests passed! ----
~~~

Final scans: zero SCRIPT ERROR / Parse Error / ERROR / resource-leak / orphan matches in official headless/full-renderer/main logs. Intentional malformed-data tests warn for invalid farm targets/care/rows and retained invalid-inventory cases. No test/guard was skipped or weakened; old turnip timing assertions now follow the approved 4-day data while retaining premature/ready/moisture/visual checks. Full-year coverage keeps 112-day/coins/transaction invariants, adds a second repeat pick and clears the retained withered plant before next-season sowing. JSON round-trip normalization preserves all field values while allowing JSON numeric type conversion; native domain target ints are tested separately. git diff --check PASS; all 73 files are inside ALLOW_LIST. FarmGridState is 213 lines; all new scripts below 250. gdtoolkit lint was not run (not installed); no packages installed.

Visual evidence: 24 clean captures at C:/Users/daova/AppData/Local/Temp/the_life_iso6b1_review/iso6b1_{vi,en}_{legacy_ready,repeat,repeat_ready,dry_repeat}_{1152,1280,1920}.png. Reviewed vi repeat/en legacy-ready at 1152, vi dry-repeat/en repeat-ready at 1280, vi legacy-ready/en dry-repeat at 1920. Controls/countdown/notes fit; legacy first-target ripeness and actual repeat-target stages match the domain. Existing source world/icon artwork remains placeholders. No new mockup screenshot is a runtime asset.

Exact manifest, review commands, assumptions and manual F5 checklist are at the end of this document. API_INDEX/ARCHITECTURE/DATA_SCHEMA/D42/UI_LAYOUT/scene contracts/ROADMAP are current. Proposed commit: `feat: add repeat crop cycles and save v8 compatibility`.

## ISO-6a final automated acceptance (2026-11-03, D41)

Delivered: data-owned 2-day dry threshold, serialized care streak and exact remaining-day query; terminal withered guard (including ripe plants); one corrected outgoing-rain -> day simulation -> new-season/new-rain path; actual localized warning and cause-neutral withered text; save v7 preserving v1–v6 progress with unknown dry history default 0. Existing prices/growth/yields/IDs, 40-slot inventory, transactions, journal/guard, input/scenes/art and owner edit are retained. ISO-6b remains pending its specification; human editor acceptance remains pending. ISO-5 committed 67c63a2; ISO-6a is uncommitted, no push.

Real final output (Godot 4.7.2 / GUT 9.7.1; isolated APPDATA):

~~~text
[check_parse] OK
[validate_data] PASS

Official headless subset:
Totals
------
Scripts              16
Tests                62
Passing Tests        62
Asserts             853
Time              3.603s


---- All tests passed! ----

Focused care/save/weather/rollover headless:
Totals
------
Scripts               5
Tests                22
Passing Tests        22
Asserts             437
Time              6.696s


---- All tests passed! ----

COMPLETE graphics-renderer suite:
Totals
------
Scripts              67
Tests               221
Passing Tests       221
Asserts            7915
Time              79.168s


---- All tests passed! ----

[run_tests] starting main scene headless
[run_tests] PASS

Separate clean-render inspector/input suite:
Totals
------
Scripts               1
Tests                 5
Passing Tests         5
Asserts             219
Time              7.887s


---- All tests passed! ----
~~~

Final scans: zero SCRIPT ERROR / Parse Error / ERROR / resource-leak / orphan matches in official headless/full-renderer/main logs. Corrupted-data tests deliberately produce FarmGridState warnings (counter fallback/clamp, bad shape/row/coordinate/ID) and the retained InventoryState warning cases. No warning suppression, skipped tests or weakened acceptance. Existing save-version expectations deliberately change to 7; farm preservation compares every original field plus the new zero-care default. git diff --check PASS; all 41 ISO-6a files are inside the approved ALLOW_LIST; old goldens and item prices have no diff. FarmGridState is 245 lines; new test scripts are below 250 lines. gdtoolkit lint was not run because it is not installed; no packages installed.

Clean visual evidence: 18 captures in C:/Users/daova/AppData/Local/Temp/the_life_iso6a_review/iso6a_{vi,en}_{warning,ripe_warning,withered}_{1152,1280,1920}.png. Checked vi warning/en ripe warning at 1152; vi/en withered at 1280; vi ripe warning/en warning at 1920. Native controls/text remain within viewport; minimum-size expansion for long descriptions stays within tested bounds. The withered text no longer falsely attributes drought to season or asks for ineffective watering. Source world/icon art remains existing placeholders, not new final art.

Acceptance, exact file manifest/review command and F5 manual checklist appear in the ISO-6a handoff at the end of this document. No manual node/Inspector/InputMap edits required. Proposed commit: `feat: add daily crop care and save v7 migration`.

## ISO-5 final automated acceptance (2026-11-03)

All approved acceptance checks are automated and passing; human editor playtest remains pending. 41 created + 54 modified files, all inside the approved ALLOW_LIST; owner's master-plan change excluded. Every new inventory/domain/config/theme/test script is below 250 lines. No new autoload, source-art/old-golden changes, package installation, ISO-5 commit or push.

Real final output, Godot 4.7.2 / GUT 9.7.1, isolated APPDATA:

~~~text
[check_parse] OK
[validate_data] PASS

Official headless subset:
Totals
------
Scripts              16
Tests                62
Passing Tests        62
Asserts             853
Time              3.748s


---- All tests passed! ----

Focused inventory/migration headless:
Totals
------
Scripts               5
Tests                22
Passing Tests        22
Asserts             548
Time              21.28s


---- All tests passed! ----

COMPLETE graphics-renderer suite:
Totals
------
Scripts              64
Tests               206
Passing Tests       206
Asserts            7515
Time              71.804s


---- All tests passed! ----

[run_tests] starting main scene headless
[run_tests] PASS
~~~

Final error-text scan: zero SCRIPT ERROR/Parse Error/ERROR/resource-leak/orphan matches in official headless/full-renderer/main logs; intentional four InventoryState warnings come from malformed-data tests (invalid whole array retained, invalid row/unknown item/fractional quantity dropped). No warning suppression or test weakening. git diff --check PASS. Prior 3 orphan Label warnings are absent in this final run.

A separate clean renderer run of test_inventory_screen passed 6/6, 402 asserts (before the final one-assert current-tab click regression was added; that addition passed in the final headless/full runs above). It produced 36 vi/en captures for 1152×648, 1280×720, 1920×1080, covering empty/partial/full/filter/discard/journal. Clean copies are C:/Users/daova/AppData/Local/Temp/the_life_iso5_review/iso5_{vi,en}_{empty,partial,full,filter,discard,journal}_{1152,1280,1920}.png. Visually reviewed vi partial 1152, en full 1152, vi filter 1280, en discard 1280, vi partial 1920 and en journal 1920 against reference 06. All 40 default cells and fixed controls fit; original icons remain placeholders. Repeated current-tab clicks keep the active toggle selected.

Exact manifest, review commands and manual editor checklist are in the ISO-5 sections at the end of this document. API_INDEX/DATA_SCHEMA/ARCHITECTURE/INPUT_MAP/UI_LAYOUT/contracts/D40/ROADMAP are updated. Proposed commit: `feat: add modular forty-slot inventory and save v6 migration`. Do not mark human acceptance or advance ISO-6 on automation alone.
## ISO-6b1 approved plan — crop balance and repeat harvest (2026-11-03)

Owner approved the exact plan/ALLOW_LIST, table, 2-day repeat cycle, ceiling 80 and v8 compatibility via “Duyệt, commit ISO-6a và triển khai ISO-6b1”. ISO-6a is committed as 7f7a429 after validator PASS; no push. The following analysis is the approved pre-implementation record; current acceptance is reported above/below.

Approved findings/decisions:
- D35 supplies first growth carrot 3 / tomato 5 / turnip 4 / corn 7 and selected prices. DATA_SCHEMA §4 and the original master-plan starter table both show tomato regrow every 2 days; adopt 2 only if this proposal is approved. Keep the already requested yield 2 (D27), care threshold 2, IDs/seasons and all unrelated prices.
- There is no current fertilizer effect/item or house-level/upgrade domain. Original prompt §6 defers the house-upgrade screen. Recommended scope is 6b1 (growth/price/repeat harvest); fertilizer and corn house-level gating remain explicitly unfinished until their behavior and usable progression path are specified. Keep corn's current availability for this slice; never claim the house-level unlock is implemented. Do not add an inert shop item or unreachable fake upgrade.
- Current DataValidator requires slower-growing crops' seed/unit-sale prices to be no lower than every faster crop. Preserve this gate. The target changes require three additional, explicit price adjustments: tomato unit sale 70 -> 72 (existing 4-day cabbage sale 72); corn seed 28 -> 35 and unit sale 75 -> 100 (existing 5-day pumpkin seed/sale 35/100). Other unspecified prices stay unchanged.
- Repeat harvest plus existing yield 2 exceeds the historical starter-table 18 coins/plot-day example. That table explicitly describes starting examples, not verified current balance; existing shipped crops already exceed it after D27. Approval must choose an explicit current data-owned crop ceiling instead of pretending the old example passed. Proposed current-MVP ceiling: 80 coins/plot-day, checking first-cycle net return and repeat-cycle marginal return with integer cross multiplication. Tomato's repeat rate is 2*72/2 = 72; its ideal 28-watered-day net is 12*2*72-35 = 1693 per plot. This is a provisional cozy-game balance decision requiring owner approval and playtest, not a claim of final balance. No other economic/recipe cap is changed.

Proposed exact affected crop values (buy = seed purchase, sale = unit produce sale):

| Crop ID | First growth | Regrow | Seed buy | Produce sale | Yield per pick |
|---|---:|---:|---:|---:|---:|
| spring_carrot | 3 | 0 | 20 | 35 | 2 |
| summer_tomato | 5 | 2 | 35 | 72 | 2 |
| turnip | 4 | 0 | 25 | 45 | 2 |
| summer_corn | 7 | 0 | 35 | 100 | 2 |

The other five crops retain their existing values. Script-free read-only calculation over the current nine Resources verified these adjustments preserve the existing monotonic price gate. Forecast assumptions exclude missed care, travel, harvest timing delays, market saturation and other future systems; no such systems are invented.

MILESTONE: ISO-6, slice 6b1 — data balance, tomato repeat harvest, save v8. This does not complete fertilizer/house-unlock work or mark all ISO-6 accepted.
READ-ONLY CONTEXT: AGENTS/PROJECT_RULES; PROGRESS/API_INDEX/ARCHITECTURE/DATA_SCHEMA/CODE_PATTERNS; D27/D35/D41; original migration prompt §4–6 and master-plan starter table; gray_box_world/hud/inventory/day_end/ui_components contracts; existing tool/harvest/shop/bin/wallet/ledger/weather APIs and v1–v7 goldens.

Plan after approval:
1. Fresh DataValidator PASS, commit precisely ISO-6a's delivered 7-created/34-modified manifest (including current PROGRESS), excluding owner changes; message feat: add daily crop care and save v7 migration. No push. Human editor acceptance remains pending.
2. Apply the reviewed table in crop/item Resources only. CropData adds regrow_days (0 for single-harvest, 2 for tomato). Add CropEconomyConfig and data/crop_economy_config.tres for the explicitly proposed ceiling 80; validate positive values/durations/references, existing unit-price and monotonic rules, and initial/repeat profit rates. Small stateless CropEconomyRules receives Resource snapshots and uses integer arithmetic; tools/validate_data.gd includes the gate. Tests reject invalid/cap-breaking data; no guard/test is silently removed to make values pass.
3. FarmGridState continues to own every plot. Introduce small stateless CropCycleRules and FarmSaveCodec helpers to keep the existing 245-line owner small: codec extracts its current farm serialization/validation without changing care semantics; cycle helper supplies read-only target calculations. Add per-plot growth_target: int and regrowing: bool. New plants freeze their Resource first-growth target. A valid tomato harvest grants the existing yield once, retains the same plant, sets growth_days=0 / growth_target=2 / regrowing=true, and requires the next cared-for day boundaries. Harvest does not grant free water, reset drought or consume another seed. Other crops retain existing removal behavior. Full inventory blocks the whole action and leaves crop/cycle/care unchanged; no same-frame repeat harvest.
4. Use one existing DaySimulator path and retain ISO-6a dry/rain/season rules in every cycle. Withered plants never yield or regrow. FarmView and CropInspector query the owner for the actual target so visuals/countdown agree for first growth, legacy plants and regrowing plants. Inspector uses a real localized repeat-growth note, with no new screen, input action or UI-owned state. Existing tool controller receives only necessary compatibility wiring and physical-action regression coverage.
5. Save v8 adds growth_target/regrowing. Existing v1–v7 plots retain every original field and first-growth timing/ripeness by assigning their prior Resource durations, not the new longer durations. A data-only CropMigrationConfig Resource (data/crop_migration_v7.tres) contains the exact previous nine-crop durations: turnip2, carrot3, pea3, tomato4, corn4, wheat3, pumpkin5, radish3, cabbage4. No active gameplay duration is hardcoded in scripts. Existing plants keep these targets for their current first crop; newly planted crops use the new table; tomato regrows at 2 after a real harvest. Old raw growth numbers are not rewritten. Every old fixture stays read-only; add v8 golden with an active repeat cycle. Validate new fields safely; preserve inventory/wallet/weather/clock/profile/social/ledger/guard and atomic writes.
6. Test exact Resource table and economy ceiling/invariants; first and multiple repeat cycles; no premature/repeated grant; seed/care preservation; dry/rain/season/wither/full-inventory behavior; old mature/immature target preservation and v8 round-trip/corruption; real harvest/water inputs; vi/en three-size inspector states. Update the full-year test to use approved durations and explicitly clear retained withered plants before replanting, preserving the full 112-day/nonnegative-wallet/transaction invariants and adding repeated-pick coverage. Run focused headless, complete official renderer suite, parse/data/main, actual captures and honest docs/handoff.

Approved ISO-6b1 ALLOW_LIST (preceding ISO-6a commit uses its delivered manifest):
~~~text
scripts/data/crop_data.gd
scripts/data/crop_economy_config.{gd,gd.uid} (new)
scripts/data/crop_migration_config.{gd,gd.uid} (new)
data/crop_economy_config.tres (new)
data/crop_migration_v7.tres (new)
data/crops/*.tres (growth_days/regrow_days only; IDs/yields/seasons/care/art unchanged)
data/items/{spring_carrot_seed,spring_carrot,summer_tomato_seed,summer_tomato,turnip_seed,turnip,summer_corn_seed,summer_corn}.tres (only approved buy_price/sell_price values above)
scripts/domain/farm_grid_state.gd
scripts/domain/crop_cycle_rules.{gd,gd.uid} (new, stateless)
scripts/domain/farm_save_codec.{gd,gd.uid} (new, stateless)
scripts/domain/economy/crop_economy_rules.{gd,gd.uid} (new, stateless)
scripts/core/{data_validator,save_service}.gd
scripts/view/{main,farm_view,crop_inspector,tool_action_controller}.gd (cycle compatibility only)
localization/strings_{vi,en}.* (real repeat-growth descriptions only)
tools/validate_data.gd (crop economy/migration data gate)
tests/unit/** (affected crop/economy/transaction/input/save/layout regressions only)
tests/golden_saves/save_v8.json (new; v1–v7 read-only)
docs/{API_INDEX,ARCHITECTURE,DECISIONS,DATA_SCHEMA,PROGRESS,ROADMAP,UI_LAYOUT}.md
docs/PROJECT_RULES.md (migration-status notice only; no locked-rule deletion)
docs/SCENE_CONTRACTS/{gray_box_world,hud,inventory,day_end,ui_components}.md (actual cycle/readout/price compatibility only)
~~~

DO NOT TOUCH: all other files, all .tscn, InputMap, crop/item IDs, stack limits/yields/seasons, final/source art, old golden fixtures, NPC quote Resources and owner edits. No new autoload/bus signal/network call/house-upgrade/fertilizer item or unapproved package/commit/push.
ACCEPTANCE: approved table and data ceiling pass every retained/new validator; tomato first growth 5 then repeat every 2 cared-for days with exactly 2 produce once per ready cycle; no seed re-consumption/free water/drought reset; no full-bag loss or withered/off-season/regrow exploit; UI/readout matches domain; v1–v7 progress/ripeness and all prior fields preserved via legacy targets, v8 cycle round-trip; required automation passes and real output/manual checklist recorded. Human gates and remaining fertilizer/house-unlock work stay pending.
RISKS: proposed ceiling 80 is a deliberate replacement for historical crop examples and requires explicit approval; repeat crops can dominate income without later saturation/progression. Resource updates change future market quotes but not old inventory quantities/IDs. Snapshotting growth targets must keep views, codec, old goldens and year-simulation assumptions consistent. No behavior for fertilizer or house-level gating is inferred.

## ISO-6a approved task — daily crop care and save v7 (2026-11-03)

Owner explicitly approved this plan/ALLOW_LIST and the ISO-5 commit via “Duyệt, commit ISO-5 và triển khai ISO-6a”. Commit 67c63a2 records the delivered ISO-5 set after DataValidator PASS; no push. The following gap analysis is the pre-implementation baseline. ISO-6a source/tests are now implemented with automated acceptance recorded below.

Concrete gaps: FarmGridState only pauses growth when unwatered; it has no consecutive-dry-day counter. can_harvest does not reject a withered mature plot and water_cell can mark a withered crop watered. Main currently advances weather and waters with the NEW day's rain before simulating the finished day, contrary to ARCHITECTURE §5's finished-day weather order. CropInspector has real moisture/countdown but no impending-dryness warning. Existing saves cannot reconstruct past missed watering, so migration must initialize unknown dry history to zero.

Full ISO-6 still needs specification: D35 does not define tomato regrow interval, fertilizer effect or house-upgrade/unlock state. Applying its new growth/price samples also conflicts with the current DataValidator/test invariant that every slower crop must cost/sell at least as much as every faster crop (e.g. target 7-day corn keeps its unspecified existing seed price 28, below the existing 5-day pumpkin seed price 35). Do not silently change additional prices or remove the invariant to make tests pass. Proposed ISO-6a isolates the fully specified daily-care rule; growth/price migration, repeat harvest, fertilizer and house unlock stay ISO-6b pending a concrete balance/behavior decision. ISO-6 remains incomplete after 6a.

MILESTONE: ISO-6, slice 6a — daily crop care / withering / v7 persistence.
READ-ONLY CONTEXT: AGENTS.md; PROJECT_RULES; API_INDEX; ARCHITECTURE §5; D35/D40; DATA_SCHEMA/CODE_PATTERNS; gray_box_world/hud/day_end/inventory scene contracts; original migration prompt §4–6; existing weather/tool/harvest/transaction APIs and all v1–v6 goldens; existing ISO-5 manifest.

Plan after approval:
1. Fresh DataValidator PASS, then commit exactly the delivered ISO-5 manifest (41 created + 54 modified files including current PROGRESS), excluding the owner edit. Message: feat: add modular forty-slot inventory and save v6 migration. No push. Human editor acceptance remains pending; do not mark it passed.
2. Add a typed max_consecutive_dry_days field to CropData, configured to 2 in the nine existing crop Resources. Add per-plot consecutive_dry_days owned by FarmGridState. One missed eligible watering day pauses growth and warns; watering/rain resets the counter; reaching the configured threshold withers the plant. Apply care to existing planted crops, including ripe plants left in soil; already-withered plants never revive or yield. Preserve existing yield/IDs/seasons/growth/prices and full-inventory atomicity. CropData's water_need=0, if used, must not accumulate dry days.
3. Keep one existing GameClock.day_started -> Main -> DaySimulator path. Account for the finished day's stored water/rain before advancing to tomorrow's weather; then apply season transition and tomorrow's rain to its morning plots. Test dry→rain and rain→dry boundaries explicitly, so tomorrow's rain cannot undo the just-finished second dry day. Keep bed/manual/cutoff/direct-rollover equivalence, locks and guarded summary behavior.
4. CropInspector displays the actual remaining dry-day warning through vi/en translation keys. Existing farm view/summary read the real withered flag; no new scene, InputMap action, HUD system, autoload, signal bus entry or view-owned care state. UI remains small modules.
5. Save version 7 adds consecutive_dry_days. Deep-copy v6→v7 migration initializes absent counters to zero (no invented dry history), preserving watered/withered/growth/crop/cell and all inventory/wallet/clock/ledger/guard/profile/social state. Older fixtures remain read-only; add v7 golden. Validate/clamp malformed new fields and unknown crops safely without a broad unrelated save rewrite.
6. Test dry/water/rain resets, threshold exactly once, no growth/harvest/revival after withering, ripe crop handling, water-free data, out-of-season behavior, full inventory, real input/clock/sleep/modal interactions, v1–v6 preservation and v7 round-trip/corruption, three-size vi/en inspector warnings. Run focused headless, parse/data, full official renderer suite and main smoke; paste actual output, exact manifest/diff and manual checklist into PROGRESS/API/docs.

Approved ISO-6a ALLOW_LIST (ISO-5 commit uses its delivered manifest):
~~~text
scripts/data/crop_data.gd
scripts/domain/farm_grid_state.gd
scripts/domain/day_simulator.gd
scripts/core/data_validator.gd
scripts/core/save_service.gd
scripts/view/main.gd
scripts/view/crop_inspector.gd
data/crops/*.tres (new care-threshold field only; growth/yield/seasons/ids/colors untouched)
localization/strings_{vi,en}.* (crop-care warnings only)
tests/unit/** (affected crop/day/weather/harvest/save/UI regressions only)
tests/golden_saves/save_v7.json (new; v1–v6 read-only)
docs/{API_INDEX,ARCHITECTURE,DECISIONS,DATA_SCHEMA,PROGRESS,ROADMAP,UI_LAYOUT}.md
docs/PROJECT_RULES.md (migration-status notice only)
docs/SCENE_CONTRACTS/{gray_box_world,hud,day_end}.md (crop-care/readout contracts only)
~~~

DO NOT TOUCH: everything else, including all .tscn, InputMap, prices/item Resources, original art, old golden files and owner edits. Any extra helper/file requires scope approval before editing.
ACCEPTANCE: threshold from Resource, two consecutive missed care days wither exactly once, real warning after first, rain/water reset only in the correct day, no withered harvest/revival, one daily simulation path, old save preservation/new counter round-trip, existing 40-slot inventory/tool/economy/day-end behavior retained, all required automation pass. No claim that ISO-6b or human editor playtest is complete.
RISKS: correcting finished-day weather order changes existing rain-boundary behavior and needs regression tests; old unknown care history must not retroactively punish players; no arbitrary balance/regrow/upgrade/fertilizer behavior is inferred. Baseline tests are ISO-5's recorded 206/206 renderer plus current fresh validator PASS; no new runtime test is claimed for this proposal.

## ISO-5 approved plan — modular inventory and supported tab shell (2026-11-03)

Owner approved this plan and ALLOW_LIST via “Duyệt, commit ISO-4 và triển khai ISO-5”. The following gap analysis is the pre-implementation baseline; current delivery and real test output are recorded above/below.

Pre-implementation gaps: InventoryState defaulted to 12 and persists compact item stacks; ItemData has IDs/prices/stack/visual metadata but no category/description/edible effect. No stamina/eating or storage/chest domain exists. The mockup's “Cất vào ô” can be represented truthfully by selecting a real stack on the existing toolbar, not by pretending a chest exists. Existing journal provides working quest content; character/calendar/map screens are not yet implemented. The supplied image has 8 columns and visually fewer occupied/display rows, while the explicit prompt requires 8×5 / 40: follow the explicit 40-slot requirement and the image's layout/style.

Plan:
1. Commit only delivered ISO-4 files after validator PASS. Preserve the owner edit. Keep ISO-5 as a separate milestone/commit; no push.
2. Add data-owned inventory configuration (40 default slots, eight columns/five visible rows), item category and optional localized description metadata. Populate only metadata on current item Resources; prices, stack limits and IDs remain unchanged. Tool/material filters may truthfully be empty; do not inject HUD tool capabilities into inventory as fake item stacks.
3. Build ui/inventory from small separate scene/script classes: common five-tab header/shell, filter bar, eight-column grid/slot, detail card, capacity/footer, discard quantity/confirmation, presenter and controller. Reuse shared Theme/ISO-2 components. Follow reference 06's wood/paper frame, top tabs, left filters/grid, right selected detail/real sale price and fixed footer. Default grid is 40 slots; legacy capacity above 40 remains usable through extra scrolling rows rather than dropping items.
4. Implement stateless InventoryActions and narrow typed owner APIs for validated sort/discard. Quantity/selected-stack identity is checked again at execution; stale/full/invalid operations do not change inventory. Sort preserves every item/quantity and remaps active selection; discard affects only the selected stack after a quantity confirmation. Keep InventoryPanel's public modal/select signals and existing toolbar/farming APIs. Quick selection uses the existing toolbar selection behavior; do not promise storage transfer or fixed slot reassignment.
5. Shell shows five reference tabs, but only Bag and the existing Quest journal are enabled. Character/Calendar/Map are disabled/unavailable, with no fake screens or data. Reuse the same shell/header for supported views, retaining Main's existing public paths. Q/E cycle supported tabs only and consume input before world interaction/placement. B/I/Tab/J/Escape remain compatible. F quick-selects the highlighted real stack; Z sorts only while inventory is open. Eating is hidden/disabled because no edible/stamina effect exists; no effect numbers are invented. Prices are actual sell_price, no fake quality/market bonus.
6. Explicit save v6 migration v5 -> v6 raises old player inventory capacity to at least the configured 40 while preserving larger capacities, slot order, IDs, quantities and all ledger/day-end/clock/farm/profile/social data. Preserve old fixtures v1–v5; add a v6 golden. Constructor tests with an explicitly small capacity stay meaningful. Invalid external item/capacity/quantity payloads must be handled without silent loss of valid contents or crashes.
7. Test old saves/full inventory/stack limits, sorting multiset/selection, stale discard and quantity validation, exact action count, no wallet/journal changes from selection, physical grid/filter/detail/buttons, Q/E/F/Z context and modal/day-end suppression. Run parse/data/headless/full renderer/main checks, and compare actual three-size vi/en captures with reference 06. Keep documentation/API/schema/scene contracts current and provide manual editor steps.

Approved new contextual InputMap actions: inventory_tab_prev=Q, inventory_tab_next=E, inventory_quick_select=F, inventory_sort=Z. Existing world interact=E and rotate_ccw=Q remain; new actions are modal-only. “Quick select” is deliberately the supported toolbar operation, not an unimplemented chest/storage action.

Approved ISO-5 ALLOW_LIST:
```text
ui/inventory/**
ui/components/**
ui/theme/**
scripts/data/{inventory_config,item_data}.gd
scripts/data/inventory_config.gd.uid
data/inventory_config.tres
data/items/*.tres (category/description metadata only; no price/stack/id changes)
scripts/domain/inventory_state.gd
scripts/domain/inventory_actions.{gd,gd.uid}
scripts/core/{save_service,data_validator}.gd
scripts/view/{inventory_panel,main,hotbar_panel,ui_coordinator,ui_layout,npc_panel,npc_system,chibi_ui_motion}.gd
scenes/main/main.tscn
project.godot (only the four contextual actions above)
tools/validate_data.gd (inventory config/metadata gate only)
localization/strings_{vi,en}.*
tests/unit/** (only affected inventory/save/UI/input/transaction regressions)
tests/golden_saves/save_v6.json (new only; v1–v5 fixtures read-only)
docs/{API_INDEX,ARCHITECTURE,DECISIONS,DATA_SCHEMA,PROGRESS,ROADMAP,UI_LAYOUT,INPUT_MAP}.md
docs/PROJECT_RULES.md (migration-status notice only; no locked-rule changes)
docs/SCENE_CONTRACTS/{inventory,hud,ui_components}.md
```

Read-only context: reference 06/shared kit, original prompt, current public inventory/item/clock/day-end/save/toolbar/NPC-journal APIs and contracts, item Resources, input/style rules. Everything else, world scenes, crop/economy balance, stamina/eating/storage/calendar/map systems and old save fixtures are outside scope. No rename/removal of existing public IDs/signals/methods or new autoload is proposed.

Acceptance proposed: small modular classes and reference-06 composition; default 40 slots in eight columns; metadata-driven filters/details; supported selection/sort/discard are validated and lossless apart from explicit confirmed discard; unavailable actions/tabs stay unavailable; contextual Q/E/F/Z cannot trigger world input; v1–v5 contents and larger inventories survive v6 migration; toolbar/day-end/merchant behavior stays working; all official checks pass with real vi/en three-size render review. Human editor acceptance and commits remain explicit milestones.

## ISO-4 handoff — day-end report and save v5 (2026-11-03)

Acceptance delivered:
- Small pure journal/guard domain classes and nine UI/application helpers, five scene wrappers, plus an isolated Theme builder extension. New UI scripts are 14–114 lines. Reference 13's wood/paper two-column sheet, blue title, real ledger/totals, actual next-day forecast/tutorial progress, warning, green next-day and manual return controls are composed from native Controls.
- Actual integer cash deltas/reasons drive income/expense/net. Refund/minh_rollback reduce expenses; optional successful trade item/quantity metadata does not count cash twice. Failed purchases do not add entries. Starting wallet/load notifications are excluded. Old or corrupt history is marked incomplete instead of reported as known zero.
- Legal bedtime interaction opens manual review; 02:00 opens forced review. Review holds clock/input and cannot be bypassed by raw minute advance, modal switching or repeated confirms. Manual Stay/Escape returns without simulation; forced review has no Stay and cannot dismiss. Exactly one existing DaySimulator path runs; completed state and tutorial sleep event are captured by morning autosave.
- Save v5 persists journal/review guard, resumes manual/forced review and preserves v1–v4 fixture data. Direct/manual/forced three-night farm/weather/clock/wallet/inventory results match. Newest-save precision/tie handling is fixed so Continue selects the completed morning over its old review. Deliberately loading an older save restores that older timeline normally.
- Native mouse/keyboard/modal, double/re-entrant confirm, safe-save, refund, copies, malformed new fields, old/golden migration, hidden/visible locale refresh and three-size layout/render checks pass. Main parse/data/headless/full renderer/main smoke pass; reference PNGs and old golden files are unchanged.

Clear implementation diff:
- Added scripts/domain/economy/day_ledger_state.gd and scripts/domain/day_end_state.gd with immediate serialize/deserialize. Added ui/day_end scene/script components, separate presenter/flow/formatting/weather-symbol helpers and ui/theme/day_end_theme.gd; generated shared Theme includes their variations.
- Main wires day_end_flow and stores day_ledger/day_end, resets/restores them with new/load, routes day_started through the existing simulator, and suppresses mid-sleep/rollover writes. GrayBoxWorld emits a local bed request; GameClock adds an optional review hold/cutoff signal without removing old low-level APIs. No new event-bus action/autoload/input binding is added.
- UiCoordinator registers/locks the summary, supports native focus/clicks, blocks switching behind it and limits Escape to manual cancellation. UiLayout supplies responsive sheet bounds, ChibiUiMotion includes the sheet. Other UI/world roots and public paths remain intact.
- SaveService writes v5/migrates v4 history explicitly, preserves subsecond latest-save timestamps and resolves exact-time ties by saved day. Existing tests expecting the current save version now expect 5; all previous preservation assertions remain. New tests add actual state/behavior checks rather than replacing gameplay tests.
- Added 25 localization keys per language, D39, schema/API/architecture/UI/scene contracts and milestone memory. PROJECT_RULES changes only its stale migration-status notice under the approved exception; locked rules remain unchanged. The owner master-plan blank line stays separate. No crop price/growth, inventory capacity, existing world scene, InputMap or third-party asset changes.

Manual editor steps and tests (owner still needs to run):
1. Open in Godot 4.7.2 and let import finish. No manual scene/Inspector wiring is required: Main constructs the new sheet from its scene wrapper and registers it with the existing modal owner. Keep scenes/main/main.tscn as the main scene; F5, New/Continue, dismiss help.
2. Make a seed purchase and sale through the existing UI. At 20:00 or later, approach home and E to review. Use existing debug time control if needed. Confirm rows/quantities match actual transactions, total income/expense/net match cash changes, forecast matches saved tomorrow weather and planted/unwatered plots produce a truthful warning. No XP/stamina/event numbers should appear.
3. Click Stay or Esc: clock/day/crops/coins stay unchanged and movement resumes. Reopen and click next-day twice quickly: the day increments once, crops/weather use the existing simulation once, morning is 06:00 and sleep tutorial completion is saved. Try inventory/journal/pause shortcuts and world clicks during review; none may switch or act underneath.
4. Reach 02:00 without sleeping: forced summary has no Stay, Escape cannot dismiss it, and confirm advances once. Close/restart while reviewing both manual and forced cases; Continue must reopen the same held review. After confirming and restarting, Continue must show the new morning, never replay the previous night.
5. Load an older save: wallet/inventory/farm/social/profile remain; today's report labels history incomplete. After the next day its fresh journal is complete. Test vi/en by changing existing Settings language while the sheet is closed, and check both locales at 1152×648, 1280×720 and 1920×1080 against docs/ui_reference/13-ket-thuc-ngay.png. Ledger scrolls; action buttons stay visible. Final art is still replaceable placeholder code/SVG, not the finished mockup texture.

Run from project root:
```powershell
$env:GODOT = 'D:\godot\Godot_v4.7.2-stable_win64_console.exe'
& .\tools\run_tests.bat
# New ISO-4 behavior/domain/save/layout checks without renderer captures:
powershell -NoProfile -ExecutionPolicy Bypass -File tools/run_godot_bounded.ps1 -Godot $env:GODOT -Arguments '--headless --path . --script addons/gut/gut_cmdln.gd -gtest=res://tests/unit/test_day_ledger_state.gd,res://tests/unit/test_day_end_flow.gd,res://tests/unit/test_day_end_save.gd,res://tests/unit/test_day_end_rollover.gd,res://tests/unit/test_day_end_layout.gd -gexit' -OutputPath "$env:TEMP\the_life_iso4_focus_final.log"
```

Real output, 2026-11-03 (summary excerpts, ANSI colors removed):
```text
[validate_data] PASS  (before ISO-3 commit)
[master 8706dfb] feat: compose modular isometric HUD from mockup references
[check_parse] OK
[validate_data] PASS
[run_tests] running domain and 2D headless tests
Scripts              16
Tests                62
Passing Tests        62
Asserts             849
Time              2.741s
---- All tests passed! ----
[run_tests] running COMPLETE GUT suite with graphics renderer
Scripts              62
Tests               195
Passing Tests       195
Asserts            6894
Time              38.708s
---- All tests passed! ----
[run_tests] starting main scene headless
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org
[run_tests] PASS
Focused ISO-4 headless:
Scripts               5
Tests                17
Passing Tests        17
Asserts             381
Time              4.447s
---- All tests passed! ----
```

Logs: %TEMP%/the_life_{headless,gut,main,validate}.log.{stdout,stderr}; focused log the_life_iso4_focus_final.log; final editor import exits 0 (the_life_iso4_final_import.log). The same three pre-existing GUT orphan Labels remain (inventory UI two, pause menu one); no new engine errors/warnings or persistent new orphans. No test was skipped/weakened, no package installed. Final English warning copy edit is followed by the dedicated renderer layout/capture check; no behavior changes follow the full runner.

Render artifacts: %TEMP%/the_life_test_appdata/Godot/app_userdata/game godot/iso4_{vi,en}_{manual,partial,forced}_{1152,1280,1920}.png (18 PNGs). Visual review compared actual vi/1152 manual, en/1152 incomplete, final vi/1152 forced/rain and en/1920 manual to reference 13. Every locale/size/state has bounds/column/no-horizontal-overflow assertions. Captures use isolated test transactions through real services; these example funds are never injected into normal gameplay. Existing cursor at upper-left may appear in captures independently of the sheet.

Assumptions/known limits:
- UI assets are code/SVG placeholders with replaceable wood/paper/weather symbols. No XP, stamina, birthday/festival or numerical reward system is invented. Current tutorial offers real completed/7; warning reads current watered/withered plot flags without inventing a wither countdown. Existing growth/weather ordering is preserved for later ISO-6 work.
- Legacy saves have no reconstructible past journal; incomplete-history note persists for that day. Journal corruption/integrity bounds can also mark it incomplete. Reporting does not change wallet or enforce new gameplay limits. Unknown item metadata displays localized generic cash reasons. Existing validation of unrelated legacy payload fields is not expanded by this task.
- Low-level try_sleep keeps its old accelerated behavior. The new application confirm uses the existing immediate sleep_to_morning path with sleep notifications and one final safe autosave. An older snapshot intentionally restores its older timeline; replay protection is within the restored state, not anti-rollback storage outside saves.
- Atomic saving remains the existing SaveService implementation; disk/hardware failure injection was not performed. Hardware/manual gameplay acceptance and Gates remain pending. ISO-4 is not committed/pushed; only ISO-3 was explicitly committed. Suggested commit: feat: add modular day-end summary and resumable daily ledger.

Exact ISO-4 files created/modified (including Godot UID metadata):

```text
docs/API_INDEX.md
docs/ARCHITECTURE.md
docs/DATA_SCHEMA.md
docs/DECISIONS.md
docs/PROGRESS.md
docs/PROJECT_RULES.md
docs/ROADMAP.md
docs/SCENE_CONTRACTS/day_end.md
docs/SCENE_CONTRACTS/gray_box_world.md
docs/SCENE_CONTRACTS/hud.md
docs/UI_LAYOUT.md
localization/strings_en.csv
localization/strings_vi.csv
scripts/core/game_clock.gd
scripts/core/save_service.gd
scripts/domain/day_end_state.gd
scripts/domain/day_end_state.gd.uid
scripts/domain/economy/day_ledger_state.gd
scripts/domain/economy/day_ledger_state.gd.uid
scripts/view/chibi_ui_motion.gd
scripts/view/gray_box_world.gd
scripts/view/main.gd
scripts/view/ui_coordinator.gd
scripts/view/ui_layout.gd
tests/golden_saves/save_v5.json
tests/unit/test_day_end_flow.gd
tests/unit/test_day_end_flow.gd.uid
tests/unit/test_day_end_layout.gd
tests/unit/test_day_end_layout.gd.uid
tests/unit/test_day_end_rollover.gd
tests/unit/test_day_end_rollover.gd.uid
tests/unit/test_day_end_save.gd
tests/unit/test_day_end_save.gd.uid
tests/unit/test_day_ledger_state.gd
tests/unit/test_day_ledger_state.gd.uid
tests/unit/test_npc_social_save.gd
tests/unit/test_save_service.gd
tests/unit/test_weather.gd
ui/day_end/day_end_flow.gd
ui/day_end/day_end_flow.gd.uid
ui/day_end/day_end_parts.gd
ui/day_end/day_end_parts.gd.uid
ui/day_end/day_end_presenter.gd
ui/day_end/day_end_presenter.gd.uid
ui/day_end/day_end_sheet.gd
ui/day_end/day_end_sheet.gd.uid
ui/day_end/day_end_sheet.tscn
ui/day_end/farm_warning.gd
ui/day_end/farm_warning.gd.uid
ui/day_end/farm_warning.tscn
ui/day_end/ledger_row.gd
ui/day_end/ledger_row.gd.uid
ui/day_end/ledger_row.tscn
ui/day_end/ledger_view.gd
ui/day_end/ledger_view.gd.uid
ui/day_end/ledger_view.tscn
ui/day_end/tomorrow_card.gd
ui/day_end/tomorrow_card.gd.uid
ui/day_end/tomorrow_card.tscn
ui/day_end/weather_symbol.gd
ui/day_end/weather_symbol.gd.uid
ui/theme/day_end_theme.gd
ui/theme/day_end_theme.gd.uid
ui/theme/the_life_theme.tres
ui/theme/theme_factory.gd
```

## ISO-4 approved plan — day-end summary and sleep flow (2026-11-03)

Owner said “oke tiếp tục”, reviewed this plan, then explicitly approved commit ISO-3 and implement ISO-4. The delivered 65-file ISO-3 set was committed as 8706dfb after a fresh validator PASS, excluding the owner's master-plan edit. The following scope is approved; D39 records implementation choices and safe-save boundaries.

Pre-ISO-4 findings: WalletState serialized only coins and emitted signed deltas/reasons, with no daily journal. Shop/NPC paths contain refund/rollback changes, so counting all positive deltas as income would be wrong. SaveService wrote v4 and whitelisted top-level payloads. Clock cutoff rolled immediately while bed interaction called try_sleep; review needed a coordinated pre-rollover decision. The implementation below preserves DaySimulator as the sole farm simulation path.

Plan:
1. Add pure small day-ledger/day-end state classes with serialize/deserialize from their first implementation. Track real integer money changes by day/reason and available successful trade metadata, reverse refunds/rollbacks correctly, exclude load/starting balance from income, and compute income minus expense. Keep wallet/trade services authoritative; the report never changes coins. Old saves without history are marked incomplete rather than inventing past zero revenue.
2. Add separate small summary scene/script components under ui/day_end: main sheet, ledger row/list, totals, tomorrow/weather preview and unwatered warning, plus a presenter and flow coordinator. Reuse the shared Theme/HUD parts. Follow reference 13's two-column paper/wood layout with blue heading, real financial rows, green next-day button and manual return option. Hide XP/stamina/calendar-event cards without supporting state; do not load mockup PNGs as assets.
3. Route manual bed requests and automatic clock cutoff through one guarded review/confirm/rollover flow. Preserve existing low-level clock APIs and the existing day_started -> DaySimulator/autosave path; no second growth/weather path. One confirmed next-day action, no double simulation, world/menu locking while reviewing/rolling, manual stay option only before forced cutoff.
4. Save the ledger and resumable day-end review state with an explicit v5 schema/migrate_4_to_5 and a new golden v5 sample; preserve v1–v4 fixtures and all previous payloads. Handle old/malformed history safely. Saving/loading a review or repeating the confirm action must not advance a day twice. Only save at safe boundaries, not halfway through rollover.
5. Add meaningful ledger/refund/serialization/migration/corruption tests; manual versus cutoff/repeated sleep equivalence; double-click/modal/input tests; vi/en three-size renderer captures compared with reference 13. Run parse/data/headless/full renderer/main checks; update APIs/contracts/schema/progress and give manual editor steps.

Approved ALLOW_LIST:
```text
scripts/domain/economy/day_ledger_state.{gd,gd.uid}
scripts/domain/day_end_state.{gd,gd.uid}
ui/day_end/**
ui/theme/**
scripts/core/{game_clock,save_service}.gd
scripts/view/{main,gray_box_world,ui_coordinator,ui_layout,chibi_ui_motion}.gd
scenes/main/main.tscn
localization/strings_{vi,en}.*
tests/unit/** (only day-end/accounting/save/clock/modal regressions affected by ISO-4)
tests/golden_saves/save_v5.json (new only; older fixtures read-only)
docs/{API_INDEX,ARCHITECTURE,DECISIONS,DATA_SCHEMA,PROGRESS,ROADMAP,UI_LAYOUT}.md
docs/PROJECT_RULES.md (migration-status notice only; no locked rule changes)
docs/SCENE_CONTRACTS/{day_end,gray_box_world,hud}.md
```

Read-only context: reference 13 and shared UI kit, existing wallet/merchant/shop/bin APIs, current GameClock/DaySimulator/farm moisture/save/golden APIs, existing world/player/HUD contracts and style/input rules. All other files, crop prices/growth, inventory capacity, world scene resources, InputMap/autoloads and old save fixtures remain outside scope. PROJECT_RULES' migration notice still says ISO-2 onward are planned; update only that stale status to agree with D37/D38 as part of D39, not the project laws.

Acceptance: small focused classes; reference 13 layout at three sizes in vi/en; correct real income/expense/net including rollback handling; truthful unwatered warning/current forecast; one simulation per accepted day-end action; cancel only where allowed; modal lock; save v5 resume and v1–v4 migration with preserved data; repeated/direct rollover equivalence; all official checks pass; honest render review and manual handoff. New economy features, balance changes, XP/stamina/calendar events and other mockup screens are not included.

## ISO-3 handoff — small HUD classes and mockup layout (2026-11-03)

Acceptance delivered:
- Thirteen focused classes under `ui/hud/`, each 18–69 lines, separate root/binding/layout/decoration and clock/quest/toolbar/shortcut/toast responsibilities. Nine reusable scene wrappers. Existing Theme remains shared; Main adds wiring and toast delegation rather than HUD construction logic.
- Reference 03/04 regions are now active: upper-left pinned quest paper, upper-right wooden clock/weather/wallet, bottom-center eight-slot toolbar/caption, bottom-left supported round buttons and up to two timed result messages. Day/night/rain tint stays world-only. Actual render images were compared with the supplied references.
- Clock/day/season/year/weather/forecast/coins/inventory/tutorial completion come from existing state. Three tools plus five real inventory stacks are visible; selecting any inventory index moves the display window. 1–3 are hoe/water/harvest, 4–8 current inventory window, 9 legacy ninth stack. B/I/Tab/J/H/Escape operate supported screens; no unsupported K/M/Q/E bindings are added.
- Physical native mouse and keyboard tests cover tool/item selection, legacy 9, modal input lock, round buttons, actual-state updates and max-two/expiry toast behavior. Three sizes and vi/en are checked, with 18 day/night/rain captures. Existing farming/drag/crop-inspection/merchant/social/save/old-golden regressions remain in the full suite.

Clear diff summary:
- Added modular HUD views/helpers and scene contract. Main wires LifeHudPresenter; UiLayout delegates anchors to LifeHudRegions. QuestPanel/HotbarPanel/HudButtonBar adapt existing APIs into the new views. Main's direct node paths, legacy hotbar child paths and old Label text APIs remain queryable; obsolete visual surfaces are hidden.
- Added shared HUD Theme variations and regenerated the Theme. Code-drawn wood grain/studs/sun/moon/rain and existing SVG tool/round/coin artwork are replaceable view assets. No reference image is loaded at runtime.
- Main save, feedback/item-gain and actual quest completion messages feed a single max-two, 3-second view-only stack. Timer callbacks defer safe card removal; there are no new orphan warnings in the final run. Existing three GUT orphan Labels remain as before (two inventory UI, one pause menu).
- Updated 15 localization keys per language, B inventory binding and the documented-but-previously-absent Tab alias; open_build remains unbound with its ID preserved. Existing I remains. No domain/data/save/world scene/autoload changes.
- Existing tests asserting C4 geometry, first-inventory key 1 or legacy weather Label visibility now assert the approved eight-slot geometry/key 4 and live weather card. Onboarding verifies InputMap's new primary B hint. No gameplay expectation was removed; weather also checks actual rain/card visibility. Fixed container minimum-height overflow, overlapping sun arc and quest/crop card positioning found by tests/render review. Crop detail uses a centered map card and hides the interaction prompt while open.

Manual editor steps and acceptance (owner still needs to run):
1. Open in Godot 4.7.2 and allow import. No manual node/Inspector wiring is needed: source constructs small container-based views from the new scene wrappers. Keep `scenes/main/main.tscn` as main; F5, New/Continue, close first-run help.
2. Compare HUD with references `03-trong-game-ban-ngay.png` / `04-trong-game-dem-mua.png`: pinned paper upper left, wood clock/coins upper right, eight bottom-center slots and bottom-left round shortcuts/toasts. The farm/characters remain ISO-1 placeholders. Change window to 1152×648, 1280×720 and 1920×1080; try vi/en through existing Settings. Check accented text and no clipped/overlapping controls.
3. Press 1/2/3 and click the tool icons, select real seed stacks with 4–8, select later inventory stacks in InventoryPanel, and try legacy 9 when a ninth stack exists. Farm with the selected seed/water/harvest action; quantities must change only through successful existing actions.
4. Open inventory with B, I and Tab; J opens journal, H help, Esc pause/close. Click their round buttons. Verify only one modal opens, toolbar disappears, movement/world clicks stay locked, and movement resumes after closing. Existing shop/dialogue/transactions/help remain reachable.
5. Inspect a crop and confirm the centered readable detail card avoids quest/toolbar, with the underlying prompt suppressed. Generate item/quest/save messages, verify maximum two toasts and expiry. Use existing debug time/weather controls for day/night/rain; HUD stays readable, world changes correctly. Save/load, sleep and Continue retain actual inventory/coins/day/profile.

Run from project root:
```powershell
$env:GODOT = 'D:\godot\Godot_v4.7.2-stable_win64_console.exe'
& .\tools\run_tests.bat
# Focused headless HUD behavior and layout checks:
powershell -NoProfile -ExecutionPolicy Bypass -File tools/run_godot_bounded.ps1 -Godot $env:GODOT -Arguments '--headless --path . --script addons/gut/gut_cmdln.gd -gtest=res://tests/unit/test_isometric_hud.gd -gexit' -OutputPath "$env:TEMP\the_life_iso3_focus.log"
```

Real final official output, 2026-11-03 (summary excerpts, ANSI colors removed):
```text
[check_parse] OK
[validate_data] PASS
[run_tests] running domain and 2D headless tests
Scripts              16
Tests                62
Passing Tests        62
Asserts             849
Time              3.12s
---- All tests passed! ----
[run_tests] running COMPLETE GUT suite with graphics renderer
Scripts              57
Tests               178
Passing Tests       178
Asserts            6495
Time              35.895s
---- All tests passed! ----
[run_tests] starting main scene headless
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org
[run_tests] PASS
```

Logs: `%TEMP%\the_life_{headless,gut,main,validate}.log.{stdout,stderr}`. Final editor import exits 0 (`the_life_iso3_final_import.log.{stdout,stderr}`). No new engine errors/warnings; same pre-existing three orphan Labels as ISO-1/2. New five-test HUD script passes within the final 178-test run. No tests were skipped or weakened and no packages were installed.

Render artifacts: `%TEMP%\the_life_test_appdata\Godot\app_userdata\game godot\iso3_{vi,en}_{day,night,rain}_{1152,1280,1920}.png` (18 PNGs). Visually inspected vi/1152 day and rain while iterating, then final vi/1152 day and en/1920 rain, plus the existing crop/modal capture regressions generated by the full suite. Region bounds/overlap are asserted for every locale/size/mode. Automated captures may show the existing cursor at the upper-left; it is separate from HUD decoration.

Assumptions and known limits:
- Placeholder frames/icons and existing ISO-1 world art do not reproduce finished illustration textures. Source/reference PNGs stay unchanged and are not runtime assets. Future supplied art can replace these views/styles without changing gameplay.
- No stamina, calendar event, map/calendar screen, water-capacity/tool-level, numerical quest target or reward data was invented. Current tutorial supports completion booleans, so it displays actual completed/7 and three relevant steps. Those explicit differences from the mockups remain until corresponding domain tasks are approved.
- A missing documented Tab default was found and supplied as part of approved B/I/Tab behavior; no new action ID was introduced. Existing slot 9 remains compatible and inventory capacity/save v4 remain unchanged. Store/sort/pin operations and Q/E tabs are later milestones.
- Human editor playtest/Gates remain pending. No ISO-3 commit/push was made. Suggested commit: `feat: compose modular isometric HUD from mockup references`.

Exact ISO-3 files created/modified (including Godot UID metadata):

```text
docs/API_INDEX.md
docs/ARCHITECTURE.md
docs/DECISIONS.md
docs/INPUT_MAP.md
docs/PROGRESS.md
docs/ROADMAP.md
docs/SCENE_CONTRACTS/gray_box_world.md
docs/SCENE_CONTRACTS/hud.md
docs/SCENE_CONTRACTS/ui_components.md
docs/UI_LAYOUT.md
localization/strings_en.csv
localization/strings_vi.csv
project.godot
scripts/view/feedback_popup.gd
scripts/view/hotbar_panel.gd
scripts/view/hud_button_bar.gd
scripts/view/main.gd
scripts/view/quest_panel.gd
scripts/view/ui_coordinator.gd
scripts/view/ui_layout.gd
tests/unit/test_chibi_ui.gd
tests/unit/test_hotbar_layout.gd
tests/unit/test_isometric_hud.gd
tests/unit/test_isometric_hud.gd.uid
tests/unit/test_onboarding.gd
tests/unit/test_ui_layout.gd
tests/unit/test_ui_mouse.gd
tests/unit/test_weather.gd
ui/hud/clock_arc.gd
ui/hud/clock_arc.gd.uid
ui/hud/clock_arc.tscn
ui/hud/clock_card.gd
ui/hud/clock_card.gd.uid
ui/hud/clock_card.tscn
ui/hud/hud_frame.gd
ui/hud/hud_frame.gd.uid
ui/hud/hud_parts.gd
ui/hud/hud_parts.gd.uid
ui/hud/hud_presenter.gd
ui/hud/hud_presenter.gd.uid
ui/hud/hud_regions.gd
ui/hud/hud_regions.gd.uid
ui/hud/hud_root.gd
ui/hud/hud_root.gd.uid
ui/hud/hud_root.tscn
ui/hud/quest_card.gd
ui/hud/quest_card.gd.uid
ui/hud/quest_card.tscn
ui/hud/shortcut_bar.gd
ui/hud/shortcut_bar.gd.uid
ui/hud/shortcut_bar.tscn
ui/hud/toast_card.gd
ui/hud/toast_card.gd.uid
ui/hud/toast_card.tscn
ui/hud/toast_stack.gd
ui/hud/toast_stack.gd.uid
ui/hud/toast_stack.tscn
ui/hud/toolbar.gd
ui/hud/toolbar.gd.uid
ui/hud/toolbar.tscn
ui/hud/toolbar_slot.gd
ui/hud/toolbar_slot.gd.uid
ui/hud/toolbar_slot.tscn
ui/theme/the_life_theme.tres
ui/theme/theme_factory.gd
```

## ISO-3 approved plan — modular HUD matching references 03/04

Owner request: commit ISO-2 and continue, splitting UI into small classes and matching the supplied reference images. Read-only review completed: reference PNGs 03/04, ROADMAP, D33–D37, INPUT_MAP, active view APIs and gray_box_world scene contract. Explicit approval authorizes the following implementation scope; the HUD scene contract records the resulting composition.

Implementation plan:
1. Compose `ui/hud/` from small scene/script pairs for HUD root, clock/weather card, pinned quest card, eight-slot toolbar, round shortcut bar, toast stack and toast card. Keep presenter/binding and responsive region layout in separate small classes. Reuse ISO-2 components/Theme; each script has one responsibility and targets <=250 lines. Keep existing Main public references/methods compatible through view adapters; Main only wires the new HUD.
2. Separate background decoration, read-only HUD, interactive controls and existing modal overlay. At design size 1152×648 follow reference 03/04 proportions: upper-left paper quest, upper-right clock/date/season/weather and wallet, bottom-center toolbar with selected caption, lower-left round shortcuts/toasts. Use anchors/containers and shared Theme styles. Preserve world camera/night/rain and modal input locking.
3. Bind actual GameClock, WalletState, inventory and existing tutorial completion to views. Do not invent quest counts/rewards, stamina, calendar events, water capacity, tool levels or future operations. Hide unsupported stamina/event/calendar/map controls; use actual season/year/day values without calendar data migration. Final icon/frame art stays replaceable placeholder code; mockup PNGs remain reference-only.
4. Define eight visible tool/item slots using existing supported tools and real inventory entries, with existing selection APIs and no item/capacity loss. Document the new visible-key mapping and retain hotbar_9 compatibility. Apply D34's B-to-inventory migration while keeping I/Tab: remove B from open_build but retain its action ID. J/Escape remain; no unsupported K/M or Q/E actions are added.
5. Keep existing HUD node paths/public APIs through thin adapters where necessary. Convert relevant old layout assertions to meaningful new-region/selection assertions; retain physical mouse/modal/farming/inventory/save regressions. Run focused tests, full official runner and vi/en three-size day/night/rain captures; compare actual render images to references 03/04 and document limits.

Approved ALLOW_LIST:
```text
ui/hud/**
ui/components/**
ui/theme/**
scripts/view/{main,ui_layout,ui_coordinator,clock_hud,weather_hud,wallet_hud,quest_panel,hotbar_panel,hud_button_bar,feedback_popup,tool_action_controller,chibi_ui_motion}.gd
scenes/main/main.tscn
project.godot (B inventory migration plus documented I/Tab aliases described above)
localization/strings_{vi,en}.*
tests/unit/** (only HUD/component/input/layout regressions affected by ISO-3)
docs/{API_INDEX,ARCHITECTURE,PROGRESS,DECISIONS,ROADMAP,UI_LAYOUT,INPUT_MAP}.md
docs/SCENE_CONTRACTS/{hud,gray_box_world,ui_components}.md
```

Approved acceptance: small modular UI classes; correct reference region placement/layering; real state and maximum two toasts; eight functional slots with preserved inventory/save data; B/I/Tab/J/Escape match documented operations; no fake unsupported state; no horizontal overflow/overlap at 1152×648, 1280×720 and 1920×1080 in vi/en; main/headless/data/full renderer tests pass with honest visual comparison. Domain/data/save/world scenes, reference images and all files outside the list remain read-only. Risks: current tutorial stores completion booleans rather than mockup quantities/rewards; unsupported calendar/map/stamina; keyboard selection compatibility; long localized captions at design size; placeholder art will not reproduce the finished illustration textures.

Approved ISO-2 scope: `ui/theme/**`, `ui/components/**`, `ui/ui_gallery.{tscn,gd,gd.uid}`, `assets/fonts/{Baloo_2,Nunito,Noto_Serif}/**`, `scripts/view/{ui_layout,start_menu,crop_inspector,npc_panel,npc_actor,placeholder_world_2d}.gd`, `scenes/main/main.tscn`, `project.godot` (GUI theme only), `tools/build_ui_theme.{gd,gd.uid}`, relevant `tests/unit/**`, `localization/strings_{vi,en}.*`, `docs/{API_INDEX,ARCHITECTURE,PROGRESS,DECISIONS,ROADMAP,CREDITS,UI_LAYOUT}.md`, and `docs/SCENE_CONTRACTS/{ui_components,ui_gallery}.md`. No domain/save/InputMap/world-map changes, package installs or push are included. Keep the existing game HUD geometry; ISO-3 owns its redesign.

Implementation notes: Google Fonts source files and OFL notices are imported; LifeThemeFactory generates the shared Theme with type variations and embedded placeholder toggle/slider textures. LifeTheme is a resource accessor, not an autoload. Seventeen requested component scenes/scripts plus an icon helper and button base use native Control input and localized captions. The gallery is a standalone comparison scene, with sample values explicitly labelled as examples. Existing C4 runtime theme duplication/panel overrides are replaced with shared-theme references; fonts/skin change without gameplay ownership changes.

## ISO-2 handoff — shared UI foundation (2026-11-03)

Acceptance delivered:
- One active shared Theme with all eight exact tokens, dark 3 px borders/downward shadows, four button states and 28 px reusable frame margins. Existing game roots/world labels share it without panel StyleBox overrides; current HUD geometry/modal behavior stays intact.
- Licensed Baloo 2 800, Nunito 600, Noto Serif Italic 400 and Open Sans fallback; primary font glyph coverage for Vietnamese verified, OFL notices and CREDITS included.
- All seventeen requested component scenes/scripts plus the icon helper and base button; empty/filled/selected/locked item views, int quantities/coins, five-heart rows, progress/toggle/slider/key hints/pills/tags/five tabs. Native press/release and signals work; locked slots reject requests and components do not change domain inventory.
- Gallery has nine sections and all component states, responsive containers, vi/en at 1152×648, 1280×720 and 1920×1080, with 18 renderer captures across top/middle/bottom. Compared actual captures with reference 15: palette, font roles, borders/shadows and state differentiation are present. Textured wood/illustrated icons remain placeholders by design. Last visual fixes add 5 px slot quantity inset and circular HUD buttons.

Clear implementation diff:
- Added LifeTheme accessor, tooling-only Theme factory and builder; committed generated Theme contains reusable native Control variations. Added fonts/OFL/import metadata, components/gallery and nine focused tests.
- Main/project GUI configuration points at the shared Theme. UiLayout stops creating/duplicating Theme styles, keeps existing reflow, and binds shared compact styles. StartMenu/CropInspector/NpcPanel/NpcActor/PlaceholderWorld2D use shared typography/surfaces.
- Appended 71 UI-kit localization rows per language. API_INDEX, ARCHITECTURE, D37, ROADMAP, UI_LAYOUT, CREDITS and the two new scene contracts describe the implemented foundation. Domain/save/InputMap/autoloads remain unchanged. Owner's master-plan blank line remains untouched.

Manual editor steps and acceptance (not yet performed by the owner):
1. Open project in Godot 4.7.2 and allow font/resource import. No node/Inspector wiring is required: the approved scenes/scripts and Project Settings GUI theme path are supplied. Do not replace the main scene with the gallery.
2. Open `ui/ui_gallery.tscn`, press F6, scroll to all nine sections and compare with `docs/ui_reference/15-bo-ui-kit.png`. Check hover/pressed/disabled buttons, selected/locked slots and legible Vietnamese title/body/italic accents. Click the normal buttons/toggle/tabs and drag sliders. Gallery interactions affect only their displayed samples.
3. Repeat at 1152×648, 1280×720 and 1920×1080, vi/en. Use the existing Settings language control, or renderer tests below to cover both locales; gallery labels already present are constructed in the selected locale (rerun F6 after changing it). Confirm no horizontal clipping, overlapping buttons or unreadable quantities.
4. F5 Main: new/continue game, inventory/shop/dialogue/help/pause, close with Escape, walk and farm after closing. Check title font, world labels and compact panels. Verify saves, coins and inventory behave as before. No human playtest or Gate A/B is claimed complete.

Run from project root (PowerShell, installed Godot):
```powershell
$env:GODOT = 'D:\godot\Godot_v4.7.2-stable_win64_console.exe'
& .\tools\run_tests.bat
# Regenerate the Theme after editing its factory:
powershell -NoProfile -ExecutionPolicy Bypass -File tools/run_godot_bounded.ps1 -Godot $env:GODOT -Arguments '--headless --path . --script tools/build_ui_theme.gd' -OutputPath "$env:TEMP\the_life_iso2_theme_build.log"
```

Real final output, 2026-11-03 (summary excerpts, ANSI colors removed):
```text
[ui_theme] wrote ui/theme/the_life_theme.tres
Focused UI suite:
Scripts               3
Tests                 9
Passing Tests         9
Asserts             581
Time              1.328s
---- All tests passed! ----
[check_parse] OK
[validate_data] PASS
[run_tests] running domain and 2D headless tests
Scripts              16
Tests                62
Passing Tests        62
Asserts             849
Time              3.359s
---- All tests passed! ----
[run_tests] running COMPLETE GUT suite with graphics renderer
Scripts              56
Tests               173
Passing Tests       173
Asserts            5965
Time              30.0s
---- All tests passed! ----
[run_tests] starting main scene headless
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org
[run_tests] PASS
```

Full logs: `%TEMP%\the_life_{headless,gut,main,validate}.log.{stdout,stderr}` and `%TEMP%\the_life_iso2_ui_focus.log.{stdout,stderr}`. Renderer captures: `%TEMP%\the_life_test_appdata\Godot\app_userdata\game godot\ui_gallery_{vi,en}_{1152,1280,1920}_{top,middle,bottom}.png`. Visually inspected vi/1152 top+middle and en/1920 bottom after final fixes, with earlier vi top/middle/bottom review. No new engine errors/warnings. The same three pre-existing GUT orphan Labels remain: two in `test_inventory_ui`, one in `test_pause_menu`; they are not hidden or fixed outside this task's focus.

Assumptions/known limits and missing assets:
- Final `assets/ui/icons/ic_{coin,heart,energy,sun,rain,moon,hoe,water,sickle,basket,carrot,tomato,turnip,corn,pumpkin,wood,stone,straw,bag,quest,calendar,map,market,gift}.png` (32×32) and wooden/item nine-slice textures have not been supplied. Circle/initial icons and StyleBoxFlat frames are replaceable placeholders. These paths name future missing art, not loaded runtime resources. Gallery sky/gold progress variants exist; final art polish remains later work.
- Native HSlider/ProgressBar use float ranges internally; displayed inventory/coin quantities remain int. No stamina, friendship, calendar, event or future screen service is implemented by display components.
- Existing key hints show actual bindings (I/J/Escape etc.); no B/K/M/Q/E shortcut migration in ISO-2. Compact HUD stays at C4 geometry until ISO-3. No gameplay/data/capacity/save migration is included.
- No gdtoolkit package was installed; no separate lint claim. Godot parser, data validator, all GUT tests, main smoke and renderer review ran. Human manual acceptance and commit are still needed. Suggested commit: `feat: add shared isometric UI theme and component gallery`.

Exact ISO-2 files created/modified (includes generated import/UID metadata):

```text
assets/fonts/Baloo_2/Baloo2-Variable.ttf
assets/fonts/Baloo_2/Baloo2-Variable.ttf.import
assets/fonts/Baloo_2/OFL.txt
assets/fonts/Noto_Serif/NotoSerif-Italic-Variable.ttf
assets/fonts/Noto_Serif/NotoSerif-Italic-Variable.ttf.import
assets/fonts/Noto_Serif/OFL.txt
assets/fonts/Nunito/Nunito-Variable.ttf
assets/fonts/Nunito/Nunito-Variable.ttf.import
assets/fonts/Nunito/OFL.txt
docs/API_INDEX.md
docs/ARCHITECTURE.md
docs/CREDITS.md
docs/DECISIONS.md
docs/PROGRESS.md
docs/ROADMAP.md
docs/SCENE_CONTRACTS/ui_components.md
docs/SCENE_CONTRACTS/ui_gallery.md
docs/UI_LAYOUT.md
localization/strings_en.csv
localization/strings_vi.csv
project.godot
scenes/main/main.tscn
scripts/view/crop_inspector.gd
scripts/view/npc_actor.gd
scripts/view/npc_panel.gd
scripts/view/placeholder_world_2d.gd
scripts/view/start_menu.gd
scripts/view/ui_layout.gd
tests/unit/test_ui_components.gd
tests/unit/test_ui_components.gd.uid
tests/unit/test_ui_gallery.gd
tests/unit/test_ui_gallery.gd.uid
tests/unit/test_ui_theme.gd
tests/unit/test_ui_theme.gd.uid
tools/build_ui_theme.gd
tools/build_ui_theme.gd.uid
ui/components/banner.gd
ui/components/banner.gd.uid
ui/components/banner.tscn
ui/components/btn_accent.gd
ui/components/btn_accent.gd.uid
ui/components/btn_accent.tscn
ui/components/btn_danger.gd
ui/components/btn_danger.gd.uid
ui/components/btn_danger.tscn
ui/components/btn_primary.gd
ui/components/btn_primary.gd.uid
ui/components/btn_primary.tscn
ui/components/btn_round_hud.gd
ui/components/btn_round_hud.gd.uid
ui/components/btn_round_hud.tscn
ui/components/btn_secondary.gd
ui/components/btn_secondary.gd.uid
ui/components/btn_secondary.tscn
ui/components/coin_label.gd
ui/components/coin_label.gd.uid
ui/components/coin_label.tscn
ui/components/component_button.gd
ui/components/component_button.gd.uid
ui/components/heart_row.gd
ui/components/heart_row.gd.uid
ui/components/heart_row.tscn
ui/components/icon_placeholder.gd
ui/components/icon_placeholder.gd.uid
ui/components/icon_placeholder.tscn
ui/components/item_slot.gd
ui/components/item_slot.gd.uid
ui/components/item_slot.tscn
ui/components/key_hint.gd
ui/components/key_hint.gd.uid
ui/components/key_hint.tscn
ui/components/panel_wood.gd
ui/components/panel_wood.gd.uid
ui/components/panel_wood.tscn
ui/components/pill.gd
ui/components/pill.gd.uid
ui/components/pill.tscn
ui/components/progress_bar_styled.gd
ui/components/progress_bar_styled.gd.uid
ui/components/progress_bar_styled.tscn
ui/components/slider_styled.gd
ui/components/slider_styled.gd.uid
ui/components/slider_styled.tscn
ui/components/tab_bar.gd
ui/components/tab_bar.gd.uid
ui/components/tab_bar.tscn
ui/components/tag.gd
ui/components/tag.gd.uid
ui/components/tag.tscn
ui/components/toggle_on_off.gd
ui/components/toggle_on_off.gd.uid
ui/components/toggle_on_off.tscn
ui/theme/life_theme.gd
ui/theme/life_theme.gd.uid
ui/theme/the_life_theme.tres
ui/theme/theme_factory.gd
ui/theme/theme_factory.gd.uid
ui/ui_gallery.gd
ui/ui_gallery.gd.uid
ui/ui_gallery.tscn
```

## ISO-1 committed baseline

`ISO-1 (2D isometric runtime)` — implementation delivered; final official runner passes 62/62 headless tests and 164/164 complete renderer tests, plus parse/data/main checks. Human editor playtest is pending. See the ISO-1 handoff below for the exact files, save compatibility, real output and manual tests. ISO-2 UI theme/gallery remains next, outside this code scope.

## Previous milestone

`ISO-0 (2D isometric migration specification)` — documentation delivered under the twelve-file scope approved by the owner's instruction “tôi đã bổ sung tài liệu ... bắt đầu đi”. D33–D35 supersede the old 3D target and stage later UI/data changes. No runtime script, scene, project setting, font, translation, domain object or save schema has changed. ISO-1 source work was subsequently approved by “oke tiếp tục”, with the explicit pause_menu.gd scope extension recorded below. The ISO-0 ROADMAP row stays in review for the human to tick.


## ISO-1 handoff — active 2D runtime (2026-11-02)

Acceptance delivered by automation:
- Active Main gameplay tree has zero Node3D descendants. Player is CharacterBody2D with its child Camera2D; eight collision names moved to 2D, Jolt project override removed, 1152×648/canvas_items/keep configured.
- Ground/Farmland share a generated 64×32 isometric Diamond Down TileSet. Cell picking, mouse position and screen/global round trips pass with negative cells, zoom/pan and a transformed layer. Grounded actor/crop/tree y-sort and swept house-footprint collision are checked.
- FarmGridState, inventory/wallet, GameClock/day simulation, weather, NPC/social/merchant logic, crop values/yield, save v4, existing InputMap/autoloads/font remain in use. No domain file was changed. Physical GUI click, modal, farming drag/inspection, transaction, old-save and vi/en three-size layout regressions run in the complete suite.
- ISO-1 is implemented and verified; human editor playtest is still pending, so ROADMAP ISO-1 remains in review. ISO-2 wooden Theme/fonts/gallery and later HUD/inventory/balance steps have not been started.

Implementation diff summary:
- Main/three scenes: CanvasLayer 1 keeps existing UI child paths; WorldCanvas 0 follows Camera2D. World children move under WorldCanvas; actors/crops/homes and passive art use Objects with nested y-sort. Typed main/world references replace active 3D APIs.
- New data/view files: IsometricWorldConfig and two Resources own map/reach/zoom/speeds; IsometricGrid delegates projection to Godot; PlaceholderAvatar2D/PlaceholderWorld2D are replaceable art only.
- Farm presentation: TileMapLayer terrain, Polygon2D soil decorations, cached Sprite2D growth textures, localized hidden Label status, transformed-sprite picking, transient bounded 2D effects. No growth or inventory authority moved into a view.
- NPC views: state stays under NpcSystem; actors/homes render under Objects, exposed through its actors/homes dictionaries. Existing Vector3 location Resources and GridMath remain pure legacy logical adapters; no TileMapLayer enters DOMAIN.
- Save compatibility: actual old v4 player.position.x/y/z is retained. The current 2D position resolves to a cell, saves its legacy center, and restores into the corresponding 2D cell. Old fractional offsets snap to a cell center; invalid numeric fields fall back to data-owned spawn and out-of-bounds cells clamp. SaveService/schema and golden saves were not edited.
- PauseMenu's approved extra change replaces its old GrayBoxWorld/Player lookup with the typed GrayBoxWorld.player reference. WeatherFx listens to time_changed as well as weather/season, so direct set_time changes day/night effects immediately.
- Test migration keeps archive-generated model/shader/animation audits. Only obsolete live 3D mesh/light/camera assertions are replaced by meaningful 2D state/picking/tint/canvas equivalents. Seven new tests cover migration-specific invariants. No test was skipped or weakened.
- Runner: parse → validator → headless domain/2D suite → COMPLETE renderer GUT → main headless. The bounded process helper hides windows, isolates APPDATA/user data under TEMP, retains the native process handle and propagates engine failures reliably.

Exact authored files created/modified (includes the earlier ISO-0 documentation carried in this working tree; twelve entries are new files including five generated .uid companions):
```text
AGENTS.md
docs/API_INDEX.md
docs/ARCHITECTURE.md
docs/CODE_PATTERNS.md
docs/COLLISION_LAYERS.md
docs/DECISIONS.md
docs/INPUT_MAP.md
docs/PROGRESS.md
docs/PROJECT_RULES.md
docs/ROADMAP.md
docs/SCENE_CONTRACTS/gray_box_world.md
docs/SCENE_CONTRACTS/player.md
project.godot
scenes/main/main.tscn
scenes/player/player.tscn
scenes/world/gray_box_world.tscn
scripts/core/data_validator.gd
scripts/player/player.gd
scripts/player/player_config.gd
scripts/view/camera_rig.gd
scripts/view/crop_presentation.gd
scripts/view/debug_menu.gd
scripts/view/farm_effects.gd
scripts/view/farm_view.gd
scripts/view/gray_box_world.gd
scripts/view/main.gd
scripts/view/npc_actor.gd
scripts/view/npc_system.gd
scripts/view/pause_menu.gd
scripts/view/soil_presentation.gd
scripts/view/tool_action_controller.gd
scripts/view/weather_fx.gd
scripts/view/world_presentation.gd
tests/unit/test_chibi_characters.gd
tests/unit/test_chibi_farming.gd
tests/unit/test_chibi_world.gd
tests/unit/test_crop_inspector.gd
tests/unit/test_day_night.gd
tests/unit/test_drag_farming.gd
tests/unit/test_farm_layout.gd
tests/unit/test_farm_view.gd
tests/unit/test_game_feel.gd
tests/unit/test_interaction_range.gd
tests/unit/test_move_dir.gd
tests/unit/test_project_config.gd
tests/unit/test_seed_shop.gd
tests/unit/test_shipping_bin.gd
tests/unit/test_tool_action.gd
tests/unit/test_weather.gd
tests/unit/test_world_presentation.gd
tools/run_godot_bounded.ps1
tools/run_tests.bat
tools/validate_data.gd
data/isometric_world_config.tres
data/player_2d_config.tres
scripts/data/isometric_world_config.gd
scripts/data/isometric_world_config.gd.uid
scripts/view/isometric_grid.gd
scripts/view/isometric_grid.gd.uid
scripts/view/placeholder_avatar_2d.gd
scripts/view/placeholder_avatar_2d.gd.uid
scripts/view/placeholder_world_2d.gd
scripts/view/placeholder_world_2d.gd.uid
tests/unit/test_isometric_migration.gd
tests/unit/test_isometric_migration.gd.uid
```

The owner's untracked the_life_prompt.md and docs/ui_reference PNGs remain inputs, not authored game assets. Godot's editor scan generated ordinary .png.import metadata beside the supplied references; no reference PNG was edited, renamed or used at runtime. Generated 3D assets/shaders/builders remain unchanged. Captures are ignored review outputs, not source edits. Full tracked patch: git diff -- AGENTS.md docs project.godot scenes scripts tests tools; inspect the twelve listed new files alongside it. No commit/push was run.

Real final official runner output:
```text
[check_parse] OK
[validate_data] PASS

Headless domain/2D:
Scripts              16
Tests                62
Passing Tests        62
Asserts             849
Time              2.973s
---- All tests passed! ----

Complete renderer suite:
Scripts              53
Tests               164
Passing Tests       164
Asserts            5366
Time              23.447s
---- All tests passed! ----

[run_tests] starting main scene headless
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org
[run_tests] PASS
```

Run from project root: tools\run_tests.bat (GODOT can point to D:\godot\Godot_v4.7.2-stable_win64_console.exe). Logs: TEMP/the_life_parse.log.*, the_life_validate.log.*, the_life_headless.log.*, the_life_gut.log.*, the_life_main.log.*. The intentional missing-script runner probe returned exit 1, confirming failure propagation; its expected error log is separate (the_life_iso1_expected_failure.log.*), not a successful validation log.

Final parse/validator/headless/full-suite/main/capture error-text scan: 0 matches for SCRIPT ERROR, Parse Error, Failed to load script or ERROR:. GUT still reports the same pre-existing two orphan Labels in test_inventory_ui and one in test_pause_menu as the ISO-0 baseline; the new migration test has no orphan warning. These are not claimed fixed or hidden. gdtoolkit lint was not run or installed.

Visual review:
- Normal Forward+/D3D12 capture flags produced screenshots/chibi-ui/chibi_ui_title.png and chibi_ui_hud.png, plus screenshots/chibi-farming/chibi_farming_main_scene.png. HUD and populated-farm captures were visually inspected at 1152×648: world is 2D with clear farm cells, grounded characters/buildings/trees and unchanged readable C4 UI. This is placeholder verification, not final mockup-art acceptance or a performance benchmark.
- Existing capture flag/tool names remain for compatibility; they now capture the 2D main scene. Historical 3D lineup tools/assets remain available separately.
- Capture logs: TEMP/the_life_iso1_capture.log.* and the_life_iso1_farming_capture.log.*.

Manual editor steps / test cases:
1. Stop an old running game, reload externally changed scenes if Godot prompts, open scenes/main/main.tscn and F5. No manual node construction, InputMap or Inspector change is required.
2. Continue an existing v4 save and confirm inventory/coins/crops/social progress. The player's position restores to the center of its saved logical cell.
3. WASD/arrows and Shift: movement follows screen axes; diagonals have no speed bonus in uncompressed movement space. Walk into a house blocker; it must stop/slide. Use = / - to zoom and check hover/click targeting at each level.
4. Select a seed in inventory (I/Tab), hoe/plant/water reachable plots, inspect the top of a plant, drag water/harvest, and verify quantities. Full inventory must leave a harvestable crop in place.
5. Near shop/bin use E; buy/sell and verify coins/items. Use existing debug visit for Minh, talk/deliver and verify journal/save progress. Change clock/weather: night tint/windows/rain follow real state; rain waters crops.
6. I/H/J/Esc and actual mouse buttons: one modal at a time, no world action beneath a modal, Pause closes/unlocks correctly, HUD stays fixed while the camera moves. Sleep when allowed and reload; day/crop/season state must remain consistent.
7. Compare vi/en and 1152×648, 1280×720, 1920×1080 as in automated layout coverage. Human gameplay acceptance and Gate A/B evidence remain outstanding.

Assumptions/known limits:
- Art is intentionally simple placeholder drawing/textures; detailed crops, seasonal critters, house lighting and final sprites remain replaceable. Current UI is still C4/Open Sans, not the new mockup Theme. Stamina remains absent/hidden.
- Legacy NPC Resources and save wire coordinates still use Vector3 data, while the active gameplay tree has no 3D nodes. This is intentional compatibility, not an alternate rendering path.
- New players use data-owned 2D movement/zoom/map values. Gameplay crop prices/timing/yield/capacity are untouched. Later tomato regrow/fertilizer/house-unlock requirements still need their own specification.
- Automated captures do not substitute for the owner's editor playtest. No unapproved future milestone, package install, git commit or git push is included.

Next: owner editor playtest of ISO-1; then define/approve ISO-2's UI resource/source allow list before building the shared Theme, font imports/components and gallery. Proposed commit: feat: migrate active gameplay to 2D isometric placeholders

## ISO-0 acceptance, changes and verification (2026-11-02)

- Acceptance delivered: reconcile old locked 3D rules with the requested 2D target; document scene/movement/grid/collision/UI boundaries; account for sixteen mockups; preserve current runtime API truth; define the staged migration and a reviewable source-scope proposal. No new test file is needed for specification-only changes; existing checks were run as a baseline, not evidence of a completed 2D game.
- Decisions: D33 selects 64×32 isometric tiles, CharacterBody2D/child Camera2D, TileMapLayer conversions, eight 2D collision layers and 1152×648 design size. D34 selects the wooden/paper shared Theme, placeholder strategy, later font/shortcut migration and hidden unsupported stamina UI. D35 stages the prompt's calendar/crop/price/inventory changes for their own tested tasks. Historical decisions are retained with superseded statuses where appropriate.
- Exact modified files (all inside the approved scope): `AGENTS.md`; `docs/PROJECT_RULES.md`; `docs/DECISIONS.md`; `docs/ARCHITECTURE.md`; `docs/ROADMAP.md`; `docs/INPUT_MAP.md`; `docs/COLLISION_LAYERS.md`; `docs/CODE_PATTERNS.md`; `docs/SCENE_CONTRACTS/player.md`; `docs/SCENE_CONTRACTS/gray_box_world.md`; `docs/API_INDEX.md`; `docs/PROGRESS.md`.
- Clear change summary: replace the normative 3D/XZ/camera-yaw target with a 2D target; retain legacy implementations as explicitly labelled migration references. Add ISO-0–ISO-7 sequencing and future acceptance. Separate current InputMap/API tables from planned bindings/types; preserve DOMAIN and save ownership. Correct the player contract's stale config path: the actual class is `scripts/player/player_config.gd`; `data/player_config.tres` does not exist. Full patch is reviewable with `git diff -- AGENTS.md docs` (reference PNGs and the owner's untracked prompt are untouched).
- Manual editor steps for ISO-0: none. Do not change project settings/scenes piecemeal to the target before ISO-1 code lands. After ISO-1, editor/manual acceptance must cover foot-level sorting/collision, picking at negative cells/zoom, WASD/Shift, modal input locks, farm planting/watering/harvest, full inventory, shop/bin/NPC interaction, sleep and v4 save/load.
- Known limits: selected new font files/licenses are not imported/verified yet; final frame/icon/sprite PNG assets are not supplied (use placeholders). Tomato regrow interval, fertilizer behavior and house-level unlock integration still need specification in ISO-6. Existing autoload count/schema documentation has historical differences from runtime; preserve actual registered autoloads during ISO-1 rather than performing an unrelated cleanup. Existing art tests include renderer-dependent assertions, so a full dummy-renderer headless run is currently not viable.

### Supplied reference inventory (read-only)

The owner supplied all files below. Header inspection found each numbered screen 01–15 is **2304×1296** (exactly 2× the 1152×648 design frame). Overview is **2536×3246**. No resize/rename is needed; layout measurements use the design frame. Overview and UI kit were visually inspected during ISO-0; other individual screens still require visual review in their corresponding implementation task. Mockups are references only, not runtime textures.

```text
docs/ui_reference/00-tong-quan-giao-dien.png
docs/ui_reference/01-menu-chinh.png
docs/ui_reference/02-tao-nhan-vat.png
docs/ui_reference/03-trong-game-ban-ngay.png
docs/ui_reference/04-trong-game-dem-mua.png
docs/ui_reference/05-ban-tin-sang.png
docs/ui_reference/06-tui-do.png
docs/ui_reference/07-nhan-vat.png
docs/ui_reference/08-so-nhiem-vu.png
docs/ui_reference/09-lich-su-kien.png
docs/ui_reference/10-cua-hang.png
docs/ui_reference/11-nang-cap-nha.png
docs/ui_reference/12-hoi-thoai.png
docs/ui_reference/13-ket-thuc-ngay.png
docs/ui_reference/14-tam-dung-cai-dat.png
docs/ui_reference/15-bo-ui-kit.png
```

### Real ISO-0 baseline results

Engine: `D:\godot\Godot_v4.7.2-stable_win64_console.exe` (version `4.7.2.stable.official.ed1daf0bf`). Parse and validator used an isolated APPDATA under `%TEMP%/the_life_iso0_appdata`; GUT used the same isolated user data to avoid touching player saves/settings. Main headless smoke subsequently ran against the unchanged main scene. No commit/push was run.

Initial sandbox parse/validator emitted `ERROR: Failed to read the root certificate store.`; the same commands rerun with approved escalation exited 0 without this error. Real validator output:

```text
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org
[validate_data] PASS
```

Headless GUT was attempted with `--headless --path . --script addons/gut/gut_cmdln.gd -gdir=res://tests/unit -gprefix=test_ -gexit`. It did NOT complete: existing `test_generated_shaders_and_materials_load_and_bind_to_a_viewport` in `test_chibi_art_foundation.gd` waits for `RenderingServer.frame_post_draw`, which the dummy renderer does not deliver. Only the matching test process was stopped after verifying its command line; the pre-existing editor was left alone. No test was skipped, weakened or changed. This is a harness limitation, not a headless pass.

Full GUT was rerun with the configured normal Forward+ renderer, hidden window and 120-second bound. Real final output (exit 0):

```text
Scripts              52
Tests               157
Passing Tests       157
Asserts            5146
Time              30.372s
---- All tests passed! ----
```

Logs: `%TEMP%/the_life_iso0_rendered.stdout`, `.stderr`; interrupted headless log: `%TEMP%/the_life_iso0_gut.log`. `--headless --path . --quit` and `--headless --path . --quit-after 120` both exited 0 outside the sandbox with no script/parse/error text. No manual gameplay or visual 2D test is claimed. Final review: `git diff --check` exit 0; rendered GUT logs have 0 matches for `SCRIPT ERROR|Parse Error|Failed to load script|ERROR:` and 1 all-tests-passed summary. Exactly the twelve approved documentation files are modified; the owner's sixteen reference images and `the_life_prompt.md` remain untracked and untouched. Suggested ISO-0 commit: `docs: specify 2D isometric migration and mockup UI stages`.

### ISO-1 source plan / approved ALLOW_LIST (2026-11-02)

Source scope was authorized by the owner's “oke tiếp tục”; the owner additionally approved scripts/view/pause_menu.gd through the scope-extension question. This records the plan that was executed. Convert active gameplay scenes in place, preserve their resource paths and UI/modal entry points, replace active 3D art with code placeholders, and leave generated art/review archives intact. Keep logical farm cells and existing services. Adapt NPC location conversion explicitly without giving TileMapLayer to domain routing; preserve save v4 unless the actual payload requires migration. Do not change crop balance, inventory capacity, fonts, shortcuts or final mockup layout in ISO-1.

Approved source scope (brace groups enumerate files; `tests/unit/**` permits only relevant regression updates/additions, never skipping or weakening assertions):

```text
project.godot
scenes/main/main.tscn
scenes/world/gray_box_world.tscn
scenes/player/player.tscn
scripts/player/{player,player_config}.gd
scripts/util/grid_math.gd
scripts/data/{world_locations,isometric_world_config}.gd
scripts/domain/quests/npc_schedule.gd
scripts/core/data_validator.gd
scripts/view/{main,gray_box_world,camera_rig,farm_view,crop_presentation,soil_presentation,farm_effects,tool_action_controller,tool_drag_stroke,debug_menu,npc_actor,npc_system,world_presentation,weather_fx,isometric_grid,placeholder_avatar_2d,placeholder_world_2d}.gd
scripts/view/pause_menu.gd (explicit owner-approved scope extension)
data/{isometric_world_config,player_2d_config}.tres
data/npcs/phase8_world.tres
tools/{run_tests.bat,check_parse.bat,run_godot_bounded.ps1,validate_data.gd}
tests/unit/**
Godot-generated .uid companions for new source/test files above
the same twelve documentation files listed in ISO-0
```

The isometric config/grid/placeholder paths above were approved as new files and now exist. Implemented exports/methods/node contracts are recorded in API_INDEX and the scene contracts. Existing `world_art_factory`, chibi mesh/face/bubble/seasonal-3D helpers and generated scenes can remain historical tools; active world/player/NPC code must stop instantiating them. If source inspection proves another file is required, request a scope extension before modifying it.

Acceptance: no Node3D in the active gameplay tree; correct 64×32 map/local round trips including negative cells and camera/layer transforms; normalized screen-relative movement with vertical ×0.5 and 2D collisions; matching eight layer names; deterministic farming/weather/NPC behavior; real physical GUI click/modal safety; old save round trip; data gate + parse + main smoke; domain tests headless and the complete renderer-dependent GUT suite on Forward+. Fix the test-runner separation explicitly rather than pretending full headless GUT can currently finish or silently skipping visual tests.

Risk: this touches 3D-typed view signatures and interaction/picking tests across several systems. Update expectations only where 2D intentionally replaces a 3D presentation detail; keep state, transaction, deterministic/golden and input assertions. Manual 2D gameplay review remains a human acceptance step. No git commit/push, archive deletion, package installation or unrelated refactor is authorized by this scope.

## Historical C4 status
`C3 (Chibi world)` — complete and tagged `chibi-world`. It adds only generated view-layer world/building/seasonal presentation while preserving all interaction anchors, collision, navigation, crop picking, weather/day-night authority and save v4.

`C4 (Chibi UI / M7)` — complete and tagged `chibi-ui`. It adds a C0-palette pastel pill Theme, compact icon-first HUD preservation, themed native tooltips, code-drawn tool-aware cursor, keyboard focus and restrained hover/press/open bounce. It preserves the readable map-first HUD, real GUI input routing, all current localization, and has no save/schema/input-domain change.

`C1 (Chibi characters)` — complete and tagged `chibi-characters`. C0 remains tagged `chibi-core`; C1 opts the existing player/NPC presentation into the C0 core without changing gameplay IDs, schedules or save schema.

## C4 approved plan and allow list (2026-10-30)

- Add runtime-only `ChibiUiMotion` and `ChibiCursor` view helpers. They will animate existing focusable controls with small hover/press/open tweens and draw a project-original rounded paw/tool cursor above all UI. They do not submit gameplay input, add an InputMap action, own UI state, save anything or change a node path required by a scene.
- Extend the existing runtime `UiLayout` theme from the C0 palette with warm rounded panel/button/field/tooltip styles, standardized readable font sizes and keyboard-focus treatment. Existing localized `tooltip_text` remains the tooltip source; the compact hotbar and corner icon bar retain their current map-safe footprints.
- Polish only the existing title card/backdrop with a restrained logo outline/bob and slow decorative parallax/motes. Keep actual StartMenu Buttons/OptionButtons and their callbacks, so physical mouse and keyboard paths remain Godot Controls rather than illustration hitboxes.
- Add an opt-in normal-renderer UI capture argument/tool that writes title and in-game HUD review PNGs without loading or writing a save. Add focused C4 regression coverage for cursor/tool modes, motion/theme wiring, native tooltip style, keyboard focus and compact three-resolution HUD constraints. Re-run the existing physical mouse/modal layout tests rather than weakening them.
- Planned C4 files only: `scripts/view/{chibi_cursor,chibi_ui_motion,ui_layout,start_menu,title_backdrop,main}.gd` and generated `.uid` companions; `tools/capture_chibi_ui.bat`; `tests/unit/test_chibi_ui.gd`; `docs/{API_INDEX,ART_BIBLE,PROGRESS,DECISIONS,UI_LAYOUT,CREDITS}.md`; and only existing C4-relevant UI tests if a deliberate assertion must change (with the reason recorded in `DECISIONS.md`). No `.tscn`, domain, save service/schema, economy, farming, NPC schedule, weather/day-night, localization text, input action, collision or C0–C3 generated model data is in scope.

## C4 completion and handoff (2026-10-30)

- Delivered the runtime-only `ChibiUiMotion` and `ChibiCursor`. Existing Buttons/fields receive small focus/hover/press/panel-open presentation tweens, while the code-drawn topmost cursor changes from paw-over-UI to a tiny selected hoe/watering-can/seed/harvest cue. It uses `MOUSE_FILTER_IGNORE`, restores the OS cursor on exit, creates no saved field or new input action, and does not call gameplay methods.
- `UiLayout` now derives its shared runtime Theme from the C0 palette: cream rounded panels, pastel pill Button/OptionButton/field states, visible keyboard focus, and a native styled Godot tooltip panel. The four tool icons and four corner buttons retain the compact D24 footprint; no item grid was restored over the map.
- Title keeps real Godot Controls and callbacks, now with an outlined/breathing logo, primary keyboard focus, form/settings focus routing and slow pointer-relative backdrop motes. The normal title/HUD capture was visually reviewed: no clipped cards, missing button, overlapping HUD or map-covering chrome was found. Tool icons intentionally stay compact after the earlier player feedback; their localized tooltips expose names/keys.
- New normal-renderer evidence is `screenshots/chibi-ui/chibi_ui_title.png` and `screenshots/chibi-ui/chibi_ui_hud.png`. The capture recorded `1152×648`, `60.0` FPS, `1,294` draw calls and `1,437` objects. The existing/current C4 UI regressions cover the same map-safe layout at `1152×648`, `1280×720` and `1920×1080` (vi/en); this one normal capture is not the still-deferred M0 full capture matrix.
- Final C4 verification: `tools\capture_chibi_ui.bat` PASS; `[check_parse] OK`; `[validate_data] PASS`; 52 scripts, 157/157 passing tests, 5,146 asserts, 27.415 s, `[run_tests] PASS`. The parse/validator/GUT/main/capture log scan found `0` matches for `SCRIPT ERROR`, `Parse Error`, `Failed to load script` or `ERROR:`; `git diff --check` passes. Generated assets remain unchanged at 162 files / 4,229,000 bytes.

## C3 approved plan and allow list (2026-10-29)

- Create original, reproducible rounded-primitive C3 world assets under `assets/generated/models/world/`: player cottage, seed market, shipping bin, generic NPC cottage, inactive observatory landmark, rounded tree, forest/cliff boundary, pond/bridge, fence/path and small village props (well, lamp, mailbox, signpost, bench, woodpile, flowers/rocks), plus tiny bird/butterfly/firefly silhouettes. Every model stays grounded, finite and within the C0 building/tree/prop budgets.
- Add a validated visual-only `WorldArtCatalog` under `data/art/world/`. It owns stable C3 asset IDs, palette roles, non-interactive placement/layout data and seasonal presentation colors. It must not encode gameplay price, collision, navigation, NPC schedule, farm grid, time or save data.
- Rebuild only the `WorldPresentation` art children through generated C3 scenes while retaining the exact House, SeedShop, ShippingBin, NPC-home, FarmView and marker transforms. Add soft terrain dressing, paths, water/bridge, rounded forest/cliff boundary and village props as non-colliding view children outside farm cells, route cells and interaction reach zones.
- Add a bounded `WorldSeasonFx` view that listens to existing `GameClock` season/time and `WeatherState` changes: spring petals, summer butterflies/day birds and night fireflies, autumn leaves, winter snow plus rain-water ripples. It owns no random gameplay, save field, input action, time/weather value or particle system outside the documented cap.
- Add reproducible C3 build, normal-renderer 4-angle/day-night/seasonal review and real-main-scene capture tools. Update the world scene contract before runtime changes, add narrow asset/data/view/review regression tests and preserve all current crop picking, NPC navigation/home, merchant/shop/bin and UI-layout coverage. Existing visual tests may change only where their primitive-art assertion is intentionally superseded; record why in a new decision.
- Planned C3 files only: `docs/{API_INDEX,ART_BIBLE,PROGRESS,DECISIONS,DATA_SCHEMA,UI_LAYOUT,CREDITS,SCENE_CONTRACTS/README,SCENE_CONTRACTS/gray_box_world,SCENE_CONTRACTS/world_art_lineup}.md`; `scripts/{data/world_art_catalog,core/data_validator,view/world_presentation,view/world_art_factory,view/world_season_fx,view/main}.gd`; `data/art/world/**`; `assets/generated/models/world/**`; `tools/{build_chibi_world,art_review_world,capture_chibi_world}.bat`, `tools/art/chibi/{build_chibi_world,chibi_world_builder,chibi_world_lineup,world_art_review_runner}.gd`, `tools/chibi_world_lineup.tscn`; `tests/unit/{test_chibi_world,test_world_review_layout,test_world_presentation}.gd`; and required generated `.uid` files. No existing gameplay `.tscn`, domain farm/economy/inventory/NPC schedule code, save service/schema, input map, collision layers, weather/day-night data or localization is in scope.

## C3 completion and handoff (2026-10-29)

- Delivered a validated, visual-only `WorldArtCatalog` and 21 reproducible rounded-primitive scenes: five buildings, a tree, cliff/forest boundary, pond/bridge, ten village-prop categories and three ambient critters. Measured triangles remain below their C0 budget: player cottage `600 / 8,000`, market `440 / 8,000`, NPC cottage `276 / 8,000`, tree `520 / 1,000`, and the largest prop/flower patch `600 / 1,500`.
- `WorldPresentation` now installs one runtime `C3WorldArt` root and safely replaces only visual children beneath the existing House, SeedShop, ShippingBin and Phase 8 home anchors. Exact anchors/markers, collision, NPC routes, FarmView/crop picking, merchant handling, time/weather authority and save v4 are unchanged. Passive catalog placements are tested outside farm cells and every protected interaction reach.
- `WorldSeasonFx` observes existing clock/weather state: spring petals, summer day butterflies/birds and night fireflies, autumn leaves, winter snow and rain ripples. The catalogue cap is `28`; the most populated current seasonal/rain combination is below that cap and it creates neither save data nor gameplay randomness.
- Normal-renderer C3 review writes five 4-season × day/night × four-angle contact sheets plus `screenshots/chibi-world/chibi_world_main_scene.png`. Three focused correction rounds found/fixed: generated scene ownership/anchor handoff; unsafe initial fence/path proximity to interaction areas; duplicate named presentation groups; and the C0 toon/outline pass rendering dark/black in the real world pipeline. Runtime toon instances now use a local readable material while generated sources and foliage/water shader treatment stay intact.
- Capture sample on the normal Forward+ renderer at `1152×648` recorded `58.3` frame FPS, `1,294` draw calls and `1,437` rendered objects (`Performance.TIME_FPS` reported `29.9` in this capture window). This is C3 review evidence, not the deferred M0 smoke/autoplay/full `1920×1080` benchmark; do not interpret it as a release-performance claim.
- Generated assets currently total `162` files / `4,229,000` bytes; the C3 world directory is `22` files / `696,982` bytes, well below the product prompt's overall generated-asset budget.
- Final verification before the C3 commit/tag: `tools\build_chibi_world.bat` PASS; `tools\art_review_world.bat` wrote five contact sheets and the main-scene image; `[check_parse] OK`; `[validate_data] PASS`; 51 scripts, 154/154 passing tests, 5,110 asserts, 24.665 s, `[run_tests] PASS`. The C3 build/review/capture/parse/validator/GUT/main log scan found 0 matches for `SCRIPT ERROR`, `Parse Error`, `Failed to load script` or `ERROR:`; `git diff --check` passes.

## C2 approved plan and allow list (2026-10-28)

- Deliver original, reproducible rounded-primitive farming assets under `assets/generated/`: four readable growth stages plus a wilted stage for each of the nine registered crops, small seed/produce props for all eighteen `ItemData` resources, and held hoe/watering-can/seed/harvest props. All use the C0 palette/material factory, grounded pivots and palette-owned triangle budgets.
- Rework only `CropPresentation` and `SoilPresentation` beneath the existing `FarmView` roots. Preserve `get_cell_view`, `get_crop_view`, `get_crop_label` and crop picking bounds while adding family-specific stage silhouettes, mature sparkle/bob, tilled furrows and wet-soil treatment. Do not change FarmGridState, crop timing/yield, weather, tool, inventory or save logic.
- Add a data-backed visual art catalogue and optional ItemData visual metadata so all current item data resolve deterministic generated 128 px transparent sticker icons. `UiIcons` may prefer these generated item icons but retains every SVG/tool-chrome fallback; this is item artwork only, not the C4 HUD/theme redesign.
- Add bounded view-only farm effects called only after the existing tool action succeeds. Failed, out-of-reach or capacity-blocked actions must not create an effect or mutate anything.
- Add reproducible build/icon/review tools and normal-renderer four-angle/day-night farm contact sheets plus a real-main-scene capture. Add narrow C2 tests/audits for assets, item icon resolution, crop-root picking, soil/effect behavior and regression locks. Review no more than three visual correction rounds and record actual findings.
- Planned C2 files only: `docs/{API_INDEX,ART_BIBLE,PROGRESS,DECISIONS,DATA_SCHEMA,UI_LAYOUT,CREDITS,SCENE_CONTRACTS/gray_box_world,SCENE_CONTRACTS/farming_art_lineup}.md`; `scripts/{data/item_data,farming_art_catalog,core/data_validator,view/crop_presentation,soil_presentation,farm_view,tool_action_controller,ui_icons,farm_effects,chibi_avatar,main}.gd`; `data/{items/**,art/farming/**}`; `assets/generated/{models/farming/**,icons/**}`; `tools/{build_chibi_farming,art_review_farming,capture_chibi_farming}.bat`, `tools/art/chibi/**`, `tools/farming_art_lineup.tscn`; `tests/unit/{test_chibi_farming,test_farming_review_layout,test_ui_mouse}.gd`; and required generated `.uid` files. No gameplay `.tscn`, domain crop/tool/inventory code, save service, economy, input map, prices or crop balance data is in scope.

## C2 completion and handoff (2026-10-29)

- Delivered a validated `FarmingArtCatalog` and 45 original generated crop scenes: four visible stages plus one withered state for each of the nine registered crops. The current crop-family mapping covers roots, vines, stalks, grain, ground vines and leafy crops, while `CropPresentation` preserves the existing logical root/picking contract, adds data-driven silhouette/dew/mature presentation, and never changes farm state.
- Delivered 18 grounded item prop scenes and 22 transparent 128 px stickers (18 seed/produce items plus four tools). Optional `ItemData.model_path` / `icon_path` are strictly view metadata. `UiIcons` prefers C2 stickers, retains SVG fallbacks, and the existing C1 held-tool animation now uses C2 props with its old procedural fallback intact.
- Delivered C2 tilled furrows, wet-soil treatment and bounded farm effects after successful hoe/seed/water/harvest paths only. Failed/missing-item/out-of-reach/capacity-blocked attempts remain visually and mechanically inert; crop growth, two-product harvests, economy, inventory atomicity, drag strokes and save v4 were not altered.
- Reproducible normal-renderer review tooling creates 14 four-angle/day-night sheets plus a real `main.tscn` capture under ignored `screenshots/chibi-farming/`. Review correction round 1 found focused assets too distant, 3D labels obscuring silhouettes and C0 shader shading too dark under the existing world pipeline; focused views now omit model labels, use closer framing, crop presentation gets a local readable material override, and the showcase spreads the nine crops over alternate cells. Round 2 found long crop captions crowded at tile seams; the sheets now use compact two-line captions. Final sheets show distinct growth silhouettes, items/tools and readable daylight/night contrast; the scene capture shows the C2 farm in the real HUD/camera context.
- Final verification before the C2 commit/tag: `tools\build_chibi_farming.bat` PASS; `tools\art_review_farming.bat` wrote 14 contact sheets and `chibi_farming_main_scene.png`; `[check_parse] OK`; `[validate_data] PASS`; 49 scripts, 151/151 passing tests, 4,741 asserts, 24.367 s, `[run_tests] PASS`. The C2 build/review/capture/parse/validator/GUT/main log scan found 0 matches for `SCRIPT ERROR`, `Parse Error`, `Failed to load script` or `ERROR:`.

## C1 approved plan and allow list (2026-10-27)

- Add a validated, data-owned character catalogue under `data/art/characters/`: six selectable player hair/skin/color combinations with a persisted cosmetic selection, plus distinct profiles for An, Bác Lâm, Linh and Minh. The existing opaque `profile` payload will store only an optional cosmetic dictionary, so older v4 saves retain their default appearance without a schema bump.
- Add original reproducible chibi-character tooling under `tools/art/chibi/` and generated scenes under `assets/generated/models/characters/` for player, An, Bác Lâm, Linh, Minh and one noninteractive dog calibration model. All models use C0 materials, grounded pivot rigs and data-defined character triangle budgets; the dog does not add Roadmap 8.5 follow/name/save behavior.
- Replace only the view-local `ChibiAvatar` mesh assembly with a pivot rig, `AnimationPlayer` clips (`Idle`, `Walk`, `Run`, `Tool`, `Sleep`, `Talk`), deterministic 8-direction facing, face/emotion API and code-built transient emotion bubbles. Bind the existing Player, Minh and Linh anchors only; do not create unplanned NPC gameplay actors for An/Lâm.
- Extend the existing new-game form with compact localized appearance selectors. Persist the selected cosmetic data through the existing profile round trip, apply it after New Game/Continue/load, and keep old two-argument test/caller compatibility. No new InputMap action, scene node, autoload, domain state, schedule, collision or save migration is planned.
- Add a character lineup/review runner with day/night four-angle sheets and a real `main.tscn` normal-renderer capture; add narrow GUT coverage for data validation, generated scene mesh audits, pivots/head ratio, animation clips, face/bubble API, old-profile fallback, save round-trip, player/NPC anchor preservation and three-resolution selector layout. Update API/ART/UI/decision/credits/progress docs and both locales.
- Planned C1 files only: `docs/{API_INDEX,ART_BIBLE,PROGRESS,DECISIONS,UI_LAYOUT,CREDITS,SCENE_CONTRACTS/art_lineup,SCENE_CONTRACTS/character_lineup}.md`; `scripts/{data/character_appearance_data,character_appearance_catalog,core/data_validator,view/chibi_avatar,character_face,emotion_bubble,npc_actor,npc_system,tool_action_controller,world_presentation,main,start_menu}.gd`; `data/art/characters/**`; `assets/generated/models/characters/**`; `tools/{art_review_characters.bat,build_chibi_characters.bat,capture_chibi_characters.bat,character_lineup.tscn,art/chibi/**}`; `tools/validate_data.gd`; `tests/unit/{test_chibi_characters,test_character_review_layout,test_ui_layout}.gd` (the prior exact three-child new-game-form assertion changes intentionally because the approved appearance form adds children); `localization/strings_{vi,en}.csv`; and generated `.uid` companions. Existing gameplay `.tscn` files, save service/schema, NPC data/schedules and Roadmap 8.5 behavior are out of scope.

## C1 completion and handoff (2026-10-28)

- Delivered a validated `CharacterAppearanceCatalog`: player appearance selection has six hair styles, six skin tones, six hair colors and six outfit colors. The optional normalized `profile.appearance` dictionary survives New Game, Continue and the existing v4 profile round-trip; old v4 profiles fall back deterministically without a schema bump.
- Delivered reproducible generated model scenes for player, An, Bac Lam, Linh, Minh and the visual-only dog calibration asset. Their measured triangle counts are player `2,808`, An `3,120`, Lam `2,820`, Linh `3,240`, Minh `2,820`, dog `2,052`, each under the `6,000` character budget with grounded pivots and finite geometry.
- Replaced the view-local avatar with the articulated chibi rig and view-only `Idle`, `Walk`, `Run`, `Tool`, `Sleep` and `Talk` clips, eight-way facing, distinct held hoe/watering-can/seed-bag/harvest-tool models, `CharacterFace` emotions and transient emotion bubbles. Successful existing farm actions and opening Minh dialogue trigger only these visuals; Player/Minh/Linh domain anchors and schedules remain authoritative.
- The normal-renderer review writes one six-model lineup plus six focused four-angle/day-night sheets to ignored `screenshots/chibi-characters/`, and captures the real `main.tscn` through the opt-in `--capture-chibi-characters` project argument. The capture uses an isolated in-memory review arrangement, never loads or writes a save slot.
- Three focused visual correction rounds were performed from those images. Actual issues found: (1) the first capture route compiled `main.tscn` without autoloads; (2) daytime/sunset prompt and name labels obscured the first real-scene review; (3) focused-sheet labels covered individual silhouettes; (4) the review camera was too high to inspect the face; and (5) generated face pieces were offset beyond the rounded head surface. The final tools launch the configured main scene, use a daylight/no-prompt in-memory showcase, suppress labels only for its capture, preserve the first 45-degree/35-degree game tile plus lower supporting views, and place a raised/compact hat and face features correctly on the head. Final review sheets show readable eyes, cheeks and individual accessories in daylight and night.
- Final verification before the C1 commit/tag: `tools\build_chibi_characters.bat` PASS; normal-renderer `tools\art_review_characters.bat` wrote 7 contact sheets and the real-scene PNG; `[check_parse] OK`; `[validate_data] PASS`; 47 scripts, 146/146 passing tests, 4,209 asserts, 22.931 s, `[run_tests] PASS`. The combined C1 build/review/capture/parse/validator/GUT/main log scan found 0 matches for `SCRIPT ERROR`, `Parse Error`, `Failed to load script` or `ERROR:`.

## C0 approved plan and allow list (2026-10-27)

- Create `docs/ART_BIBLE.md` and a data-owned `ArtPalette` Resource with one warm pastel, four-season palette in `data/art/palette/`. Validate the palette in the headless data gate.
- Add original generated shader/material foundations (toon/tinted shadow/rim, outline, foliage wind, water, dither fade) beneath `assets/generated/`; add a view-only material factory but do not alter `WorldPresentation`, `ChibiAvatar`, crops, UI, or existing scenes.
- Add deterministic primitive builders and mesh-audit helpers under `tools/art/chibi/`; use them to build five calibration scenes under `assets/generated/models/chibi_core/`, bounded by data-defined triangle budgets.
- Add the standalone `tools/art_lineup.tscn` tool scene, `tools/art_review.bat` contact-sheet runner, scene contract, and unit coverage for palette validation, shader/material load/render binding, generated scene loading, triangle budgets, bounds, pivots and review layout.
- Planned C0 files only: `docs/{ART_BIBLE,API_INDEX,PROGRESS,DECISIONS,CREDITS,SCENE_CONTRACTS/art_lineup}.md`; `scripts/{data/art_palette,core/data_validator,view/chibi_material_factory}.gd`; `data/art/palette/chibi_valley.tres`; `assets/generated/{shaders,materials,models/chibi_core}/**`; `tools/{art_review.bat,build_chibi_core.bat,art_lineup.tscn,art/chibi/**}`; `tools/validate_data.gd`; `tests/unit/test_chibi_art_foundation.gd`, Godot-generated `.uid` companions and the narrow `/screenshots/` ignore-rule addition. No existing game scene or runtime presentation script is in scope.

## C0 completion and handoff (2026-10-27)

- Delivered an original, data-driven `ArtPalette` (`chibi_valley`) with four seasonal role colors, chibi scale ratios and data-owned triangle budgets. The normal data validator loads it in the existing gate.
- Delivered five generated Godot 4.7 shader/material pairs (toon/tinted shadow/rim, inverted-hull outline, foliage wind, water and dither fade), an opt-in material factory, deterministic primitive builders and mesh audit coverage. Existing runtime presentation remains intentionally unchanged.
- Generated calibration scenes: character `672 / 6,000`, prop `100 / 1,500`, crop `128 / 400`, rounded building `300 / 8,000`, tree `220 / 1,000` triangles. Every scene loads, has finite grounded bounds, non-degenerate faces and is tested against its data budget.
- `tools\art_review.bat` now uses the normal RTX/Forward+ renderer and produces a labeled 4-angle × day/night lineup plus one focused 512 px-tile contact sheet per calibration model under ignored `screenshots/chibi-core/`. It fails on empty capture or parse/script/engine error text.
- Visual correction round 1 was reviewed from the generated sheets: models were initially too small; the grid/model/angle/light evidence was absent; shaders were not visible; building silhouette and shadow were harsh; and night was muddy. The tool now has compact two-row layout, 1 m grid, labels/captions, focused model sheets, generated toon/foliage/outline materials, a rounded building/softer shadow and brighter night. Round 2 caught inward normals on the first custom rounded meshes; winding was flipped and the final day/night sheets restore readable warm faces. A real `main.tscn` scene capture remains deliberately deferred to C1/C3 rather than being misrepresented as C0 evidence.
- Final verification before the C0 commit/tag: `tools\build_chibi_core.bat` PASS; normal-renderer `tools\art_review.bat` wrote 6 sheets; `[check_parse] OK`; `[validate_data] PASS`; 45 scripts, 137/137 passing tests, 3,996 asserts, 18.315 s, `[run_tests] PASS`. The combined build/review/parse/validator/GUT/main log scan found 0 matches for `SCRIPT ERROR`, `Parse Error`, `Failed to load script` or `ERROR:`. M0 smoke/autoplay/full-capture/baseline automation remains deferred per D28.

## Last commit / tag
`chore: persist Phase 8 scene resource serialization` — approved Godot 4 scene/resource canonicalization, isolated from gameplay feature work
`docs: add master production prompt` — moved the product-owner supplied master prompt into tracked documentation without changing its contents
`feat: add two-product harvest and drag farming` — data-driven two-product harvests, direct Harvest selection and de-duplicated mouse farming strokes
`feat: add original farm audio and grounded world polish` — reproducible farming effects, separated sale landmark, extra cottages, terrain detail and warm daylight
`npc-quests` — confirmed delivery and merchant transactions, Minh/Linh schedules, localized dialogue/journal, friendship, and save v4 migration

`feat: add chibi art foundation` / `chibi-core` — validated palette, generated shader/material suite, original calibration models and independent review tooling; no gameplay presentation migration
`feat: add chibi characters and customization` / `chibi-characters` — data-owned appearance options, generated character models, view-only rig/face/emotion/held-tool presentation and normal-renderer review capture; no save-schema, schedule or Roadmap 8.5 behavior change
`feat: add chibi farming art` / `chibi-farming` — data-owned crop families/stages, generated crop/item/tool assets and stickers, view-only soil/effects/readability plus normal-renderer review; no gameplay, economy or save-schema change
`feat: add chibi world presentation` / `chibi-world` — data-owned generated buildings/world props, bounded seasonal ambience, real-main-scene review and C3 interaction/anchor regression locks; no gameplay, economy or save-schema change
`feat: add chibi UI presentation` / `chibi-ui` — C0-palette runtime Theme, native tooltip styling, code-drawn cursor, focus/motion wiring and normal-renderer title/HUD review; no scene, gameplay, input or save-schema change

## Done
- [x] C3 chibi world: generated building/terrain/prop/critter art, bounded seasonal ambience, safe anchor/placement handling, normal-renderer review/capture and regression coverage (commit/tag recorded above)
- [x] C2 chibi farming: data-owned crop families/stages, generated crop/item/tool models and 128 px stickers, view-only soil/effects/readability, normal-renderer review/capture, interaction/icon regression coverage (commit/tag recorded below)
- [x] C1 chibi characters: player appearance selector, generated player/An/Bac Lam/Linh/Minh/dog-reference assets, articulated presentation, face/emotion bubbles, C1 review tooling and compatibility coverage (commit/tag recorded above)
- [x] `docs/MASTER_PROMPT.md` added from the root prompt source, byte-preserving in UTF-8 (commit `215d2d6`)
- [x] Master plan written (reference copy: `docs/reference/THE_LIFE_MASTER_PLAN.txt` — not read every session)
- [x] Repo starter docs integrated into the existing project
- [x] MVP scope confirmed: gray-box farming loop through harvest
- [x] Godot 4.7.2-stable, Forward+, Jolt Physics, PC Windows target confirmed
- [x] Camera confirmed: orthographic, yaw 45°, pitch 35°
- [x] Open Sans regular font copied for the Vietnamese UI
- [x] GUT 9.7.1 installed and headless smoke tests configured
- [x] GridMath implemented with boundary, negative-coordinate and footprint tests
- [x] InputMap, physics layer names and foundation autoloads configured
- [x] Gray-box world scene with orthographic camera and placeholder farm plot created
- [x] Smooth camera follow and player/map bounds added

## Historical handoff notes
- 2026-10-27 crop-yield and drag-farming follow-up completed (player-approved). Every current crop Resource has `yield_qty = 2`, validator rejects non-positive data, and the existing harvest payload/inventory path now visibly grants two products for each mature crop. Holding left use across reachable cells plants, waters or harvests each cell once; click/default hoe inspection, keyboard use, modal locks, reach checks and inventory-capacity blocking remain intact. Harvest is now a selectable direct tool mode. The formerly pending `data/npcs/phase8_world.tres` and `scenes/main/main.tscn` reserialization was explicitly approved and committed as `3a4be46`.

## Requested M0 cleanup / M1 completion handoff (2026-10-27)

- `docs/MASTER_PROMPT.md` was added in its own commit `215d2d6` after SHA-256 equality with the root source (`7F9FBD9D75F3C721E1E4BFA69753B2AD48829573836EB2D894F68294AC7C0E45`). The root copy was moved, not duplicated.
- The former `data/npcs/phase8_world.tres` and `scenes/main/main.tscn` diffs are Godot serialization canonicalization (UIDs, resource ordering, values equal to script defaults, empty packed arrays as `null`, node unique ids, anchor presets and property ordering). The product owner explicitly approved retaining them; they are now isolated in `3a4be46`, rather than being represented as new NPC gameplay.
- Final official verification after `3a4be46`: `[check_parse] OK`, `[validate_data] PASS`, 44 scripts, 132/132 tests passing, 3,882 asserts, 17.772 s, `[run_tests] PASS`, with no captured `SCRIPT ERROR`, `Parse Error`, `Failed to load script`, or `ERROR:` text.
- Read-only M1 audit found no missing requested feature: conditional data dialogue/journal, confirmed atomic delivery/shortage safety, friendship and heard dialogue persistence, Minh's seeded data offer with isolated prices, all-four-season/rain/night schedules/routes, save v4/migration/golden coverage and validation are already implemented. `npc-quests` already exists at `8a30283`; do not move it.

## NEXT

- Start C5 (chibi audio / M8) only in a fresh task/conversation: read `docs/MASTER_PROMPT.md`, `docs/CHIBI_STYLE_PROMPT.md`, this file, `docs/ART_BIBLE.md`, `docs/API_INDEX.md`, `docs/DECISIONS.md` and every touched scene contract first. Audit the existing four farming WAV effects/AudioService before extending audio; preserve all C0–C4 generated paths, UI modal/input authority, FarmView/crop picking, DayNightProfile/weather authority and save v4. Do not quietly add gameplay systems, scene ownership changes or a new audio authority.
- Before a release claim, separately return to the deferred M0 automation named by `docs/MASTER_PROMPT.md`: `smoke_run`, autoplay, full capture matrix, baseline measurements/tag and global `build_assets`. Do not retroactively describe C0's isolated contact-sheet runner as that complete M0 suite.

## Chibi-style prompt reference handoff (2026-10-27)

- Added `docs/CHIBI_STYLE_PROMPT.md` from the product-owner supplied prompt. It is a visual-production reference for the future C0–C6 sequence; this documentation-only task does not start C0/M2, regenerate any model, or change runtime logic, IDs, resources, scenes, saves, tests, or current Phase 8 scope.
- The prompt intentionally retains its reference to `docs/MASTER_PROMPT.md`, which is now tracked in commit `215d2d6` after the product owner explicitly authorized moving the root source. Future sessions read both prompt files before continuing from this document.
- Project authority remains `AGENTS.md`, `docs/PROJECT_RULES.md`, approved Roadmap/task scope, and existing decision records. This prompt is not permission to bypass milestone order, scene ownership, save compatibility, or tests.
- Verification for this docs-only commit: `[check_parse] OK`, `[validate_data] PASS`, 44 scripts, 132/132 passing tests, 3,882 asserts, 17.974 s, and `[run_tests] PASS`. The captured runner output contained no `SCRIPT ERROR`, `Parse Error`, `Failed to load script`, or `ERROR:` text.

## Two-product harvest and drag farming handoff (2026-10-27)

- Assumption implemented: “one seed grows into two” means one valid planting consumes one seed and a mature crop grants two product items, rather than spawning two separate plot instances. This is data-owned in the nine crop `.tres` resources; no save migration is required because planted plots store only `crop_id` and harvest reads current crop data.
- Input behavior: select Seed, Water or Harvest, hold left mouse and move through reachable farm cells. A stroke visits each cell at most once even if the pointer returns over it. Default Hoe click on a planted crop continues to open CropInspector; direct Water/Harvest modes act on crops. Space/key use remains a one-cell action. No new InputMap action or auto-farming timer was added.
- Focused coverage: the new SubViewport input regression performs Seed → Water → mature → Harvest across two cells and returns over the first one; it verifies two seeds are consumed, watering occurs once per crop, harvest adds four turnips total and harvest mode does not open the inspector. Crop/data/year tests assert data-defined quantity 2, capacity protection and sale quantity. Validator now rejects `yield_qty <= 0`.
- Real final official runner:

```text
[check_parse] OK
[validate_data] PASS
Scripts              44
Tests               132
Passing Tests       132
Asserts            3882
Time              17.878s
---- All tests passed! ----
[run_tests] PASS
```

- Error-text scan across parse, validator, GUT and main-scene logs: `0` matches for `SCRIPT ERROR`, `Parse Error`, `Failed to load script`, or `ERROR:`. The requested yield doubles current sale output without changing any price; the full-year simulation remains green, but a future data-only economy balance pass should recalibrate profit targets rather than hiding this change in code.
- 2026-10-27 presentation/audio follow-up completed (approved player scope; mechanics unchanged). Delivered: four reproducible original WAV effects for the existing hoe/seed/water/harvest calls; AudioService resolves OGG first then WAV and honors saved effects volume. The selling bin and its marker moved together to `(5.2, 0, 10)`, over 4 m from the cottage bed marker; the seed stall stays fixed. Two non-interactive cottages, grass tufts and a stone path distinguish village places. Farm cells now present dry tilled furrows and a subtle wet sheen, and warm low-cost fog/shadow/ground tuning improves sunlight without taking clock or weather authority. No domain, economy, growth, save, time, reach or input behavior changed.

## Presentation/audio follow-up handoff (2026-10-27)

- Files: original audio source/rebuild script `tools/build_audio.gd`; generated `assets/audio/{hoe,seed,water,harvest}.wav` plus Godot import metadata; `scripts/core/audio_service.gd`; view-only `scripts/view/soil_presentation.gd`, `farm_view.gd`, `world_art_factory.gd`, `world_presentation.gd`; the documented world-anchor scene movement, focused tests, and API/layout/scene/credits/decision docs.
- Automated coverage: audio files resolve and load as `AudioStream`s; a normal tool sound creates a player; bin mesh/marker remain aligned at the separated sale point; cottages/path/ground dressing exist; warm sunlight properties are present; tilled/watered soil adds only the expected view meshes. Existing shipping-bin reach, shop, crop, interaction, save and year-economy coverage remain in the full suite.
- Real final official runner:

```text
[check_parse] OK
[validate_data] PASS
Scripts              43
Tests               131
Passing Tests       131
Asserts            3857
Time              17.811s
---- All tests passed! ----
[run_tests] PASS
```

- Error-text scan across the generator, parse, validator, GUT and main-scene logs: `0` matches for `SCRIPT ERROR`, `Parse Error`, `Failed to load script`, or `ERROR:`. Godot imported the WAVs using `--headless --import`; the generated `.wav.import` files are tracked. No manual game-window automation was run because the player is using the existing game window.
- Manual check: stop an old run, F5 and Continue/New Game. Use hoe, seed, watering can and harvest on reachable plots to hear four gentle effects; change Effects volume in Settings and repeat. Walk to the new sale-bin location south-west of the cottage and press E; verify sell panel opens. Visit cottage, seed stall, village homes and farm at morning/afternoon/rain/night; ensure all markers still show only their existing prompts. Tilled soil should have raised rows; watered planted soil should appear darker with a small sheen.
- 2026-10-27 world-art pass, requested after the compact HUD review. Delivered: view-only native low-poly crops are distinct by family (sprout, roots, tomato, pea, corn, wheat, pumpkin, cabbage, wilted); healthy crops have a minimal sway and watered crops show dew. Existing crop root meshes and CropInspector remain the only click/detail path. Existing House, SeedShop, ShippingBin and NPC-home anchors now render as separate cottage/market/bin structures, and four exterior rock/moss clusters make the map edge less empty. Filmic color, restrained glow/fog and softened directional shadows improve daylight while retaining DayNightProfile/weather ownership and night house lights. No domain, timing, save, marker, collision, input or `.tscn` change.
- Visual/manual evidence: launched the real 1152x648 game on 2026-10-27, used Continue, and inspected the daylight world: cottage, separate awning seed market, NPC homes, terrain rocks, compact HUD and farm grid appeared with no overlapping HUD or missing interaction surfaces. A user input event was then detected, so automation stopped without further game input. Automated proof is `test_world_presentation.gd` plus the normal interaction/layout suite.
- The player added `Prompt tổng hoàn thiện game The Life.md` at the repository root (currently untracked/user-owned) and supplied the same Downloads copy. It was read as a long-term product reference, not treated as authority over `AGENTS.md`, `PROJECT_RULES.md`, Roadmap order, scene ownership or current user scope. Its direct art guidance matches this completed view-only pass; its suggested generator/palette/shader pipeline is a separate next milestone.

## World-art pass handoff (2026-10-27)

- Delivered files: `scripts/view/{crop_presentation,world_art_factory,farm_view,world_presentation,npc_system}.gd` and generated `.uid` files; `tests/unit/{test_world_presentation,test_game_feel}.gd`; `docs/{API_INDEX,DECISIONS,PROGRESS,UI_LAYOUT,SCENE_CONTRACTS/gray_box_world}.md`. The player-owned root prompt file is deliberately not part of this art commit.
- Acceptance: crop meshes are now family-specific and stateless; their existing root bound remains the click target. The map renders a cottage at the house anchor, a visibly separate seed-market stall, a distinct bin, decorated Minh/Linh homes and four non-colliding edge rock clusters. Lighting is limited to Forward+ Environment/sun parameters and leaves data-driven clock/weather behavior intact.
- Automated coverage: `test_world_presentation.gd` checks visual children, unchanged shop/bin marker positions, decorated NPC homes, exterior-rock exclusion from the 6×6 farm, Forward+ post-processing/shadow configuration, sprout-to-mature change and cleanup after harvest. The earlier game-feel test was changed only because it deliberately asserted the superseded BoxMesh implementation; it now asserts a taller mature crop and recognizable sprout/root nodes.
- Real final official runner (backgrounded only to avoid the host command's 30 s transport cap):

```text
[check_parse] OK
[validate_data] PASS
Scripts              42
Tests               129
Passing Tests       129
Asserts            3830
Time              18.46s
---- All tests passed! ----
[run_tests] PASS
```

- Error-text scan across parse, validator, GUT, main-scene and runner logs: `0` matches for `SCRIPT ERROR`, `Parse Error`, `Failed to load script`, or `ERROR:`. Visual manual smoke: started the actual game at 1152×648, pressed Continue, and checked the daylight world. Do not automate the still-open game further: an input event from the user was detected during a later debug-menu attempt.
- Known limits / NEXT: this is a low-poly presentation pass, not the full `world-v1` or M2 art-foundation milestone. A separate next task should add the reproducible palette/material/generator framework, then a purpose-built screenshot/performance harness before expanding terrain, water, audio or future Roadmap systems. No claim is made that later Roadmap phases are complete.
- 2026-10-27 compact HUD/crop inspection task, approved standing plan-then-proceed workflow: hide the nine item-slot grid and caption in normal gameplay, keep a small four-tool strip and smaller corner menu buttons; expose selectable items only in the inventory modal. Add a nonmodal CropInspector view (large localized name, countdown, estimated game-day/morning, water/ready/withered status) on crop click; hide repetitive world-space crop labels. Reuse GameClock time_changed/FarmGridState queries and existing tool/harvest APIs, with a conditional daily-watering estimate and no save/growth changes. Files: scripts/view/{hotbar_panel,inventory_panel,main,ui_layout,ui_coordinator,tool_action_controller,farm_view,crop_inspector}.gd (+ new .uid), localization/strings_{vi,en}.csv, tests/unit UI/crop regressions, docs/{API_INDEX,PROGRESS,UI_LAYOUT,DECISIONS}.md and screenshot evidence. Initial workspace has two generated docs/screenshots/*.png.import metadata files; preserve them. Verify default HUD footprint, inventory mouse selection, crop click/action routing, minute/day countdown, watering/ripeness/removal, modal suppression and three resolutions in vi/en before the task commit.

## Compact HUD/crop countdown handoff (2026-10-27)
- Acceptance delivered: default item grid/caption hidden; tool strip is 220×60 and menu strip 216×60 at 1152×648; readable item selection appears only inside inventory. Selecting an inventory row closes it, selects the existing stack for use and never changes quantity. 1–9 shortcuts remain.
- Crop click opens a readable lower-left card with localized name, 24 px countdown, expected game day/morning and water state. It updates on GameClock.time_changed and FarmGridState.plot_changed, stays nonmodal and does not pause the clock. World labels remain API-compatible but hidden. Visual crop bounds, not just ground-ray cells, determine clicks on taller crops.
- Countdown assumption: remaining watered growth-day boundaries, daily care and a suitable season, using current GameClock data. It is an estimate in game time, not real-world seconds or offline progress; skipping water delays the forecast. Ready/withered states replace the timer. Water/Harvest buttons route through existing reach/locked-input/harvest capacity checks. No growth logic, economy, scene file or save schema changed.
- Six new regression tests cover physical crop clicks with no accidental tool use/consumption, minute countdown, daily growth and missed watering, inventory selection, mature crop top picking, withered/out-of-reach safety, removal after harvest, modal suppression, and vi/en layout at 1152×648 / 1280×720 / 1920×1080. Old world-label/hotbar geometry assertions were deliberately updated for the requested hidden UI; lifecycle text, tool bounds and gameplay invariants remain checked.
- Real final official runner:

```text
[check_parse] OK
[validate_data] PASS
Scripts              41
Tests               126
Passing Tests       126
Asserts            3789
Time              15.565s
---- All tests passed! ----
[run_tests] PASS
```

- Separate headless GUT: 41 scripts / 126 tests / 126 passing / 3716 asserts / 8.904s. Rendered-only PNG assertions explain the assertion-count difference. Player save slots 0/1 and backups were preserved/restored around both suites. No lint installation was performed.
- Manual editor steps: none. Stop old game/F5 → Continue. The map has no expanded item slots. Open backpack/I → Select a seed → inventory closes → plant as before. Click a planted crop → inspect countdown/water state → Water, wait game minutes or sleep, inspect again → Harvest when ready. Full modal opening hides the crop card. Check close button, far-away crop feedback, missing watering and full inventory. Human playtest remains pending; automation exercised physical press/release events in isolated viewports and rendered both languages/sizes.
- Screenshot evidence: docs/screenshots/compact_hud.png and crop_inspector.png. API_INDEX and UI_LAYOUT describe the view contract; D24 records the presentation/forecast decision. Proposed/used task commit: `fix: compact HUD and inspect crop harvest countdown`. Exact task diff is available against a741cfa; existing milestone tags are retained.
- Active request (2026-10-26): fix completely unclickable menus, then redesign title/HUD with cozy chibi art/icons and lightweight animated models; audit the whole project and proceed through missing milestones. User authorizes this broader visual scope. Immediate plan: reproduce physical mouse click failure; repair backdrop/input dispatch and start/continue entry; add SVG icons, generated title illustration and pastel UI; add procedural chibi presentation with gentle animation; verify real mouse/key paths and vi/en layouts at three sizes. Runtime scripts/assets only, no scene edits needed. File scope expands to scripts/view/, assets/icons/, assets/ui/, tests/unit/, docs/, localization/. Gameplay completion proceeds separately in Roadmap order; human gates cannot be asserted passed automatically.
- UI readability/overlap repair implemented after Phase 8 playtest screenshots; automated checks pass, human re-test pending.
- Approved execution process continues: record plan then implement without another approval. UI-only file scope: scripts/view/{main,debug_menu,hotbar_panel,inventory_panel,seed_shop_panel,shipping_bin_panel,start_menu,npc_actor,npc_system,ui_coordinator,ui_layout}.gd, their new .uid files, tests/unit UI regression/layout tests, localization/strings_{vi,en}.csv, docs/{API_INDEX,PROGRESS,UI_LAYOUT,DECISIONS}.md. No scene, shared Theme file, domain, economy, weather or save-schema changes.
- Plan: a view coordinator owns modal exclusivity/input/prompt suppression; a runtime layout/theme helper applies readable 18 px typography, responsive central panels and opaque surfaces using existing nodes; repair inventory/hotbar list sizing and permanent close/actions; test real key sequences, full inventory/shop lists, settings and modal switching at 1152x648, 1280x720, 1920x1080 in vi/en, then run official/headless suites and inspect rendered screenshots.
- Risks: old layout tests assume multiple simultaneous panels and tiny dimensions; update those expectations only where the new intentional modal/layout contract changes, retain all containment/readability checks. Runtime theme is duplicated, leaving the shared .tres outside the ALLOW_LIST untouched. Keep npc-quests tag intact; use a separate UI fix commit under the user's standing one-task/one-commit workflow.

## Chibi UI and mouse regression handoff
- Acceptance delivered: actual mouse clicks work in title/settings/new-game/inventory/shop; title always opens before gameplay; Continue accepts slot 0 or 1; New Game starts a clean farm/wallet/clock/onboarding/weather/social state; existing save v4 is unchanged.
- Root cause: ModalBackdrop was rendered behind buttons using z_index but placed after them in sibling GUI hit order. It intercepted mouse input. Now it is the first child, and modal/NPC input handlers leave mouse events to GUI. A regression test temporarily restoring the old order fails 0/2; fixed order passes. GUT overlay is excluded using an isolated SubViewport; tests inject real motion/left-button press/release events rather than emitting pressed signals.
- Visual delivery: assets/ui/title_valley.png generated with built-in image_gen (final prompt in title_valley.prompt.txt); 22 original SVG icons under assets/icons; cream/sage rounded theme; backpack/help/journal/pause and tool icons; item artwork in hotbar/inventory/shops; localized tooltips/full-name caption; compact icon bar; title art with subtle motes. The illustration is copied into the project and does not depend on the generation cache.
- Model delivery: ChibiAvatar procedural meshes for player/Minh/Linh, straw hat/backpack/face and idle/walk motion; WorldPresentation cottage, stall, shipping chest and ornamental trees. These are runtime mesh assemblies, not imported GLB files or completed character animation rigs. Domain state, collision anchors, season/weather/lighting profiles and scene files are unchanged. Title-art puppy is not a dog gameplay implementation.
- Windows computer-use verification completed on a separately launched game window: mouse-click Settings → New Game → Confirm → Got it → backpack icon → Close inventory. Observed clock advance from 06:00 to 06:26 and resume after closing. Closed only that verification window through its normal exit handler; editor was left open.
- Final full official runner:

```text
[check_parse] OK
[validate_data] PASS
Scripts              40
Tests               120
Passing Tests       120
Asserts            3781
Time              16.894s
---- All tests passed! ----
[run_tests] PASS
```

- Separate headless: 40 scripts / 120 tests / 120 passing / 3720 asserts / 8.928s. Final compact icon-bar layout rechecked afterwards: 2 scripts / 5 tests / 5 passing / 1278 asserts / 9.603s, both locales and three viewports. Current parse/validator/GUT/main/mouse/headless/final-UI logs: 0 SCRIPT ERROR / Parse Error / Failed to load script / ERROR: matches. git diff --check passes. Full-suite wrapper preserved/restored player slots 0/1 and backups byte-for-byte; new save-interaction tests preserve their own slot payloads too.
- UI tests were deliberately adapted only for new presentation semantics: hidden name labels no longer count as visible geometry (icons plus tooltips/caption replace them); weather HUD test enters gameplay because title screen now intentionally hides it. Original inventory, transaction, save, schedule and full-year invariants remain.
- Manual editor steps: none. Stop an old game instance and F5. Verify title click/New Game/Continue, backpack/help/journal/pause icons and close buttons; hover icons for labels; select keys 1–9; buy/sell; watch character idle/walk. Screenshots: docs/screenshots/chibi_title.png and chibi_hud.png. Human follow-up: play a 10–15 minute farm loop for Gate A evidence.
- Whole-project audit and remaining work: docs/PROJECT_AUDIT.md (phase coverage, source findings and execution order), docs/SOURCE_AUDIT.md (project-owned source/content inventory and methods). The game is still an MVP; economy ledger/orders, production/building, ecology/director, dog/story, full map/audio, export, online and release are not marked complete. Gate A/B require human/stranger playtests. Do not silently skip these gates or treat unchecked ROADMAP boxes as a reliable implementation inventory.
- Commit message for this task: `fix: restore mouse input and add cozy chibi presentation`. Review complete diff against 5c87cd5. Existing npc-quests tag is retained.

## UI repair results and handoff
- Fixed the reproduced inventory/pause/debug stack with UiCoordinator; one active panel through keys, HUD buttons and programmatic opens. Prompt and secondary HUD hide behind modal surfaces, Esc closes the active panel, I/H/J/Ctrl+M switch cleanly. New Game/help are separate; settings/name-entry forms are exclusive and repeated New Game clicks cannot duplicate Confirm.
- Duplicated runtime Theme: 18 px body, 24 px headings, opaque surfaces, 40+ px buttons; nine large hotbar slots with 16 px names, 18 px full-name caption and readable world NPC/home labels. All inventory slots remain in the scrollable inventory. Shop/bin changes affect list sizing and display only; transaction methods are unchanged.
- Fixed deferred minimum-size reflow so hidden/rebuilt content cannot leave oversized panels covering the HUD. Inventory close header, trade footer and debug close button stay available. Long lists and NPC text/actions scroll.
- Real official runner output (2026-10-26):

```text
[check_parse] OK
[validate_data] PASS
Scripts              39
Tests               115
Passing Tests       115
Asserts            3818
Time              12.166s
---- All tests passed! ----
[run_tests] PASS
```

- Separate headless GUT: 39 scripts / 115 tests / 115 passing / 3758 asserts / 6.147s. Rendered runs include 60 PNG-save assertions. Final scan of parse, validator, GUT, main, headless and UI capture logs: 0 matches for SCRIPT ERROR / Parse Error / Failed to load script / ERROR:. git diff --check passes. gdtoolkit remains unavailable and was not installed.
- Updated tests intentionally replace the old simultaneous-modal geometry assumptions with actual single-modal behavior, retain HUD non-overlap/containment, and add full inventory/shop lists, expanded pause/start settings, repeated New Game clicks, real modal shortcut sequences, viewport/button bounds, both languages and all three resolutions. Onboarding still checks every original binding and opt-out; it explicitly opens help after the start screen, matching the new exclusive flow.
- Manual editor steps: none. F5, start/continue, then I → Ctrl+M → H → J → Esc. Only one panel should appear, all text should be readable, Esc should return to play without another hidden menu. Open buy/sell panels, scroll lists, verify Close/Confirm stay visible; compare 1152x648/1280x720/1920x1080. Verify New Game/settings fields and scroll a full inventory. Human confirmation remains pending.
- Review diff: `git diff npc-quests..HEAD` after the separate UI commit. Commit message: `fix: improve UI readability and modal exclusivity`. No new milestone tag; existing npc-quests remains unchanged.
- Rendered evidence: user://ui_repair_{hud,InventoryPanel,PauseMenu,DebugMenu,TutorialPanel,SeedShopPanel,ShippingBinPanel,StartMenu}_{vi,en}_{1152x648,1280x720,1920x1080}.png; targeted capture uses -gopacity=0 so GUT does not obscure the game.

## Done
- [x] Reusable interaction prompt anchored to the viewport with readable background and outline
- [x] Prompt integration tests for near/far player positions and visible text
- [x] Debug-only Ctrl+M menu with clock, player position, FPS, time controls and extensible action registry
- [x] GameClock debug time and speed APIs with tests
- [x] Overnight sleep runs at x20 until 06:00, then restores the previous time speed
- [x] Daytime sleep prompt and interaction are hidden/no-op
- [x] Clock display wraps overnight hours to 00:00, 01:00 and 02:00 instead of showing 24:00+ or 25:00+
- [x] HUD and debug menu use the shared GameClock.format_time() formatter
- [x] Sleeping continues through displayed 00:00–05:59 and finishes at 06:00; awake rollover at 02:00 remains unchanged
- [x] InventoryState supports capacity, stacking, add/remove validation, signals and save serialization
- [x] DataRegistry loads temporary seed and harvest item definitions from Resource data
- [x] Basic inventory panel opens with I and debug menu can add seeds or clear the inventory
- [x] Shared HUD button bar adds a mouse inventory button with tooltip, active state and sleep lock
- [x] DataValidator checks item resource presence, unique IDs, snake_case IDs and positive max_stack values
- [x] Hotbar displays inventory stacks and selects non-empty slots without mutating quantities
- [x] Hotbar redraw is safe during inventory updates and button signals; 3.3 tests pass
- [x] Localization autoload loads Vietnamese and English CSV translations; UI labels use `tr()`
- [x] Official runner discovers Godot at `D:\godot\Godot_v4.7.2-stable_win64.exe`, uses bounded non-debug runs, scans error text, and starts the main scene headless
- [x] FarmGridState parse/runtime error fixed; 4.1 lifecycle tests pass
- [x] FarmView builds a visible GridMath-aligned placeholder grid and updates soil/crop visuals from domain signals
- [x] ToolData and ToolAction support hoe, watering and seed actions with reach checks
- [x] Hotbar tool buttons select actions; target highlight distinguishes reachable and unreachable cells
- [x] World tool input is handled through unhandled input and is blocked by inventory, debug menu and sleep
- [x] Mature crops preview their harvest, deliver products to InventoryState, and remain planted when the full inventory blocks delivery
- [x] DaySimulator advances only watered crops and dries plots; Main connects it to GameClock.day_started
- [x] Debug menu includes seed, hoe-all, water-all, grow-one-day and reset-farm actions
- [x] SaveService writes versioned JSON atomically, rotates three backups and ignores corrupted/future saves safely
- [x] Debug menu exposes localized save/load actions; Main restores clock, player, inventory and farm state
- [x] HUD regions use anchors and containers; layout tests cover 1152x648, 1280x720 and 1920x1080
- [x] First-run controls guide uses InputMap bindings, H and HUD `?`, with persistent opt-out in Settings
- [x] New players receive turnip seeds and the farming checklist tracks domain events through harvest
- [x] Onboarding checklist is included in save/load state
- [x] Hotbar slots use contained key/name/quantity labels without overlap at all supported viewport sizes
- [x] FarmView grid fits the brown FarmPlot and its projected centers avoid UI and the house at supported viewport sizes
- [x] Vietnamese is the default locale; item and crop names use translation keys with complete English/Vietnamese CSV coverage
- [x] Shared 14 px UI Theme, compact help modal, quest suppression and three-resolution all-panel layout tests
- [x] Official runner verified after UI polish: 21 scripts, 61 tests, 61 passing, 1185 asserts
- [x] Godot-generated `.uid` files are tracked project metadata and are not ignored
- [x] Pause menu, start menu, profile names, autosave slot 0 and save notification are implemented
- [x] Game-feel feedback includes animated item/invalid-action messages, soil response, crop growth stages and optional AudioService
- [x] NV1 pause/start menus include settings, profile naming, slot 0 autosave and save toast
- [x] NV2 optional audio naming is documented in `CREDITS.md`; missing audio files are silent
- [x] Autosave writes after exit, every 60 real seconds, and after debounced farm/inventory changes; Continue selects the newest valid save
- [x] Crop labels show localized remaining growth days, watering need and harvest readiness above each crop
- [x] DayNightProfile interpolates data keyframes and applies sun, moon, ambient, sky and house lighting to the gray-box world
- [x] WeatherState stores seeded current weather and forecast, rain waters crops, HUD/debug controls and placeholder rain FX are wired
- [x] Four data-defined 28-day seasons update GameClock, HUD and save state; crops reject wrong-season planting and can wither/clear
- [x] Distinct items and seeds for all 9 crops with differentiated buy/sell values, colors and DataValidator integrity checks
- [x] Season-based starter seeds guaranteed at new game start to prevent softlocks in the initial planting tutorial
- [x] WalletState domain state (coins, add, remove, can_afford, signals, serialize) with top-left WalletHud display
- [x] Shipping bin 3D interactable near house with [E] prompt, modal produce selector, quantity controls and immediate sale payouts
- [x] Seed shop 3D interactable with [E] prompt, current season filtering, out-of-season dimmed notes, and atomic transactions
- [x] Tutorial quest expanded to 7 steps (selling produce and buying seeds) and debug menu economy controls added (add coins, add all seeds)
- [x] Save schema bumped to save_version 3, backward-compatible migration for v1 and v2 saves, and save_v3 golden fixture
- [x] Integration test simulates an entire 4-season year: buying seeds, planting, watering, sleeping, harvesting and selling with non-negative wallet invariants
- [x] Official runner verified after economy milestone: 33 scripts, 97 tests, 97 passing, 2325 asserts
- [x] Phase 8 request: confirmed all-or-nothing delivery through existing wallet/inventory APIs; no shortage consumption, no duplicate payout, reward capacity checked after removal
- [x] Minh's seeded daily resource offers; finite stock persists across load; original item prices and existing full-year simulation unchanged
- [x] Minh/Linh placeholder actors follow AStarGrid2D routes, seasonal/weekly schedules, DayNightProfile night threshold and rain/home override
- [x] E dialogue, J journal, named NPCs, explicit quest/trade buttons, localizable feedback, debug quick-test buttons and modal input/clock locking
- [x] Save v4 social payload and v3 migration; old golden v1/v2/v3 retained; active/completed quests, friendships, heard dialogue, talk days, positions and used merchant offers round-trip
- [x] Final official runner: 39 scripts / 113 tests / 113 passing / 2850 asserts; parse/validator/main smoke PASS; headless GUT: 113 passing / 2838 asserts (12 PNG assertions apply only to rendered runs)

## Known issues / tech debt
- GUT 9.7.1 is installed under `addons/gut` for Godot 4.7.x.
- NPCs and their homes are simple placeholders; interiors, dog and Chapter I quest content are outside this slice. NPCs walk home before hiding; indoors NPCs cannot be spoken to in this placeholder version.
- Night follows the shared profile's moon-energy threshold (0.14 in NPC data), so it overrides Minh's nominal 22:00 visit end. Scheduled visits remain days 3/6 of each week, per Roadmap and D21.
- Dialogue pauses the clock; no periodic save while it is open. Closing marks the save dirty; exiting closes it and then saves at a safe point.

## Decisions since last update
- D08 and D13 confirmed from the submitted project form.
- Placeholder geometry is allowed until the developer supplies final models.
- HUD layout is documented in `docs/UI_LAYOUT.md`; prompt sits above the hotbar and inventory is centered with a close button.
- Hotbar item slots use a two-row responsive container and reserve space above the bottom HUD regions.
- Farm grid cells are inside the brown plot; red target highlighting means the selected tool is out of reach, green means usable.
- Player-facing item and crop names are stored as translation keys and rendered through `tr()`; Vietnamese is selected on startup when no settings override exists.
- UI uses `scenes/main/ui_theme.tres`; the help panel is limited to 36% viewport width and hides the quest panel while open.
- Pause and start overlays use the same Theme and are included in the documented modal layout; start menu blocks world input until a game is started or continued.
- While sleeping, debug set-time, set-speed, pause and next-day actions are ignored. This keeps the sleep state deterministic and prevents a debug action from leaving the player locked or the clock stuck at x20.
- Autosave uses slot 1 for active-progress recovery and selects the newest valid save between slots 0 and 1 using `saved_utc`.
- Crop status is rendered as world-space billboard `Label3D` with depth testing disabled so it remains readable above placeholder crops.
- The requested day/night, weather and season work is intentionally being delivered before Roadmap phases 7 and 11 per D19.
- Save schema is now v3: wallet is persisted, and v1/v2 saves migrate smoothly with default starting coins per D20.
- Out-of-season seeds in the seed shop are displayed dimmed and disabled with a localized season note to guide player purchasing.

## Open `<<FILL>>` items (must be empty before roadmap task 0.1)
- gdtoolkit 4.3.0 is selected but not installed yet

## Next up (agent proposal)
- MVP farming loop and the requested first polish pass are complete; final models and audio assets remain developer-supplied.
- Human: run the Phase 8 manual checklist below. Do not advance to dog/Chapter I or change the Roadmap status based on automated tests alone.

## Phase 8 execution plan (approved by product owner, 2026-10-26)
- Task 4 save domain verified: v4 social payload, explicit migrate_3_to_4, old golden fixtures retained, golden v4 added; v1/v2/v3 preserve onboarding/profile/farm/inventory/clock/player and wallet/weather. Dedicated tests cover unknown ids/types, friendship clamping, daily talk persistence, completed quests and merchant consumed days. The final headless run passes 39 scripts / 113 tests / 2838 asserts. Existing save-version assertions now expect v4 deliberately, with all original field checks retained.
- Task 3 domain verified: 36 scripts / 105 tests / 105 passing / 2667 asserts; full runner PASS. Four seasons, weekly visits, rain/night home override, obstacle avoidance and rebuilt routes after load covered. Fixed a signal-lambda reference cycle found by the error-log scan; final run has no resource-leak error. NPC visuals/dialogue are integrated in Task 4.
- Task 2 verified: 35 scripts / 103 tests / 103 passing / 2373 asserts; all runner stages PASS, including unchanged full-year economy simulation. Merchant stock is saved and finite; discount/request prices are isolated. Added missing DetRandom under the allowed domain folder (no existing implementation existed). Initial new-class cache error resolved by headless editor import; corrected an incorrectly transcribed golden seed against independent integer calculation (1466485800), no production algorithm changed for the test.
- Task 1 verified: 34 scripts / 100 tests / 100 passing / 2345 asserts; parse, data validation and main smoke PASS. Delivery preview accounts for exact freed slots; confirmation rejects null wallet, shortage, oversized rewards and duplicate/reentrant payout.
- Baseline: parse, validator, main smoke and GUT pass: 33 scripts / 97 tests / 2325 asserts; error-text scan zero matches. Existing NPC/quest base is committed separately; it is not yet integrated or covered by dedicated tests.
- Task 1: harden `scripts/domain/quests/quest_manager.gd`, add delivery tests in `tests/unit/`: explicit confirmation, all-or-nothing requirements/rewards using existing wallet/inventory APIs, reject duplicate payout and full reward inventory.
- Task 2: `scripts/data/merchant_offer_data.gd`, `data/npcs/`, `data/shops/`, `scripts/domain/quests/merchant_service.gd`: data-defined daily offer, deterministic selection, independent pricing; preserve the existing full-year test unchanged.
- Task 3: NPC/dialogue data and pure schedule/relationship/dialogue state under `scripts/data/` and `scripts/domain/quests/`; AStarGrid2D routes from data-defined cell locations, home at night and in rain, four-season and load tests. Views only animate routes.
- Task 4: `scripts/core/save_service.gd`, `scripts/view/main.gd`, new NPC UI/view scripts, `scenes/main/main.tscn` additions only, localization, validator and tests: integrate NPC dialogue/journal (J), debug actions, v4 social payload and v3 migration preserving onboarding, golden v4; layout checks at 1152x648, 1280x720 and 1920x1080.
- Documentation: API_INDEX, PROGRESS, DECISIONS, UI_LAYOUT, INPUT_MAP; no edits to farm/tools/weather/day-night/wallet/shop/bin implementations, no additional autoloads, no registry changes beyond the already committed base.
- Scope follows Roadmap 8.1–8.4 for this request; 8.5 dog and 8.6 Chapter I content remain separate tasks. Merchant visits obey the Roadmap schedule; a daily offer is selected every day but is available only while Minh is at the market. Night/rain override visits. See D21.
- Risks: atomic delivery must preview inventory after removal; retain the existing `quests` onboarding save field and add a separate social payload; modal UI must prevent world input and unsafe saves. Manual editor playtest remains human verification.

## How to run
- Parse check: `tools/check_parse.sh` (macOS/Linux) or `tools\check_parse.bat` (Windows). Set the `GODOT` env var to your Godot executable.
- All tests: `tools/run_tests.sh` / `tools\run_tests.bat`; Windows official runner uses the pinned Godot executable and bounded processes, with error-text scans.
- Main scene: `scenes/main/main.tscn` (F5). No manual node/Inspector/InputMap changes are required for Phase 8; additions are in the allowed main scene, while existing E/J/Esc actions are reused.

## Phase 8 handoff and manual checklist
- Acceptance: delivery changes inventory only on explicit confirmation with enough items and reward room; merchant quote is data-defined, finite and isolated; every season respects rain/night home schedules; v3 load keeps previous progress and v4 social state survives save/load.
- [ ] F5, start/continue, dismiss help; press J, close with J/Esc, check that movement/clock/HUD resume.
- [ ] Ctrl+M → Test Minh visit; close debug menu; E near Minh → accept quest. With fewer than 3 turnips, confirm is disabled and nothing is removed.
- [ ] Ctrl+M → add delivery turnips; close menu; E → confirm delivery. Exactly 3 turnips leave inventory; 60 coins and 2 spring carrot seeds arrive once. Check full-inventory blocking, including space freed by delivery.
- [ ] Confirm Minh's daily discount/request; compare the normal shop/bin price before/after. Repeat today and after save/load: no second trade. Advance to a new visit day: stock is available again.
- [ ] Use existing debug weather/time controls: rain and 20:00 send NPCs home; resume sunny daytime and observe routes around farm/buildings. Check all four seasons; Linh's warm/cool season destinations differ.
- [ ] Save with an active quest and after completing it, exit/Continue, inspect J: friendship and quest state persist; dialogue reflects the restored quest condition. `social.heard` in save JSON keeps heard dialogue ids. Repeated talk/load on the same day adds no extra friendship.
- [ ] Repeat dialogue/journal at 1152x648, 1280x720 and 1920x1080; scroll long English text/actions. Esc closes the NPC modal without opening Pause; I/H/Ctrl+M do not open another modal over it.
- Assumptions: small declared static navigation grid, no dynamic building placements in this milestone; home boxes are presentation markers and NPC navigation does not share player physics. Daily offers are deterministic from saved seed/day and shipped data.
- Rendered evidence: `user://npc_dialogue_{vi,en}_{1152x648,1280x720,1920x1080}.png` and matching `npc_journal_...png`; generated by test_npc_ui. Visual QA sampled both languages at all three sizes using GUT `-gopacity=0` to keep the runner overlay out of screenshots.
- Full code diff for review: `git diff 57c9bde..npc-quests` (includes the pre-existing base committed at Step 0); commit log separates base, docs, delivery, merchant, schedules, save migration and UI integration. Extra metadata-only Step 0 commit: 57c9bde; item_data.gd's missing final newline was restored with no resulting content diff.
- Proposed/used one-line integration commit: `feat: integrate NPC dialogue journal and validated trade UI`.

## Exact Phase 8 file manifest (relative to 57c9bde)

Created (includes the pre-existing NPC/quest base):

```text
data/npcs/phase8_world.tres
data/quests/quest_turnip_delivery.tres
data/shops/minh_autumn_discount.tres
data/shops/minh_spring_discount.tres
data/shops/minh_summer_discount.tres
data/shops/minh_turnip_request.tres
data/shops/minh_winter_discount.tres
scripts/data/dialogue_data.gd
scripts/data/dialogue_data.gd.uid
scripts/data/merchant_offer_data.gd
scripts/data/merchant_offer_data.gd.uid
scripts/data/npc_data.gd
scripts/data/npc_data.gd.uid
scripts/data/npc_schedule_entry.gd
scripts/data/npc_schedule_entry.gd.uid
scripts/data/npc_world_data.gd
scripts/data/npc_world_data.gd.uid
scripts/data/quest_data.gd
scripts/data/quest_data.gd.uid
scripts/data/world_locations.gd
scripts/data/world_locations.gd.uid
scripts/domain/quests/det_random.gd
scripts/domain/quests/det_random.gd.uid
scripts/domain/quests/merchant_service.gd
scripts/domain/quests/merchant_service.gd.uid
scripts/domain/quests/npc_schedule.gd
scripts/domain/quests/npc_schedule.gd.uid
scripts/domain/quests/npc_social_state.gd
scripts/domain/quests/npc_social_state.gd.uid
scripts/domain/quests/quest_manager.gd
scripts/domain/quests/quest_manager.gd.uid
scripts/view/npc_actor.gd
scripts/view/npc_actor.gd.uid
scripts/view/npc_panel.gd
scripts/view/npc_panel.gd.uid
scripts/view/npc_system.gd
scripts/view/npc_system.gd.uid
tests/golden_saves/save_v4.json
tests/unit/test_merchant_service.gd
tests/unit/test_merchant_service.gd.uid
tests/unit/test_npc_data_validation.gd
tests/unit/test_npc_data_validation.gd.uid
tests/unit/test_npc_quest_delivery.gd
tests/unit/test_npc_quest_delivery.gd.uid
tests/unit/test_npc_schedule.gd
tests/unit/test_npc_schedule.gd.uid
tests/unit/test_npc_social_save.gd
tests/unit/test_npc_social_save.gd.uid
tests/unit/test_npc_ui.gd
tests/unit/test_npc_ui.gd.uid
```

Modified:

```text
docs/API_INDEX.md
docs/DECISIONS.md
docs/INPUT_MAP.md
docs/PROGRESS.md
docs/UI_LAYOUT.md
localization/strings_en.csv
localization/strings_vi.csv
scenes/main/main.tscn
scripts/core/data_registry.gd
scripts/core/data_validator.gd
scripts/core/save_service.gd
scripts/view/main.gd
tests/unit/test_save_service.gd
tests/unit/test_weather.gd
tools/validate_data.gd
```

Real final runner output:

```text
[check_parse] OK
[validate_data] PASS
Scripts              39
Tests               113
Passing Tests       113
Asserts            2850
Time              5.728s
---- All tests passed! ----
[run_tests] PASS
```

Separate headless GUT: 39 scripts, 113 tests, 113 passing, 2838 asserts, 4.094s. Final error-text scan: 0 matches across parse, validator, GUT, main, headless and NPC UI logs. Human manual playtest is still pending; gdtoolkit lint was not run (not installed).

Exact UI repair files:

```text
docs/API_INDEX.md
docs/DECISIONS.md
docs/PROGRESS.md
docs/UI_LAYOUT.md
localization/strings_en.csv
localization/strings_vi.csv
scripts/view/debug_menu.gd
scripts/view/hotbar_panel.gd
scripts/view/inventory_panel.gd
scripts/view/main.gd
scripts/view/npc_actor.gd
scripts/view/npc_system.gd
scripts/view/seed_shop_panel.gd
scripts/view/shipping_bin_panel.gd
scripts/view/start_menu.gd
scripts/view/ui_coordinator.gd
scripts/view/ui_coordinator.gd.uid
scripts/view/ui_layout.gd
scripts/view/ui_layout.gd.uid
tests/unit/test_hotbar_layout.gd
tests/unit/test_npc_ui.gd
tests/unit/test_onboarding.gd
tests/unit/test_ui_layout.gd
```

Exact files for click/chibi task (relative to 5c87cd5):

```text
assets/icons/ui_backpack.svg
assets/icons/ui_backpack.svg.import
assets/icons/ui_cabbage.svg
assets/icons/ui_cabbage.svg.import
assets/icons/ui_carrot.svg
assets/icons/ui_carrot.svg.import
assets/icons/ui_close.svg
assets/icons/ui_close.svg.import
assets/icons/ui_coin.svg
assets/icons/ui_coin.svg.import
assets/icons/ui_corn.svg
assets/icons/ui_corn.svg.import
assets/icons/ui_harvest.svg
assets/icons/ui_harvest.svg.import
assets/icons/ui_help.svg
assets/icons/ui_help.svg.import
assets/icons/ui_hoe.svg
assets/icons/ui_hoe.svg.import
assets/icons/ui_journal.svg
assets/icons/ui_journal.svg.import
assets/icons/ui_pause.svg
assets/icons/ui_pause.svg.import
assets/icons/ui_pea.svg
assets/icons/ui_pea.svg.import
assets/icons/ui_play.svg
assets/icons/ui_play.svg.import
assets/icons/ui_pumpkin.svg
assets/icons/ui_pumpkin.svg.import
assets/icons/ui_radish.svg
assets/icons/ui_radish.svg.import
assets/icons/ui_seed.svg
assets/icons/ui_seed.svg.import
assets/icons/ui_settings.svg
assets/icons/ui_settings.svg.import
assets/icons/ui_sun.svg
assets/icons/ui_sun.svg.import
assets/icons/ui_tomato.svg
assets/icons/ui_tomato.svg.import
assets/icons/ui_turnip.svg
assets/icons/ui_turnip.svg.import
assets/icons/ui_watering_can.svg
assets/icons/ui_watering_can.svg.import
assets/icons/ui_wheat.svg
assets/icons/ui_wheat.svg.import
assets/ui/title_valley.png
assets/ui/title_valley.png.import
assets/ui/title_valley.prompt.txt
docs/API_INDEX.md
docs/CREDITS.md
docs/DECISIONS.md
docs/PROGRESS.md
docs/PROJECT_AUDIT.md
docs/screenshots/chibi_hud.png
docs/screenshots/chibi_title.png
docs/SOURCE_AUDIT.md
docs/UI_LAYOUT.md
localization/strings_en.csv
localization/strings_vi.csv
scripts/view/chibi_avatar.gd
scripts/view/chibi_avatar.gd.uid
scripts/view/hotbar_panel.gd
scripts/view/inventory_panel.gd
scripts/view/main.gd
scripts/view/npc_actor.gd
scripts/view/npc_system.gd
scripts/view/seed_shop_panel.gd
scripts/view/shipping_bin_panel.gd
scripts/view/start_menu.gd
scripts/view/title_backdrop.gd
scripts/view/title_backdrop.gd.uid
scripts/view/tutorial_panel.gd
scripts/view/ui_coordinator.gd
scripts/view/ui_icons.gd
scripts/view/ui_icons.gd.uid
scripts/view/ui_layout.gd
scripts/view/world_presentation.gd
scripts/view/world_presentation.gd.uid
tests/unit/test_hotbar_layout.gd
tests/unit/test_ui_mouse.gd
tests/unit/test_ui_mouse.gd.uid
tests/unit/test_weather.gd
```

## ISO-5 delivery manifest (relative to c8b94f9)

Created (41 files):

~~~text
data/inventory_config.tres
docs/SCENE_CONTRACTS/inventory.md
scripts/data/inventory_config.gd
scripts/data/inventory_config.gd.uid
scripts/domain/inventory_actions.gd
scripts/domain/inventory_actions.gd.uid
tests/golden_saves/save_v6.json
tests/unit/test_inventory_actions.gd
tests/unit/test_inventory_actions.gd.uid
tests/unit/test_inventory_screen.gd
tests/unit/test_inventory_screen.gd.uid
ui/inventory/capacity_footer.gd
ui/inventory/capacity_footer.gd.uid
ui/inventory/capacity_footer.tscn
ui/inventory/common_tabs.gd
ui/inventory/common_tabs.gd.uid
ui/inventory/common_tabs.tscn
ui/inventory/detail_card.gd
ui/inventory/detail_card.gd.uid
ui/inventory/detail_card.tscn
ui/inventory/discard_prompt.gd
ui/inventory/discard_prompt.gd.uid
ui/inventory/discard_prompt.tscn
ui/inventory/filter_bar.gd
ui/inventory/filter_bar.gd.uid
ui/inventory/filter_bar.tscn
ui/inventory/inventory_controller.gd
ui/inventory/inventory_controller.gd.uid
ui/inventory/inventory_screen.gd
ui/inventory/inventory_screen.gd.uid
ui/inventory/inventory_screen.tscn
ui/inventory/inventory_slot.gd
ui/inventory/inventory_slot.gd.uid
ui/inventory/inventory_slot.tscn
ui/inventory/item_grid.gd
ui/inventory/item_grid.gd.uid
ui/inventory/item_grid.tscn
ui/inventory/item_icon.gd
ui/inventory/item_icon.gd.uid
ui/theme/inventory_theme.gd
ui/theme/inventory_theme.gd.uid
~~~

Modified (54 files):

~~~text
data/items/autumn_pumpkin.tres
data/items/autumn_pumpkin_seed.tres
data/items/autumn_wheat.tres
data/items/autumn_wheat_seed.tres
data/items/spring_carrot.tres
data/items/spring_carrot_seed.tres
data/items/spring_pea.tres
data/items/spring_pea_seed.tres
data/items/summer_corn.tres
data/items/summer_corn_seed.tres
data/items/summer_tomato.tres
data/items/summer_tomato_seed.tres
data/items/turnip.tres
data/items/turnip_seed.tres
data/items/winter_cabbage.tres
data/items/winter_cabbage_seed.tres
data/items/winter_radish.tres
data/items/winter_radish_seed.tres
docs/API_INDEX.md
docs/ARCHITECTURE.md
docs/DATA_SCHEMA.md
docs/DECISIONS.md
docs/INPUT_MAP.md
docs/PROGRESS.md
docs/PROJECT_RULES.md
docs/ROADMAP.md
docs/SCENE_CONTRACTS/hud.md
docs/SCENE_CONTRACTS/ui_components.md
docs/UI_LAYOUT.md
localization/strings_en.csv
localization/strings_vi.csv
project.godot
scripts/core/data_validator.gd
scripts/core/save_service.gd
scripts/data/item_data.gd
scripts/domain/inventory_state.gd
scripts/view/chibi_ui_motion.gd
scripts/view/hotbar_panel.gd
scripts/view/inventory_panel.gd
scripts/view/main.gd
scripts/view/npc_panel.gd
scripts/view/npc_system.gd
scripts/view/ui_coordinator.gd
scripts/view/ui_layout.gd
tests/unit/test_crop_inspector.gd
tests/unit/test_day_end_flow.gd
tests/unit/test_day_end_save.gd
tests/unit/test_npc_social_save.gd
tests/unit/test_save_service.gd
tests/unit/test_ui_mouse.gd
tests/unit/test_weather.gd
tools/validate_data.gd
ui/theme/the_life_theme.tres
ui/theme/theme_factory.gd
~~~

Owner edit excluded: docs/reference/THE_LIFE_MASTER_PLAN.txt (one leading blank line). No old golden fixture or source-art file changed. Main scene required no edits.

Review tracked changes: git diff c8b94f9 -- . ':(exclude)docs/reference/THE_LIFE_MASTER_PLAN.txt'. Newly created files above are the complete reviewable source; use git diff --no-index -- NUL <path> for their addition diffs. No ISO-5 staging/commit/push was performed.


## ISO-5 editor handoff / manual acceptance

Acceptance: default 40 slots in 8×5, metadata filters and actual detail/unit price, exact confirmed stack discard, stable sort/selection, Q/E/F/Z only in supported modal context, v1–v5 migrated without content loss and v6 round-trip, prior farming/economy/day-end flows intact. Each is automated; human visual/gameplay acceptance remains pending.

No editor node/Inspector changes required: approved script-backed wrapper scenes construct their documented children. Existing Main InventoryPanel/NpcJournal paths remain. InputMap's four approved contextual actions are already in project.godot. Existing source item artwork is reused as a replaceable placeholder; layout/skin follows reference 06, it is not a claim of identical final illustrations. No eating/Character/Calendar/Map/storage domain was introduced.

Run: set GODOT to D:\godot\Godot_v4.7.2-stable_win64_console.exe, then tools\run_tests.bat. Rebuild shared theme with --headless --path . --script tools/build_ui_theme.gd after any theme-builder edit. All Godot test commands use tools/run_godot_bounded.ps1 and isolated APPDATA; they do not write player saves.

- [ ] F5 → start/continue → dismiss help. B/I/Tab opens Bag; close button and Escape close it, restoring movement/clock. Check vi/en at 1152×648, 1280×720, 1920×1080; five default rows, details/actions/header/footer fit.
- [ ] Choose seed/produce filters and a real stack; verify name/count/unit sell price. Tool/material filters are honestly empty. F/detail selection closes Bag, selects the original real stack on toolbar and leaves quantities/money unchanged; plant using the normal workflow.
- [ ] Z with an inventory item selected retains that stack and its quantity; with a tool active it does not change tool. Fill to 40 occupied stacks; blocked grants/transactions keep original behavior. A legitimate legacy capacity 60 retains all stacks and extra scrollable rows.
- [ ] Discard opens integer quantity confirmation. Escape/Keep cancels without loss. Confirm partial/exact stack once; only that stack changes, selected later stacks remap correctly, no coins or journal entry is added. Change inventory while confirmation is open: stale confirmation cannot act.
- [ ] Q/E or supported header tabs switch Bag ↔ existing Quest journal. Disabled tabs show unavailable; J/Escape/close still work. E/Q never performs world interaction/rotation underneath; F/Z outside Bag has no inventory effect. Check close over the visible clock region; HUD decoration must not intercept it.
- [ ] At bed/forced 02:00 review, Q/E/F/Z/B cannot bypass the day-end sheet. Existing confirmation advances exactly once and save/reload retains ledger/guard. Continue v1–v5 saves: same item IDs/quantities/order, capacity at least 40, other progress intact; v6 save reloads the same state.

Assumptions/limits: compact existing stack model remains (sort does not merge); toolbar selection is the supported interpretation of quick-store, without chest/fixed-slot reassignment. Legacy invalid entries are warned/dropped; malformed whole arrays/unsafe totals retain previous inventory. Intentional warning output in corrupted-data tests is expected. gdtoolkit lint was not run because it is not installed; no package installation was performed.

During verification, a 72-pixel slot height clipped the fifth row on the small viewport; final 64-pixel cells plus shared outer inset preserve all rows and animated focus bounds. A physical-close regression revealed the read-only clock decoration intercepting GUI events above the wide header; UiCoordinator now marks its static readout subtree mouse-ignore. Wide shells keep stable geometry during open. Original regression tests were kept; the old list-row selector test now clicks the grid and explicitly quick-selects, matching the approved two-step interaction. Existing migration assertions compare slots unchanged plus the new capacity floor, with all other field checks retained.

Proposed ISO-5 commit: feat: add modular forty-slot inventory and save v6 migration

## ISO-6a exact file manifest (relative to 67c63a2)

Created (7 files):

~~~text
tests/golden_saves/save_v7.json
tests/unit/test_crop_care.gd
tests/unit/test_crop_care.gd.uid
tests/unit/test_crop_care_save.gd
tests/unit/test_crop_care_save.gd.uid
tests/unit/test_crop_care_ui.gd
tests/unit/test_crop_care_ui.gd.uid
~~~

Modified (34 files):

~~~text
data/crops/autumn_pumpkin.tres
data/crops/autumn_wheat.tres
data/crops/spring_carrot.tres
data/crops/spring_pea.tres
data/crops/summer_corn.tres
data/crops/summer_tomato.tres
data/crops/turnip.tres
data/crops/winter_cabbage.tres
data/crops/winter_radish.tres
docs/API_INDEX.md
docs/ARCHITECTURE.md
docs/DATA_SCHEMA.md
docs/DECISIONS.md
docs/PROGRESS.md
docs/PROJECT_RULES.md
docs/ROADMAP.md
docs/SCENE_CONTRACTS/day_end.md
docs/SCENE_CONTRACTS/gray_box_world.md
docs/SCENE_CONTRACTS/hud.md
docs/UI_LAYOUT.md
localization/strings_en.csv
localization/strings_vi.csv
scripts/core/data_validator.gd
scripts/core/save_service.gd
scripts/data/crop_data.gd
scripts/domain/farm_grid_state.gd
scripts/view/crop_inspector.gd
scripts/view/main.gd
tests/unit/test_day_end_flow.gd
tests/unit/test_day_end_save.gd
tests/unit/test_inventory_actions.gd
tests/unit/test_npc_social_save.gd
tests/unit/test_save_service.gd
tests/unit/test_weather.gd
~~~

Owner edit excluded: docs/reference/THE_LIFE_MASTER_PLAN.txt (one leading blank line). No .tscn, project.godot, source-art, item-resource or old-golden changes. Review tracked source with git diff 67c63a2 -- . ':(exclude)docs/reference/THE_LIFE_MASTER_PLAN.txt'; inspect the created files above or use git diff --no-index -- NUL <path> for their addition diffs. Files are not staged; no ISO-6a commit/push performed.

## ISO-6a editor handoff and acceptance checklist

Acceptance: first missed eligible watering day pauses growth and warns; two consecutive missed days wither once; watering/rain resets a living crop; terminal/ripe withered plants cannot grow, revive, water or harvest; source Resource sets the threshold; dry→rain/rain→dry/out-of-season boundaries use the correct completed day; one manual/forced/direct simulation path; save v7 round-trip and v1–v6 preservation; prior inventory/farming/economy/modal behavior retained. Automation passed; human checks below remain pending.

Editor steps: none. Existing Main/scene paths, Inspector controls, signals and InputMap stay intact. Open the project with pinned Godot 4.7.2 and F5; updated Resources/translations/scripts import normally. Run all automation by setting GODOT to D:\godot\Godot_v4.7.2-stable_win64_console.exe then tools\run_tests.bat. Focused suite uses test_crop_care.gd, test_crop_care_save.gd, test_crop_care_ui.gd, test_day_end_rollover.gd and test_save_service.gd via tools/run_godot_bounded.ps1; headless flags and real output are recorded above.

- [ ] F5, start/continue, dismiss help. On a sunny day till/plant a crop, leave it unwatered for one completed day; inspect it. Growth is paused, it is alive, warning reports one remaining dry day. Ripe plants left in soil receive the same warning.
- [ ] Water via the existing tool or Inspector button before the next rollover. Warning clears, no item/coin/ledger change from watering; growth advances once at the day boundary. Another isolated missed day starts a new streak.
- [ ] Leave a plant unwatered through two consecutive sunny day boundaries. It becomes withered; watering/harvesting cannot revive or yield. Previously ripe plants are also blocked. Existing hoe clearing/replanting starts fresh care state.
- [ ] Use existing weather/debug controls to compare outgoing sunny → tomorrow rain versus outgoing rain → tomorrow sunny. A second completed dry day still withers before new rain; a survivor gets morning rain without free previous-day growth; an outgoing rainy day counts as cared-for even for a newly planted crop, and leaves no old moisture on a sunny morning.
- [ ] Open manual bedtime review and cancel: no counter/growth change. Confirm once or repeatedly: one day only. Repeat forced 02:00 review: cannot cancel/bypass; new day and autosave include completed care. Check season boundary and unwatered summary count without reviving dead crops.
- [ ] Save/reload a threatened plant: counter/warning remain, next missed day withers once. Continue a v1–v6 save: original fields/growth/wither/water/order/items/wallet/social/ledger/guard remain; absent dry history starts 0. Check v7 withered mature plant cannot harvest after load.
- [ ] Switch vi/en; check warning, ripe warning and terminal status at 1152×648, 1280×720, 1920×1080. B/I/Tab/J/Escape modal behavior and toolbar selection stay working; native Water action respects reach/locks. Full inventory still blocks harvest without destroying the live crop.

Assumptions/known limits: maturity does not exempt a crop left planted from care (explicitly approved); water_need=0 exempts dryness. No unavailable historical care is inferred on migration. Existing data says all shipped crops need water and supplies threshold 2. Growth/prices, tomato repeat-harvest interval, fertilizer effects and house-level corn unlock are intentionally ISO-6b, not implemented or validated by this slice. Old artifacts remain placeholders. Malformed row handling is limited to farm state/new counters, not a new general top-level save format/security rewrite. Source FarmGridState remains the state owner and DaySimulator the one daily transition; no future system or hidden balance change.

Proposed ISO-6a commit: feat: add daily crop care and save v7 migration
## ISO-6b1 exact file manifest (relative to 7f7a429)

Created (21 files):

~~~text
data/crop_economy_config.tres
data/crop_migration_v7.tres
scripts/data/crop_economy_config.gd
scripts/data/crop_economy_config.gd.uid
scripts/data/crop_migration_config.gd
scripts/data/crop_migration_config.gd.uid
scripts/domain/crop_cycle_rules.gd
scripts/domain/crop_cycle_rules.gd.uid
scripts/domain/economy/crop_economy_rules.gd
scripts/domain/economy/crop_economy_rules.gd.uid
scripts/domain/farm_save_codec.gd
scripts/domain/farm_save_codec.gd.uid
tests/golden_saves/save_v8.json
tests/unit/test_crop_balance.gd
tests/unit/test_crop_balance.gd.uid
tests/unit/test_crop_regrow.gd
tests/unit/test_crop_regrow.gd.uid
tests/unit/test_crop_regrow_save.gd
tests/unit/test_crop_regrow_save.gd.uid
tests/unit/test_crop_regrow_ui.gd
tests/unit/test_crop_regrow_ui.gd.uid
~~~

Modified (52 files):

~~~text
data/crops/summer_corn.tres
data/crops/summer_tomato.tres
data/crops/turnip.tres
data/items/spring_carrot.tres
data/items/spring_carrot_seed.tres
data/items/summer_corn.tres
data/items/summer_corn_seed.tres
data/items/summer_tomato.tres
data/items/summer_tomato_seed.tres
data/items/turnip.tres
data/items/turnip_seed.tres
docs/API_INDEX.md
docs/ARCHITECTURE.md
docs/DATA_SCHEMA.md
docs/DECISIONS.md
docs/PROGRESS.md
docs/PROJECT_RULES.md
docs/ROADMAP.md
docs/SCENE_CONTRACTS/day_end.md
docs/SCENE_CONTRACTS/gray_box_world.md
docs/SCENE_CONTRACTS/hud.md
docs/SCENE_CONTRACTS/inventory.md
docs/SCENE_CONTRACTS/ui_components.md
docs/UI_LAYOUT.md
localization/strings_en.csv
localization/strings_vi.csv
scripts/core/data_validator.gd
scripts/core/save_service.gd
scripts/data/crop_data.gd
scripts/domain/farm_grid_state.gd
scripts/view/crop_inspector.gd
scripts/view/farm_view.gd
scripts/view/main.gd
tests/unit/test_chibi_farming.gd
tests/unit/test_crop_care_save.gd
tests/unit/test_crop_care_ui.gd
tests/unit/test_crop_inspector.gd
tests/unit/test_day_end_flow.gd
tests/unit/test_day_end_save.gd
tests/unit/test_day_simulator.gd
tests/unit/test_drag_farming.gd
tests/unit/test_farm_grid_state.gd
tests/unit/test_farm_view.gd
tests/unit/test_full_year_economy_simulation.gd
tests/unit/test_game_feel.gd
tests/unit/test_harvest.gd
tests/unit/test_inventory_actions.gd
tests/unit/test_npc_social_save.gd
tests/unit/test_save_service.gd
tests/unit/test_shipping_bin.gd
tests/unit/test_weather.gd
tools/validate_data.gd
~~~

Owner edit excluded: docs/reference/THE_LIFE_MASTER_PLAN.txt (one leading blank line). No old golden, scene, InputMap or source-art file changed. Review tracked changes: git diff 7f7a429 -- . ':(exclude)docs/reference/THE_LIFE_MASTER_PLAN.txt'. Created files above contain the complete additions; git diff --no-index -- NUL <path> shows an addition diff. No ISO-6b1 staging/commit/push performed.

## ISO-6b1 editor handoff / manual acceptance

Acceptance: exact approved table and Resource ceiling80 pass retained/new validators; tomato5-day first growth then2-day cared-for repeats yield2 once, no extra seed/water/dry reset; full inventory leaves all plant/cycle state untouched; missing care/season/wither remains terminal in each phase; legacy mature/immature plants keep remaining time while new sowing uses current data; v8 cycles round-trip and every old field survives v1–v7 migration; actual UI/stage/countdown follows owner targets at three sizes/both languages; existing inventory/economy/clock/modal/save path remains. Automated acceptance passed; human checks remain pending.

No editor node/Inspector/InputMap changes required. F5 in Godot4.7.2 imports new Resources/scripts/translations; gameplay scene paths remain existing. Set GODOT to D:\godot\Godot_v4.7.2-stable_win64_console.exe and run tools\run_tests.bat for the complete verification. Focused suite: test_crop_balance, test_crop_regrow, test_crop_regrow_save, test_crop_care, test_crop_care_save, test_full_year_economy_simulation through tools/run_godot_bounded.ps1; real summaries appear above. Test profile is isolated from player saves.

- [ ] F5 → start/continue → dismiss help. In summer buy/select tomato seeds and sow: consume exactly one seed. Water daily; no pick before day5, day5 gives two produce. The same plant remains, Inspector reports its new-fruit countdown and FarmView uses the same target.
- [ ] Water two more completed days; get two more produce, with no extra seed consumption. Repeat clicking/harvesting immediately cannot duplicate products. Check existing single-harvest carrot/turnip behavior still removes their crop.
- [ ] Fill inventory so tomato cannot fit, then harvest. Quantity, moisture, dry streak and cycle/target remain unchanged. Free space and retry: one yield, one reset. Check no wallet/ledger change until a real sale; bin/shop quotes match Resource prices and normal atomic behavior.
- [ ] Miss water in repeat phase: growth pauses and warns; two dry days wither. Picking must not clear a prior dry streak. Rain and manual care reset only living plants; season transition/withered plants cannot yield or regrow. Review/cancel/forced sleep advances through the same existing day path once.
- [ ] Continue a v1–v7 save with mature/immature plants: old first-growth target/ripeness/remaining time are preserved. New sowing uses carrot3/tomato5/turnip4/corn7. A real harvest on an old tomato starts the current2-day repeat. Save/load mid-repeat: remaining time, care, items, wallet, social, ledger and guard remain; all cells refresh their saved stage.
- [ ] Check seed buy / produce unit sale: carrot20/35, tomato35/72, turnip25/45, corn35/100. Yield remains2; other crop prices/seasons/IDs/stacks/care stay unchanged. Bag details and successful shop/bin transactions show actual values, while old saved journal history keeps its recorded amounts.
- [ ] Switch vi/en and test 1152×648,1280×720,1920×1080: legacy-ready/repeat/repeat-ready/dry-repeat readouts fit. B/I/Tab/J/Escape/F/Z/toolbar/modal behavior stays compatible. Unsupported fertilizer/house UI is absent.

Assumptions/known limits: cap80 and the exact table are approved provisional current-MVP balance, not final human-tested tuning. Ideal 28-watered-day tomato net1693 omits travel/missed care/saturation/future systems. Fertilizer and house-level corn gating remain unimplemented by approved scope; corn availability is unchanged. Frozen first targets admit current or historical valid durations; future balance changes need another deliberate compatibility decision. Ordinary domain restore without version migration uses current targets; real old-save loading goes through SaveService. Crop/field art is existing placeholder material; no new illustrations were commissioned. Old JSON numbers are normalized for round-trip comparisons; no source fixture or saved historical amount is rewritten.

Proposed ISO-6b1 commit: feat: add repeat crop cycles and save v8 compatibility

## ISO-7 handoff and exact manifest (relative to 4b3ca62, D43)

Acceptance: reference14 two wood/paper cards and four tabs; six small scene/script pairs plus presenter/helpers (new UI scripts35-85 lines); native mouse/focus/slider operation with world locks; supported preference drafts/Apply/Default/cancel/vi-en persistence; real save/load/backend-rejection feedback and failure-safe return to title; preserved day-end priority/clock holds. Source settings/save/domain/data/Theme/old scenes/InputMap and v1-v8 goldens are unchanged. Unsupported pictured preferences remain explicitly disabled. ISO-6b1 committed4b3ca62; ISO-7 is uncommitted, no push. Human editor acceptance is pending.

Created (27 files):
~~~text
docs/SCENE_CONTRACTS/pause_menu.md
tests/unit/test_pause_layout.gd
tests/unit/test_pause_layout.gd.uid
tests/unit/test_pause_settings.gd
tests/unit/test_pause_settings.gd.uid
ui/pause/audio_settings.gd
ui/pause/audio_settings.gd.uid
ui/pause/audio_settings.tscn
ui/pause/controls_help.gd
ui/pause/controls_help.gd.uid
ui/pause/controls_help.tscn
ui/pause/game_settings.gd
ui/pause/game_settings.gd.uid
ui/pause/game_settings.tscn
ui/pause/pause_actions.gd
ui/pause/pause_actions.gd.uid
ui/pause/pause_actions.tscn
ui/pause/pause_parts.gd
ui/pause/pause_parts.gd.uid
ui/pause/pause_presenter.gd
ui/pause/pause_presenter.gd.uid
ui/pause/pause_shell.gd
ui/pause/pause_shell.gd.uid
ui/pause/pause_shell.tscn
ui/pause/settings_panel.gd
ui/pause/settings_panel.gd.uid
ui/pause/settings_panel.tscn
~~~

Modified (16 files):
~~~text
docs/API_INDEX.md
docs/ARCHITECTURE.md
docs/DECISIONS.md
docs/PROGRESS.md
docs/ROADMAP.md
docs/SCENE_CONTRACTS/hud.md
docs/SCENE_CONTRACTS/ui_components.md
docs/UI_LAYOUT.md
localization/strings_en.csv
localization/strings_vi.csv
scripts/view/main.gd
scripts/view/pause_menu.gd
scripts/view/ui_coordinator.gd
scripts/view/ui_layout.gd
tests/unit/test_pause_menu.gd
tests/unit/test_ui_layout.gd
~~~

Scope audit:43 delivered files inside approved ALLOW_LIST; owner's one leading blank line in docs/reference/THE_LIFE_MASTER_PLAN.txt remains excluded. tests/unit/test_ui_mouse.gd needed no edits; existing physical-input cases were rerun unchanged. New .gd.uid files came from Godot editor import. No packages installed.

Clear diff: `git diff 4b3ca62 -- . ':(exclude)docs/reference/THE_LIFE_MASTER_PLAN.txt'` reviews tracked edits. The exact new files above contain the remaining source. Combined patch including all new files: C:/Users/daova/AppData/Local/Temp/the_life_iso7_review/iso7_review.patch (git apply --reverse --check PASS; no working files reversed). Screenshot folder: C:/Users/daova/AppData/Local/Temp/the_life_iso7_review (54 clean PNGs). Reference PNG is never loaded at runtime.

Run automation in PowerShell: `$env:GODOT='D:\godot\Godot_v4.7.2-stable_win64_console.exe'; & tools/run_tests.bat`. The helper isolates APPDATA and launches hidden bounded processes; real player saves/settings are not used. Final logs: %TEMP%/the_life_{gut,headless,main,validate}.log.{stdout,stderr}, focused %TEMP%/the_life_iso7_final_focused.log.{stdout,stderr}, clean render %TEMP%/the_life_iso7_render.log.{stdout,stderr}.

Manual editor steps: no node/Inspector/project-setting/scene edits required. Open project.godot in Godot4.7.2, allow import, F5, start/continue, dismiss help, Escape. Existing Main/PauseMenu mounts the new scenes at runtime. See docs/SCENE_CONTRACTS/pause_menu.md for the tree/APIs.

Manual cases (owner pending):
- [ ] Both vi/en at1152x648,1280x720,1920x1080: four tabs, close/left/footer/Apply/Default remain visible; page scrolls when necessary; text/percentages/disabled explanations fit.
- [ ] Change volumes/language without Apply, close via Resume/close/Escape or switch to Bag, reopen: original preferences return. Apply persists after restart. Default changes only the draft until Apply. Editing after Apply restores draft feedback.
- [ ] Mouse drag/click; Tab traverses focus without opening Bag, arrows adjust slider, Space activates focused button without farming. Escape closes only active modal; B/I/J/H retain routing. World/clock stay locked while pause is visible and restore prior hold on close.
- [ ] Save, change farm/inventory/wallet, Load: real state and metadata restore. Missing/corrupt manual save reports failure without replacing game. Use isolated test saves for corruption checks.
- [ ] Return to main menu saves; Continue restores it. Blocked/failed required save keeps game with feedback. Backend rejection/retry is automated without touching player user://.
- [ ] Load a day-end review: summary replaces pause and holds clock/world. Pause cannot replace review. Confirm uses existing exactly-once morning simulation and atomic v8 saves/backups.
- [ ] Unsupported rain/wind audio/fullscreen/key-hints/autosave toggle/shake/S-M-L sizing are explicit. Controls read-only. Music preference storage does not imply background playback.

Validation notes:
- Focus-scale overflow on close fixed with6px header inset; containment assertions retained. Earlier pause fixture opened from title and relied on unconditional unlocking; it now starts a running game.
- First complete renderer246/247: old pause test inherited a clock hold but expected running time. Setup now explicitly sets paused=false; separate new test verifies a real prior hold survives closing. No assertion/guard removed.
- Isolated OS fault: directory at slot_1.json.tmp produced expected SaveService “could not open temporary save”; Main/view displayed failure and retry succeeded. Strict official runner rejects even GUT-asserted expected ERROR text, so its guards stay unchanged. The delivered regression exercises the actual Main→SaveService false-result path via a rejected negative slot, plus real NPC safe-point blocking. No log suppression or skipped test.
- Clean renderer before added prior-hold regression:2 scripts/8 tests/8 passing/1236 asserts/6.744s.54 captures: four tabs plus dirty/default/applied/save-failure/reopen, two locales/three sizes. Reviewed vi dirty/failure and en audio1152, en Controls/vi Game1280, vi Graphics/en Default/Game1920; visible tracks, fixed controls, wrapping and explanations fit.
- ISO-7 final validation, Godot4.7.2/GUT9.7.1, isolated APPDATA:

~~~text
[check_parse] OK
[validate_data] PASS

Official headless subset:
Totals
------
Scripts              16
Tests                62
Passing Tests        62
Asserts             879
Time              3.817s
---- All tests passed! ----

Final focused pause/settings/layout/mouse headless:
Totals
------
Scripts               5
Tests                21
Passing Tests        21
Asserts            2647
Time              8.902s
---- All tests passed! ----

COMPLETE graphics-renderer suite:
Totals
------
Scripts              73
Tests               247
Passing Tests       247
Asserts            9806
Time              99.054s
---- All tests passed! ----

[run_tests] starting main scene headless
[run_tests] PASS
~~~

Final scans: zero SCRIPT ERROR / Parse Error / Failed to load script / ERROR / orphan / resource-leak matches in official headless/full-renderer/main and final focused logs. Intentional malformed-data warnings remain; the new backend-rejection test warns for negative slot -1. git diff --check PASS; protected data/domain/core/project/scenes/goldens/assets/Theme/components have zero diff from4b3ca62. Owner master-plan edit remains1 insertion/0 deletions, outside delivery. No tests skipped, no runtime guard/log suppression, no package installation. Existing pause test keeps all assertions with an explicit running-game setup; added hold test verifies restoration.

Assumptions/limits: ConfigFile setters have no success return; normal persistence is verified by reload, not claimed atomic preference transactions. New music/weather players, pictured unsupported preferences/key remapping, fertilizer/house unlock and other screens remain future tasks. Existing shared StyleBoxFlat artwork is replaceable; composition/colors reuse Theme rather than newly commissioned textures. Human F5 test remains required. gdtoolkit lint not run (not installed).

Proposed ISO-7 commit: feat: add modular pause settings and reliable save feedback

## ISO-8a handoff and exact manifest (relative to 4ccc8de, D44)

Acceptance delivered in source: reference01 left wood/paper/green-banner menu, real latest save, large Continue, paired New Game/Settings, red Exit/footer; five components/seven small UI scripts; explicit old internal-path migration with preserved public adapter APIs; profile normalization/initial seed/reset flow unchanged; reused settings pages with draft Apply/Default/cancel; native mouse/keyboard/typing/Back routing with one modal owner. Background illustration/Theme remain existing assets. ISO-7 committed4ccc8de; ISO-8a uncommitted/no push. Human editor test remains pending.

Created (24 files):
~~~text
docs/SCENE_CONTRACTS/start_menu.md
tests/unit/test_title_flow.gd
tests/unit/test_title_flow.gd.uid
tests/unit/test_title_layout.gd
tests/unit/test_title_layout.gd.uid
ui/title/latest_save_card.gd
ui/title/latest_save_card.gd.uid
ui/title/latest_save_card.tscn
ui/title/profile_form.gd
ui/title/profile_form.gd.uid
ui/title/profile_form.tscn
ui/title/title_actions.gd
ui/title/title_actions.gd.uid
ui/title/title_actions.tscn
ui/title/title_parts.gd
ui/title/title_parts.gd.uid
ui/title/title_presenter.gd
ui/title/title_presenter.gd.uid
ui/title/title_screen.gd
ui/title/title_screen.gd.uid
ui/title/title_screen.tscn
ui/title/title_settings.gd
ui/title/title_settings.gd.uid
ui/title/title_settings.tscn
~~~

Modified (18 files):
~~~text
docs/API_INDEX.md
docs/ARCHITECTURE.md
docs/DECISIONS.md
docs/PROGRESS.md
docs/PROJECT_RULES.md
docs/ROADMAP.md
docs/SCENE_CONTRACTS/hud.md
docs/SCENE_CONTRACTS/ui_components.md
docs/UI_LAYOUT.md
localization/strings_en.csv
localization/strings_vi.csv
scripts/view/start_menu.gd
scripts/view/ui_coordinator.gd
scripts/view/ui_layout.gd
tests/unit/test_chibi_characters.gd
tests/unit/test_chibi_ui.gd
tests/unit/test_ui_layout.gd
tests/unit/test_ui_mouse.gd
~~~

Scope audit:42 delivered files inside approved ALLOW_LIST, zero outside; owner's docs/reference/THE_LIFE_MASTER_PLAN.txt leading blank line stays excluded. Existing .tscn, Main, TitleBackdrop, core/domain/data, source art, ui/pause/components/Theme, project.godot and v1-v8 goldens have zero diff. New UI scripts22-99 lines; no packages installed.

Clear diff: `git diff 4ccc8de -- . ':(exclude)docs/reference/THE_LIFE_MASTER_PLAN.txt'` plus exact new files above; a combined patch including new files is supplied at C:/Users/daova/AppData/Local/Temp/the_life_iso8a_review/iso8a_review.patch after final validation. Clean screenshots: same folder,36 PNGs, vi/en x three sizes x empty/latest-long-name/corrupt/profile/settings-audio/settings-game. Compared with reference01; existing background matches the supported composition but is retained source artwork, not a newly generated reference copy.

Manual editor steps: none. Open project.godot in Godot4.7.2, allow import and F5. Existing Main/StartMenu mounts ui/title/title_screen.tscn at runtime; new profile/settings components remain inside the same modal. See SCENE_CONTRACTS/start_menu.md for tree/API and approved path migration. The old script-created MarginContainer/Column paths are intentionally replaced; Main/StartMenu and public configure/appearance APIs remain.

Manual cases (human pending):
- [ ] F5 with no save: disabled Continue and localized empty card; New Game focused. With a valid slot0/1: actual latest farm/player/day/coins and metadata version; newest slot controls Continue. Missing optional fields are omitted, no fake playtime/house/portrait.
- [ ] Check both locales at1152x648,1280x720,1920x1080. Long names scroll inside the card while day/coins remain fixed. Menu buttons/footer remain in bounds. Profile fields scroll independently of Confirm/Back; settings uses the wide rectangle.
- [ ] Use mouse New Game/Back/Settings/Back; Tab focus, Enter/Space activation, slider arrows. Type B/I/E into name fields: letters stay in text, no Bag/shop/tool. Escape returns from a subpage; Escape on title never unlocks an unstarted world.
- [ ] Choose all six data-backed appearance choices, enter names, Back/reopen: transient values remain. Repeated New Game does not add duplicate controls. Confirm initializes the original clean farm/wallet/starter seeds once, persists normalized appearance and leaves title. Reference02 redesign is not included.
- [ ] Edit language/music/effects, Back without Apply/reopen: stored preferences return. Default only edits drafts. Apply persists supported preferences after restart and refreshes title/form captions without clearing typed names/selection. Other pictured options remain explicitly unavailable.
- [ ] Continue loads the displayed newest save. If a file is removed/corrupted before the click, no invalid Continue callback enters the game; title stays open. Automated tests exercise v1-v8 goldens and malformed/missing display fields in isolated user://; do not corrupt a real player save.
- [ ] Pause/return to title after gameplay still works; Continue, sleep/day-end/save backup behavior stays unchanged. Exit invokes the existing Main quit callback.

Validation / evidence:
- Initial old mouse test expected New Game to stay visible inside Settings; now it physically clicks Back before New Game, retaining original dispatch/confirm assertions. Original form/path tests use typed fields and keep appearance/duplicate-control assertions. No test was skipped or weakened.
- One new locale test initially guessed an absent BOB key; corrected its expected key to derive from the actual catalogue's first style (round_bob), preserving localization assertions.
- Initial render exposed date/coins below the long-name scroll; moved them to a fixed row and added containment regression assertions. Card padding keeps labels inside its border.
- Final focused headless:6 scripts/27 tests/27 passing/2277 asserts/8.909s.
- Final clean renderer:2 scripts/9 tests/9 passing/684 asserts/11.28s.
- Reviewed vi/en latest at1152, vi/en profile1280, en empty/Game settings1920; header/actions/footer, fixed saved stats, fields and reused settings controls fit.36 clean captures retained before the official suite's GUT overlay could overwrite user:// images.
- ISO-8a final official validation (Godot4.7.2/GUT9.7.1, isolated APPDATA):

~~~text
[check_parse] OK
[validate_data] PASS

Official headless subset:
Totals
------
Scripts              16
Tests                62
Passing Tests        62
Asserts             879
Time              4.084s
---- All tests passed! ----

Final focused title/profile/settings/input headless:
Totals
------
Scripts               6
Tests                27
Passing Tests        27
Asserts            2277
Time              8.909s
---- All tests passed! ----

Separate clean-render title suite:
Totals
------
Scripts               2
Tests                 9
Passing Tests         9
Asserts             684
Time              11.28s
---- All tests passed! ----

COMPLETE graphics-renderer suite:
Totals
------
Scripts              75
Tests               256
Passing Tests       256
Asserts           10468
Time             111.822s
---- All tests passed! ----

[run_tests] starting main scene headless
[run_tests] PASS
~~~

Final scans: zero SCRIPT ERROR/Parse Error/Failed to load script/ERROR/orphan/resource-leak matches in official headless/full-renderer/main, focused and clean-render logs. Existing intentional malformed-data warnings and ISO-7 negative-slot warning remain. git diff --check PASS;42 delivered files in approved scope, zero outside, no staged files/ISO-8a commit. Protected source/goldens unchanged; owner master-plan edit remains1 insertion/0 deletions. No weakened/skipped tests, log suppression or package installation.

Run automation: `$env:GODOT='D:\godot\Godot_v4.7.2-stable_win64_console.exe'; & tools/run_tests.bat`. Helpers use isolated APPDATA, hidden windows and bounded runs; player saves/settings stay separate. Logs: %TEMP%/the_life_{gut,headless,main,validate}.log.{stdout,stderr}, focused %TEMP%/the_life_iso8a_focused.log.{stdout,stderr}, clean render %TEMP%/the_life_iso8a_render.log.{stdout,stderr}.

Known limits: existing illustration and shared flat Theme surfaces are retained; no new bitmap/final-art commission. Very long saved names require scrolling; fixed day/coins remain visible. No playtime/house/portrait/backend or new save schema. ConfigFile setter failures have no result API; normal supported-preference persistence is verified by reload, not claimed atomic. Human F5 acceptance remains pending. gdtoolkit lint not run (not installed).

Proposed ISO-8a commit: feat: add modular main menu with live save summary

## ISO-8b handoff and exact manifest (relative to a683feb, D45)

Acceptance implemented: reference02 two-panel creation with red ribbon/paired names/six hairstyle and palette choices, shared actual2D preview, arrows cycling hair, fixed Back/Start and readable caption plates. Five new scene/script pairs plus presenter/parts and shared AvatarHair2D; new UI scripts19-88 lines. Explicit OptionButton/AppearanceGrid migration to typed rows retains normalization/selection coverage and public StartMenu/form flow. UI drafts never change game state; one-submit latch handles native/reentrant/double requests. Actual player/saved appearance matches preview; empty-customization NPC arc remains byte-identical after restoration. ISO-8a committed a683feb; ISO-8b uncommitted/no push. Human editor acceptance pending.

Created (26 files):
~~~text
docs/SCENE_CONTRACTS/character_creation.md
scripts/view/avatar_hair_2d.gd
scripts/view/avatar_hair_2d.gd.uid
tests/unit/test_profile_creation.gd
tests/unit/test_profile_creation.gd.uid
tests/unit/test_profile_preview.gd
tests/unit/test_profile_preview.gd.uid
ui/profile/avatar_preview.gd
ui/profile/avatar_preview.gd.uid
ui/profile/avatar_preview.tscn
ui/profile/choice_row.gd
ui/profile/choice_row.gd.uid
ui/profile/choice_row.tscn
ui/profile/choice_swatch.gd
ui/profile/choice_swatch.gd.uid
ui/profile/choice_swatch.tscn
ui/profile/name_fields.gd
ui/profile/name_fields.gd.uid
ui/profile/name_fields.tscn
ui/profile/profile_choices.gd
ui/profile/profile_choices.gd.uid
ui/profile/profile_choices.tscn
ui/profile/profile_parts.gd
ui/profile/profile_parts.gd.uid
ui/profile/profile_presenter.gd
ui/profile/profile_presenter.gd.uid
~~~

Modified (24 files):
~~~text
docs/API_INDEX.md
docs/ARCHITECTURE.md
docs/DECISIONS.md
docs/PROGRESS.md
docs/PROJECT_RULES.md
docs/ROADMAP.md
docs/SCENE_CONTRACTS/gray_box_world.md
docs/SCENE_CONTRACTS/hud.md
docs/SCENE_CONTRACTS/player.md
docs/SCENE_CONTRACTS/start_menu.md
docs/SCENE_CONTRACTS/ui_components.md
docs/UI_LAYOUT.md
localization/strings_en.csv
localization/strings_vi.csv
scripts/view/placeholder_avatar_2d.gd
scripts/view/start_menu.gd
scripts/view/ui_layout.gd
tests/unit/test_chibi_characters.gd
tests/unit/test_ui_layout.gd
tests/unit/test_ui_mouse.gd
tools/run_tests.bat
ui/title/profile_form.gd
ui/title/title_presenter.gd
ui/title/title_screen.gd
~~~

Scope audit:50 delivered files, all in approved ALLOW_LIST; zero outside. Owner docs/reference/THE_LIFE_MASTER_PLAN.txt leading blank line excluded/preserved. Allowed UiCoordinator/test_title_flow/test_title_layout needed no edits and were rerun. Godot generated new .gd.uid files. Core/domain/data/Main/WorldPresentation/TitleBackdrop/old scenes/art/Theme/ui-pause/components/project.godot/goldens and bounded-helper defaults unchanged. Only graphics-suite invocation adds TimeoutMs180000; tests/error-text/exit gates retained.

Clear diff: `git diff a683feb -- . ':(exclude)docs/reference/THE_LIFE_MASTER_PLAN.txt'` plus exact new files above. Combined review patch including new files: C:/Users/daova/AppData/Local/Temp/the_life_iso8b_review/iso8b_review.patch (generated after final validation). Same folder has42 clean vi/en screenshots: all six hair+palette indices at three sizes, plus long-name states. Reference02 PNG is never loaded as a runtime asset; existing title art and body renderer are retained.

Manual editor steps: none. Open project.godot in Godot4.7.2, allow import, F5 → New Game. Existing profile_form VBox mounts new ui/profile components; no old .tscn/Inspector/InputMap edits. See character_creation.md for current tree/API; start_menu.md labels old profile paths historical.

Manual cases (human pending):
- [ ] vi/en at1152x648,1280x720,1920x1080: left form/red ribbon and right preview/name plates fit; Back/Start stay fixed; scroll/focus exposes every palette row. Long names stay editable, captions wrap/ellipsis without changing draft text; tooltips retain full text.
- [ ] Click every one of six hair/skin/hair-color/outfit choices. Selected check/focus and actual preview update. Previous from0 wraps5; Next from5 wraps0. Arrows change hairstyle, not camera facing. No new3D/pet state or gameplay bonuses.
- [ ] Use Tab/Enter/Space and type B/I/E in name fields: GUI receives input without Bag/tool/world actions. Scroll follows focused choices. Escape/Back returns to title; reopen retains drafts. Locale refresh retains text/selection and updates captions/tooltips.
- [ ] Before Start, wallet/inventory/farm/pending game appearance/save remain unchanged. Start emits normalized appearance before the existing two-string callback once; double/reentrant input cannot create a second game. Back/reopen arms a fresh confirmation.
- [ ] Create with each cosmetic category, compare actual player to preview, save/load: same hair/colors/name/farm; original100-coin/new-world/starter-seed behavior and save-v8 schema remain. Old saves/IDs stay usable; NPC legacy hair remains unchanged.
- [ ] Pause/return/Continue/settings/day-end/weather/farming keep existing behavior. Preview body is current replaceable2D art; final reference-quality body/hat/scenery work is not implied.

Validation notes:
- Old form tests retain six-choice, duplicate-confirm, normalized values and real mouse dispatch assertions; only internal type/lookup access changed. No skipped/weakened tests.
- New saved-profile assertion canonicalizes both JSON sides because JSON represents integers as floats; all fields/values remain compared. Separate assertions check native integer selection and real Main load's normalized profile/player. No schema/fixture changed.
- Native render initially caught fractional edge overflow during panel bounce. Added4px real outer padding; kept strict containment assertions. Caption plates improve contrast over the retained illustration; filled player hair cap avoids an unintended skin gap. NPC arc branch stays unchanged.
- Final focused headless:7 scripts/32 tests/32 passing/2521 asserts/10.977s.
- Final clean renderer:2 scripts/8 tests/8 passing/964 asserts/11.787s. Includes native pixel differences for all six hair IDs, exact pixel parity between preview/game configuration for six palette/style combinations, and NPC legacy pixel restoration.
- Profile-preview script requires graphics/frame_post_draw and is covered by native focused/full suites; it is not passed to the headless-only subset. No tests are skipped inside it.
-42 clean captures retained before GUT's full-suite overlay overwrite. Reviewed vi default1152, en long1152, both-locale/profile color states1280 and en twin-puffs1920; form/actions/arrows/captions fit, all choices are reachable via scroll.
- ISO-8b final official validation (Godot4.7.2/GUT9.7.1, isolated APPDATA):

~~~text
[check_parse] OK
[validate_data] PASS

Official headless subset:
Totals
------
Scripts              16
Tests                62
Passing Tests        62
Asserts             879
Time              4.158s
---- All tests passed! ----

Final focused creation/title/profile/input headless:
Totals
------
Scripts               7
Tests                32
Passing Tests        32
Asserts            2521
Time             10.977s
---- All tests passed! ----

Separate clean graphics creation/preview suite:
Totals
------
Scripts               2
Tests                 8
Passing Tests         8
Asserts             964
Time             11.787s
---- All tests passed! ----

COMPLETE graphics-renderer suite:
Totals
------
Scripts              77
Tests               264
Passing Tests       264
Asserts           11480
Time              124.39s
---- All tests passed! ----

[run_tests] starting main scene headless
[run_tests] PASS
~~~

Final official/headless/main/focused/clean-render scan: zero SCRIPT ERROR/Parse Error/Failed to load script/ERROR/orphan/resource-leak matches. Existing deliberate malformed-data/negative-slot warnings remain. git diff --check PASS;50 delivered files inside approved scope, zero outside; protected source/goldens unchanged and owner's leading blank line remains1 insertion/0 deletions. No skipped/weakened tests, runtime error suppression or package installation. The full renderer really took124.39s, within the explicitly approved180s bound; other helper defaults and all gates unchanged.

Run automation: `$env:GODOT='D:\godot\Godot_v4.7.2-stable_win64_console.exe'; & tools/run_tests.bat`. Hidden bounded helper isolates APPDATA; player saves/settings are separate. Full graphics bound180s, other defaults120s unchanged. Logs: %TEMP%/the_life_{gut,headless,main,validate}.log.{stdout,stderr}; focused %TEMP%/the_life_iso8b_focused.log.{stdout,stderr}; clean render %TEMP%/the_life_iso8b_render.log.{stdout,stderr}.

Assumptions/limits: current body/scenery/flat Theme artwork is replaceable, not a new final-art commission. All six existing options are kept even though reference02 pictures fewer. Small viewport scrolls choices; names retain original empty-name fallback/no new validation. UI arrows cycle hair only. No domain/save/data/input/bus/autoload migration, package installation or log suppression. Human F5 playtest remains pending. gdtoolkit lint not run (not installed).

Proposed ISO-8b commit: feat: add modular farmer creation and shared 2d hair preview

## ISO-9 handoff and exact manifest (relative to 57008ab, D46)

Acceptance implemented: reference05 pinned newspaper composition, actual date/season/year, weather/three saved forecasts, real tutorial/garden status, current produce shipping-bin prices, fixed task strip and green Begin button. Six scene/script pairs plus three helpers; UI scripts20-54 lines. Uses existing Theme/weather symbols/cropped inventory icons, never the reference PNG. Weather/garden/market scroll independently; vi/en and three resolutions remain usable. Unsupported calendar/events/trends are explicit; no invented rewards or game state.

Main queues presentation after its existing completed-morning care/simulation/weather/journal/direct-save attempt. The next process frame waits for day-end advancement/final save/review/sleep/other modal to finish. Manual/direct/forced rollover tests prove one simulation and completed-morning save; Begin/Escape/locale refresh cannot add another day or mutate weather/farm/quests/ledger/wallet/inventory. UiCoordinator owns hold/input and restores prior pause. Same-day dedup and New Game/load/title reset guards are view-only. Tutorial/Continue/load do not auto-open; restored review retains precedence. Existing save version8/v1-v8 goldens, domain/core/data/DayEndFlow remain unchanged.

ISO-8b was committed57008ab after fresh validator PASS, exact50 files. ISO-9 remains uncommitted; no push. Human editor acceptance is pending.

Exact44-file delivery manifest (15 modified,29 created; matching .gd.uid included):

~~~text
M docs/API_INDEX.md
M docs/ARCHITECTURE.md
M docs/DECISIONS.md
M docs/PROGRESS.md
M docs/PROJECT_RULES.md
M docs/ROADMAP.md
M docs/SCENE_CONTRACTS/day_end.md
M docs/SCENE_CONTRACTS/hud.md
A docs/SCENE_CONTRACTS/morning_bulletin.md
M docs/SCENE_CONTRACTS/ui_components.md
M docs/UI_LAYOUT.md
M localization/strings_en.csv
M localization/strings_vi.csv
M scripts/view/main.gd
M scripts/view/ui_coordinator.gd
M scripts/view/ui_layout.gd
A tests/unit/test_morning_flow.gd
A tests/unit/test_morning_flow.gd.uid
A tests/unit/test_morning_layout.gd
A tests/unit/test_morning_layout.gd.uid
A ui/morning/garden_column.gd
A ui/morning/garden_column.gd.uid
A ui/morning/garden_column.tscn
A ui/morning/market_column.gd
A ui/morning/market_column.gd.uid
A ui/morning/market_column.tscn
A ui/morning/morning_flow.gd
A ui/morning/morning_flow.gd.uid
A ui/morning/morning_presenter.gd
A ui/morning/morning_presenter.gd.uid
A ui/morning/morning_sheet.gd
A ui/morning/morning_sheet.gd.uid
A ui/morning/morning_sheet.tscn
A ui/morning/morning_snapshot.gd
A ui/morning/morning_snapshot.gd.uid
A ui/morning/price_row.gd
A ui/morning/price_row.gd.uid
A ui/morning/price_row.tscn
A ui/morning/task_strip.gd
A ui/morning/task_strip.gd.uid
A ui/morning/task_strip.tscn
A ui/morning/weather_column.gd
A ui/morning/weather_column.gd.uid
A ui/morning/weather_column.tscn
~~~

All44 files are in the approved ISO-9 ALLOW_LIST, zero outside. Owner docs/reference/THE_LIFE_MASTER_PLAN.txt remains exactly its pre-existing leading blank line (1 insertion/0 deletions), excluded from delivery. Existing allowed day-end/weather/UI tests needed no edits and were rerun unchanged. All existing .tscn/core/domain/data/DayEndFlow/art/Theme/project.godot/InputMap/goldens/tools remain unchanged. No test weakening or timeout/error-gate edits. Godot generated the11 matching .gd.uid files.

Clear combined diff including new files: C:/Users/daova/AppData/Local/Temp/the_life_iso9_review/ISO-9-review.patch. Dry-run git apply --reverse --check validates against this working tree; no patch is applied and no staging/commit occurs. Clean24 screenshots plus contact-sheet.png and validation.txt are in the same review directory. These local review artifacts are outside the repository/ALLOW_LIST; no gameplay asset is added.

Real final test output (ANSI color codes omitted):

~~~text
Focused headless: morning_flow,morning_layout,day_end_flow,day_end_save,weather,ui_layout,ui_mouse
Scripts               7
Tests                30
Passing Tests        30
Asserts            2415
Time              10.132s
---- All tests passed! ----

Clean native renderer: morning_flow,morning_layout (-gopacity=0)
Scripts               2
Tests                 9
Passing Tests         9
Asserts             859
Time               6.004s
---- All tests passed! ----

tools/run_tests.bat (Godot4.7.2/GUT9.7.1, isolated APPDATA):
[check_parse] OK
[validate_data] PASS
Headless:
Scripts              16
Tests                62
Passing Tests        62
Asserts             879
Time               4.154s
---- All tests passed! ----
Complete graphics suite:
Scripts              79
Tests               273
Passing Tests       273
Asserts           12339
Time             131.425s
---- All tests passed! ----
[run_tests] starting main scene headless
[run_tests] PASS
~~~

Final focused/native logs: %TEMP%/the_life_iso9_{focused,render}.log.{stdout,stderr}. Official logs: %TEMP%/the_life_{parse,validate,headless,gut,main}.log.{stdout,stderr}. Final scans: zero SCRIPT ERROR/Parse Error/Failed to load script/ERROR/failing-summary/orphan/leak matches; native/focused stderr empty. Full-suite warnings are expected malformed-save/capacity/backend-rejection fixtures, including the deliberate slot -1 failure; the official runner exits0. Graphics bound remains the approved180s, all error gates unchanged. git diff --check passes.

During development, an initial snapshot guessed a needs_water field and added1 to an already one-based seasonal date; fixed to documented CropData.water_need and direct GameClock.get_day_in_season(). Direct-sleep tests initially assumed immediate completion; corrected to exercise the real accelerated sleep through public advance_minutes. No core/domain workaround or weakened assertion. Final code passed all checks above.

How to rerun from project root:

~~~powershell
.\tools\run_tests.bat
powershell -NoProfile -ExecutionPolicy Bypass -File tools/run_godot_bounded.ps1 -Godot 'D:\godot\Godot_v4.7.2-stable_win64.exe' -Arguments '--path . --script addons/gut/gut_cmdln.gd -gtest=res://tests/unit/test_morning_flow.gd,res://tests/unit/test_morning_layout.gd -gopacity=0 -gexit' -OutputPath "$env:TEMP\the_life_iso9_render.log"
~~~

Run test processes sequentially: they share the existing isolated APPDATA. Copy clean screenshots before the official full runner overwrites user:// captures with its visible GUT overlay. Tests never use player APPDATA/saves.

Manual editor acceptance (owner, still pending; no scene-tree/Inspector/project-setting edits required):

- [ ] F5 New Game/Continue: initial tutorial/save resumes normally without a morning bulletin. Reach20:00, interact with bed, inspect/cancel summary; no morning popup or domain advancement on cancel. Confirm sleep: summary closes, one morning bulletin appears at06:00 after the completed save.
- [ ] Compare real weather/forecast, garden counts (ripe/young/empty/withered/repeating tomato), tutorial progress and unit prices against the existing garden/shipping-bin data. Rain shows0 needs-water after actual morning care. No added weather roll or transaction on open/refresh/close.
- [ ] Click green Begin, repeat click, Escape, Tab/Enter/Space, mouse-wheel price scroll and ordinary modal switching. No tool action/item use or extra day. World/clock remain locked while visible and restore their prior hold after close. Day-end review always wins.
- [ ] Test forced02:00 review/confirm; still one rollover/bulletin. Load an old v1-v8 save, saved review and completed-morning save; no automatic bulletin/replay. Return-title/load/New Game clear pending popup; next actual sleep opens it once.
- [ ] Compare vi/en at1152x648,1280x720,1920x1080: all three columns/footer/button fit, long text wraps/scrolls, Vietnamese accents render and current icons/prices are readable. Empty/completed quest states remain truthful.

Known limits/assumptions: current placeholder2D world/art remains; newspaper approximates the reference composition with the existing shared Theme. Three saved forecasts are shown, not five invented entries. Birthdays/festivals/trends remain unavailable; no unsupported event/reward/XP/stamina system. Morning UI does not gate gameplay on save success: it waits until the existing completed save attempt returns; existing failure feedback/behavior is preserved. Bulletin dismissal is not saved, so loading a morning resumes gameplay without replaying it. Human F5 visual/game-feel approval remains required before marking roadmap rows complete.

Proposed ISO-9 commit: feat: add modular morning bulletin after completed day rollover

## ISO-10 handoff and exact manifest (relative to ec3c6d3, D47)

Acceptance implemented: reference07 five-tab wood/paper composition, actual saved farmer name/farm/2D portrait on the left, five explicitly unavailable skill rows and actual NPC relationship cards on the right, fixed key-hint plate/Close. Seven scene pairs plus flow/presenter/snapshot helpers, UI scripts11-43 lines. Existing native Theme/PlaceholderAvatar2D/catalogue/hair rendering are reused; all six player cosmetic choices and actual NPC colors/hair match game avatars. No reference PNG/new artwork/Theme mutation.

Current social world registers Minh and Linh (two), independent of the catalogue's additional appearance recipes. Show all registered NPCs, exact friendship/per-NPC cap plus five floor-ratio hearts; no fictional birthday/role/gift/discount or remote talk. Display/refresh/locale/scroll/close cannot earn friendship, mutate profile/social/quests/farm/weather/inventory/wallet/journal or advance time. Skills/XP/levels/bonuses remain unavailable, with no false bars/stats/actions. New Game/load/title close stale presentation; open rereads actual values.

Approved tab migration: Bag0/Character1/Quest2 enabled, existing Q/E move forward/reverse with wrap, mouse headers/Close work across all three. Calendar3/Map4 stay disabled; J/B/I retain existing targets. InventoryController remains the shared request router; Main wires the read-only Character flow before inventory attach/UiCoordinator configure. UiCoordinator owns exclusivity/clock/world hold and prior-hold restoration; title/tutorial/sleep guards and manual/forced day-end precedence remain. Native Tab/Space/Enter stay GUI input. No new action/autoload/bus/save/UI flags or domain/core/data/old-scene/renderer changes.

ISO-9 committed **ec3c6d3** after fresh DataValidator PASS, exact44 files including the plan; owner master-plan edit excluded. ISO-10 is uncommitted/no push. Human editor acceptance remains pending.

Exact51-file delivery manifest (19 modified,32 created; matching .gd.uid included):

~~~text
M docs/API_INDEX.md
M docs/ARCHITECTURE.md
M docs/DECISIONS.md
M docs/INPUT_MAP.md
M docs/PROGRESS.md
M docs/PROJECT_RULES.md
M docs/ROADMAP.md
A docs/SCENE_CONTRACTS/character.md
M docs/SCENE_CONTRACTS/hud.md
M docs/SCENE_CONTRACTS/inventory.md
M docs/SCENE_CONTRACTS/ui_components.md
M docs/UI_LAYOUT.md
M localization/strings_en.csv
M localization/strings_vi.csv
M scripts/view/main.gd
M scripts/view/ui_coordinator.gd
M scripts/view/ui_layout.gd
A tests/unit/test_character_layout.gd
A tests/unit/test_character_layout.gd.uid
A tests/unit/test_character_screen.gd
A tests/unit/test_character_screen.gd.uid
M tests/unit/test_inventory_screen.gd
A ui/character/avatar_portrait.gd
A ui/character/avatar_portrait.gd.uid
A ui/character/avatar_portrait.tscn
A ui/character/character_flow.gd
A ui/character/character_flow.gd.uid
A ui/character/character_presenter.gd
A ui/character/character_presenter.gd.uid
A ui/character/character_sheet.gd
A ui/character/character_sheet.gd.uid
A ui/character/character_sheet.tscn
A ui/character/character_snapshot.gd
A ui/character/character_snapshot.gd.uid
A ui/character/identity_card.gd
A ui/character/identity_card.gd.uid
A ui/character/identity_card.tscn
A ui/character/relationship_card.gd
A ui/character/relationship_card.gd.uid
A ui/character/relationship_card.tscn
A ui/character/relationship_list.gd
A ui/character/relationship_list.gd.uid
A ui/character/relationship_list.tscn
A ui/character/skill_row.gd
A ui/character/skill_row.gd.uid
A ui/character/skill_row.tscn
A ui/character/skills_panel.gd
A ui/character/skills_panel.gd.uid
A ui/character/skills_panel.tscn
M ui/inventory/common_tabs.gd
M ui/inventory/inventory_controller.gd
~~~

All51 files are inside the approved ISO-10 ALLOW_LIST, zero outside. Existing allowed inventory_ui/ui_layout/ui_mouse test files needed no edits and were rerun. Only inventory_screen's approved enabled-tab assertion/traversal changed: it now checks Character before continuing E to Quest and Q back through Character to Bag; all original sort/selection/quantity/farm/world/day-end assertions remain. No test removed/weakened/skipped. Godot generated12 new .gd.uid files. Owner docs/reference/THE_LIFE_MASTER_PLAN.txt stays its pre-existing leading blank line (1 insertion/0 deletions), excluded from delivery. Core/domain/data/NpcSystem/NpcPanel/old scenes/avatars/appearance/hair/art/Theme/project.godot/v1-v8 goldens/tools/timeouts/error gates remain unchanged. INPUT_MAP docs only describe the existing actions' extra enabled tab.

Real focused/native test output (ANSI codes omitted):

~~~text
Focused headless: character_screen,character_layout,inventory_screen,inventory_ui,ui_layout,ui_mouse,day_end_flow,morning_flow
Scripts               8
Tests                36
Passing Tests        36
Asserts            2979
Time              36.389s
---- All tests passed! ----

Clean native renderer: character_screen,character_layout (-gopacity=0)
Scripts               2
Tests                 8
Passing Tests         8
Asserts            1041
Time               8.75s
---- All tests passed! ----
~~~

Official full-suite output (Godot4.7.2/GUT9.7.1, isolated APPDATA):

~~~text
[check_parse] OK
[validate_data] PASS
Headless:
Scripts              16
Tests                62
Passing Tests        62
Asserts             879
Time               4.992s
---- All tests passed! ----
Complete graphics suite:
Scripts              81
Tests               281
Passing Tests       281
Asserts           13383
Time             148.329s
---- All tests passed! ----
[run_tests] starting main scene headless
[run_tests] PASS
~~~

Final focused/native logs: %TEMP%/the_life_iso10_{focused,render}.log.{stdout,stderr}. Official logs: %TEMP%/the_life_{parse,validate,headless,gut,main}.log.{stdout,stderr}. Final import/focused/native/official scans: zero SCRIPT ERROR/Parse Error/Failed to load script/ERROR/failing-summary/orphan/leak matches; focused/native stderr empty. Full-suite warnings are expected malformed-save/capacity/backend-rejection fixtures (including deliberate slot -1), runner exit0. Graphics bound remains180s and all original error gates are unchanged.

Clean36 vi/en captures (24 resolution/friendship/name cases,12 cosmetic-choice cases), contact-vi.png/contact-en.png and review artifacts are outside the repository at C:/Users/daova/AppData/Local/Temp/the_life_iso10_review. PNGs were copied before the full runner overwrites user:// captures with its GUT overlay. Full clear diff including all new files: ISO-10-review.patch; validation.txt/full logs live beside it. git apply --reverse --check dry-run validates the combined patch against this tree; no patch is applied, no index staging or ISO-10 commit. git diff --check passes;51/51 scope/manifest match, zero protected-file changes. These review artifacts are not runtime assets.

During development, rebuilding/detaching cards on every refresh left queued nodes visible to GUT's immediate orphan audit after rapid teardown. Reuse stable NPC controls now preserves scroll and avoids that churn; final focused/native runs have no orphans. The first scroll fixture assumed four world NPCs from the appearance catalogue; actual world data has two fitting cards. The corrected test keeps its physical-scroll assertion using eight repeated real display rows in an isolated view snapshot; it never adds NPCs to domain/data and separately asserts production card count matches registered NPCs. Adding a readable hint plate exposed29px excess minimum height at1152; existing18px body-text variation for unavailable skill labels restores fit without weakening bounds checks or changing Theme.

How to rerun from project root:

~~~powershell
.\tools\run_tests.bat
powershell -NoProfile -ExecutionPolicy Bypass -File tools/run_godot_bounded.ps1 -Godot 'D:\godot\Godot_v4.7.2-stable_win64.exe' -Arguments '--path . --script addons/gut/gut_cmdln.gd -gtest=res://tests/unit/test_character_screen.gd,res://tests/unit/test_character_layout.gd -gopacity=0 -gexit' -OutputPath "$env:TEMP\the_life_iso10_render.log"
~~~

Run test processes sequentially; existing bounded helper isolates APPDATA/user data under TEMP, never player saves. Full graphics bound remains180s and all original gates stay intact.

Manual editor acceptance (owner, pending; no scene-tree/Inspector/project-setting work):

- [ ] F5/New Game/Continue, B opens Bag; E -> Character -> Quest -> Bag, Q reverses/wraps. Click all three headers/current tab/Close; Calendar/Map remain disabled. J still opens journal and B/I switch to Bag. No duplicate panels or world E/Q action.
- [ ] Compare actual saved name/farm/six hairstyles/skin/hair/outfit colors with the world player. Open after new-game/load/title to confirm no stale name/portrait. Old v1-v8 saves keep existing defaults/migration and format8; saved day-end review remains primary.
- [ ] Inspect Minh/Linh cards against journal numeric friendship and actual NPC colors/recipes. Talk through the existing nearby dialogue, reopen Character and compare points/hearts. Looking/scrolling/locale refresh alone earns nothing and changes no dialogue history/quest/coin/item/weather/farm state.
- [ ] Native Tab/Space/Enter and wheel work as GUI actions; Escape/Close restore original pause/input hold. With a running clock it resumes, with a prior hold it stays held. Character cannot bypass title/tutorial/sleep/manual or forced day-end review. Morning bulletin and pause behavior still work.
- [ ] Compare vi/en at1152x648,1280x720,1920x1080: long names wrap, portrait/skill rows/NPC cards/hint/Close fit; accents render. Skills/XP/levels/benefits are explicitly unavailable. No equipment/gifting/remote-talk actions appear.

Known limits: placeholder2D body/art remains replaceable and is not final mockup artwork. Only actual registered NPCs appear, currently two; shared cards can scroll with more. Five hearts are a display ratio, not gameplay tiers or romance. Skills/XP/bonuses/birthdays/gifting/calendar/map remain unavailable. No new state/save schema is implied. Human F5 visual/game-feel acceptance remains required before marking roadmap rows complete.

Proposed ISO-10 commit: feat: add modular character profile and real npc relationships

## ISO-11 handoff and exact manifest (relative to b44c5d5, D48)

Acceptance implemented: reference08 common tabs/wood-paper two-page composition, All/Active/Completed filters and selectable list, actual giver2D portrait/description/read-only objectives/current Resource reward terms, independently scrolling detail and fixed disabled Pin/Map controls/key plate. Seven scene pairs plus controller/presenter/snapshot; UI scripts15-91 lines. Current real content is seven onboarding flags and one Minh delivery quest; current NPC friendship summary remains. No mockup texture/new art/Theme change or fabricated daily/XP/deadline/tier/pin/map state.

NpcJournal remains the same NpcPanel root. Journal-only enable_quest_book/show_quest_book/book/book_controller attach the new branch; legacy margin is hidden and existing column/title_label/close_button/show_content/enable_tabs/close_requested stay for dialogue/standalone callers. Original dialogue action selectors/acceptance/delivery/payout/reach/capacity/save guards remain. NpcSystem.open_journal delegates with legacy fallback; InventoryController connects the actual common header. Native journal ui_* pass-through lets Tab/Enter/Space work before world shortcuts, preserving Q/E/J/B/I, prior clock hold/world lock and day-end precedence.

UI owns only transient filter/selection/scroll. Owner signals coalesce a deferred refresh after transactions/emitting controls finish; valid selection/scroll persist, changing tasks starts detail at top, Main resets on new-game/load/title. Opening/filtering/selecting/locale/scroll/dismiss cannot accept/complete/talk/payout/grant/remove/simulate/reroll. Completed delivery can show0 current bag items; rewards remain task terms, not another payout/history. Onboarding has no listed reward. Nearby original NPC dialogue still pays exactly once; full bag/duplicate failure snapshots stay identical.

ISO-10 committed **b44c5d5** after fresh DataValidator PASS, exactly51 files including approved plan, excluding owner's master-plan edit. ISO-11 remains uncommitted/no push. Human F5 acceptance remains pending.

Exact49-file delivery manifest (17 modified,32 created; matching .gd.uid included):

~~~text
M docs/API_INDEX.md
M docs/ARCHITECTURE.md
M docs/DECISIONS.md
M docs/PROGRESS.md
M docs/PROJECT_RULES.md
M docs/ROADMAP.md
M docs/SCENE_CONTRACTS/hud.md
M docs/SCENE_CONTRACTS/inventory.md
A docs/SCENE_CONTRACTS/quest_book.md
M docs/SCENE_CONTRACTS/ui_components.md
M docs/UI_LAYOUT.md
M localization/strings_en.csv
M localization/strings_vi.csv
M scripts/view/main.gd
M scripts/view/npc_panel.gd
M scripts/view/npc_system.gd
M scripts/view/ui_coordinator.gd
A tests/unit/test_quest_book.gd
A tests/unit/test_quest_book.gd.uid
A tests/unit/test_quest_book_layout.gd
A tests/unit/test_quest_book_layout.gd.uid
M ui/inventory/inventory_controller.gd
A ui/quests/book_controller.gd
A ui/quests/book_controller.gd.uid
A ui/quests/book_presenter.gd
A ui/quests/book_presenter.gd.uid
A ui/quests/book_snapshot.gd
A ui/quests/book_snapshot.gd.uid
A ui/quests/filter_bar.gd
A ui/quests/filter_bar.gd.uid
A ui/quests/filter_bar.tscn
A ui/quests/objective_row.gd
A ui/quests/objective_row.gd.uid
A ui/quests/objective_row.tscn
A ui/quests/quest_book.gd
A ui/quests/quest_book.gd.uid
A ui/quests/quest_book.tscn
A ui/quests/quest_detail.gd
A ui/quests/quest_detail.gd.uid
A ui/quests/quest_detail.tscn
A ui/quests/quest_list.gd
A ui/quests/quest_list.gd.uid
A ui/quests/quest_list.tscn
A ui/quests/quest_row.gd
A ui/quests/quest_row.gd.uid
A ui/quests/quest_row.tscn
A ui/quests/reward_card.gd
A ui/quests/reward_card.gd.uid
A ui/quests/reward_card.tscn
~~~

All49 files are in the approved ALLOW_LIST, zero outside. Allowed UiLayout/old NPC/inventory/character/UI test files needed no edits and were rerun unchanged; no test weakened/removed/skipped. Godot generated12 matching .gd.uid files. Core/domain/data, all existing .tscn, ui/character/title/profile/pause/morning/day_end/theme, avatar/appearance/hair/art, project.godot/InputMap bindings, v1-v8 goldens/tools/timeouts/error gates remain unchanged. Owner docs/reference/THE_LIFE_MASTER_PLAN.txt is still its pre-existing leading blank line (1 insertion/0 deletions), excluded from delivery.

Real focused/native output (ANSI codes omitted):

~~~text
Focused headless: quest_book,quest_book_layout,npc_ui,npc_quest_delivery,inventory_screen,character_screen,ui_layout,ui_mouse,day_end_flow
Scripts               9
Tests                40
Passing Tests        40
Asserts            2957
Time              43.656s
---- All tests passed! ----

Clean native renderer: quest_book,quest_book_layout (-gopacity=0)
Scripts               2
Tests                 8
Passing Tests         8
Asserts             876
Time              12.923s
---- All tests passed! ----
~~~

Official full-suite output (Godot4.7.2/GUT9.7.1, isolated APPDATA):

~~~text
[check_parse] OK
[validate_data] PASS
Headless:
Scripts              16
Tests                62
Passing Tests        62
Asserts             879
Time               4.943s
---- All tests passed! ----
Complete graphics suite:
Scripts              83
Tests               289
Passing Tests       289
Asserts           14259
Time             162.897s
---- All tests passed! ----
[run_tests] starting main scene headless
[run_tests] PASS
~~~

Final focused/native logs: %TEMP%/the_life_iso11_{focused,render}.log.{stdout,stderr}. Official logs: %TEMP%/the_life_{parse,validate,headless,gut,main}.log.{stdout,stderr}. Final import/focused/native/official scans: zero SCRIPT ERROR/Parse Error/Failed to load script/ERROR/failing-summary/orphan/leak matches; focused/native stderr empty. Full-suite warnings are expected malformed-save/capacity/backend-rejection fixtures (including deliberate slot -1), runner exit0. Graphics bound remains180s, every original error gate unchanged.

Clean42 vi/en captures at1152x648,1280x720,1920x1080 cover tutorial/new/active/ready/completed/empty/long states; two contact sheets and review artifacts are outside the repo at C:/Users/daova/AppData/Local/Temp/the_life_iso11_review. Copying before the full runner preserves clean captures without its GUT overlay. Full diff including all new files: ISO-11-review.patch, with validation.txt/logs beside it. git apply --reverse --check dry-run validates this combined patch against the tree, without applying/staging/committing it. git diff --check PASS,49/49 scope/manifest match and zero protected-file changes. Review artifacts are not runtime assets; ISO-11 remains uncommitted.

Development correction: the first parse called existing LifeHudParts.texture with a missing required icon argument. Reading its actual signature and passing null fixed the parse/cascade errors; no helper/domain/API or tests were changed to hide failure. Final native tests also verify changing a scrolled task resets detail to top. UI-only overflow tests repeat real display snapshots/long text, never add production quests or mutate Resources. Old dialogue/transaction tests pass unchanged.

How to rerun from project root:

~~~powershell
.\tools\run_tests.bat
powershell -NoProfile -ExecutionPolicy Bypass -File tools/run_godot_bounded.ps1 -Godot 'D:\godot\Godot_v4.7.2-stable_win64.exe' -Arguments '--path . --script addons/gut/gut_cmdln.gd -gtest=res://tests/unit/test_quest_book.gd,res://tests/unit/test_quest_book_layout.gd -gopacity=0 -gexit' -OutputPath "$env:TEMP\the_life_iso11_render.log"
~~~

Run test processes sequentially: existing bounded helper shares isolated TEMP APPDATA; player saves/settings are never used. Graphics bound remains180s, all original error/exit gates intact.

Manual editor acceptance (owner, pending; no scene-tree/Inspector/project-setting changes):

- [ ] F5/J opens new Sổ nhiệm vụ; Q/E/mouse travel Bag/Character/Quest, current-tab click stays selected, Close/Escape/J closes normally. Native Tab/Enter/Space select filters/rows/header without world actions or accidental Bag opening. Prior running/held clock state restores; title/tutorial/sleep/manual/forced review retain guards.
- [ ] Compare onboarding's seven actual flags with pinned HUD; no reward/XP invented. All/Active/Completed counts and empty states match actual accepted/completed quests. Daily/Pin/Map remain unavailable and no T hint/action appears.
- [ ] Inspect actual Minh quest/giver portrait/current bag quantity/Resource coin and seed reward. Receive via original nearby dialogue, collect items, reopen/select and compare. Full bag/shortage prevents original delivery; successful original confirmation pays once, book refreshes completed while current bag may show0. Repeated confirmation adds nothing.
- [ ] Filter/select/scroll/change locale repeatedly without accepting/completing quests, spending/granting anything, talking, rerolling weather or changing day. Switch tasks after scrolling: detail starts at top. Friendship summary remains actual and does not gain points from viewing.
- [ ] New Game/load/title reset transient selection/filter; old v1-v8 saves keep domain state/format8 and restored review precedence. vi/en at1152x648,1280x720,1920x1080 retain readable accents, independent scroll and fixed actions; long text has no overlap.

Known limits: existing placeholder2D portrait/art remains replaceable, not final mockup art. Production has one registered delivery quest plus onboarding; the list is not padded with fictional tasks. Daily/XP/deadlines/ranks/pinning/map are unavailable. The journal is informational; original nearby NPC dialogue handles acceptance/delivery/rewards. Completed-state Resource terms do not reconstruct historical rewards; current possession is not delivery history. No save schema/state expansion. Human F5/game-feel approval remains required before marking roadmap complete.

Proposed ISO-11 commit: feat: add modular quest book using existing task state
