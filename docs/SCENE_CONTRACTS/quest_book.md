# ISO-11 Quest book (D48)

## Phase7.3h ecology entry (D113)

Existing J/modal/common tabs/4filters and all quest APIs remain. LifeQuestBook now exposes navigation:HBoxContainer (compact Ecology entry then existing tabs/Close), paper/body containers, ecology_button and nullable ecology_sheet. Book controller owns LifeEcologyController. Explicit entry lazily instantiates small ecology sheet/metric/source scene pairs inside same paper; Back/reset/close detaches/queue_frees page and restores unchanged quest body. Ordinary quest mode still has no ProgressBar descendants, preserving original no-fake-XP acceptance/tests. NpcPanel.show_quest_book and existing book reset restore quest mode; nativeJ/QE/Esc, modal lock and original accept/deliver/reward routes remain. UI controller only reads actual state, coalesces owner/locale refresh, guards stale work/focus, persists no mode. Full typed tree in ecology.md. No InputMap/Main/old .tscn/Theme edits or editor setup; manual J->Ecology->Back/scroll/live locale/load/title/day-end checks supplement original quest cases.

Owner approved commit ISO-10 and implement ISO-11. Commit b44c5d5 records51 ISO-10 files after fresh validator PASS, excluding owner master-plan edit. Main/NpcJournal remains the same NpcPanel root; existing scenes/domain/data/core/dialogue/public APIs/save-v8 remain unchanged.

NpcPanel adds book: LifeQuestBook, book_controller: LifeQuestBookController; enable_quest_book(main: Node), show_quest_book() -> void. InventoryController.attach_main enables this journal-only branch before connecting tabs; tabs points at book.tabs. The old journal margin is hidden, not removed; existing column/title_label/close_button/show_content/enable_tabs/close_requested stay for dialogue/standalone compatibility. New content uses a Theme-backed outer margin/clear root. Dialogue tree/AcceptQuest/DeliverQuest/ConfirmOffer selectors are unchanged. NpcSystem.open_journal keeps guards/lock and selects the new branch, legacy fallback if absent.

| Scene / class | Root | Typed view API |
|---|---|---|
| quest_book / LifeQuestBook | VBoxContainer | tabs: LifeInventoryTabs; filters: LifeQuestFilters; list: LifeQuestList; people: Label; detail: LifeQuestDetail; hint: Label |
| filter_bar / LifeQuestFilters | GridContainer | buttons: Array[Button]; filter_requested(id: StringName); display(active: StringName, counts: Dictionary) -> void; All/Active/Completed, Daily disabled |
| quest_list / LifeQuestList | ScrollContainer | rows: VBoxContainer; empty: Label; selected(key: String); display(values: Array[Dictionary], key: String) -> void |
| quest_row / LifeQuestRow | Button | display(row: Dictionary, selected: bool) -> void; metadata key only, no game action |
| quest_detail / LifeQuestDetail | VBoxContainer | scroll: ScrollContainer; title/giver/description/status/visit: Label; portrait: LifeCharacterPortrait; objectives: VBoxContainer; rewards: LifeQuestReward; pin_button/map_button: Button (disabled); display(row: Dictionary, main: Node) -> void |
| objective_row / LifeQuestObjective | HBoxContainer | text: Label; display(row: Dictionary) -> void; read-only completion glyph/current quantity |
| reward_card / LifeQuestReward | PanelContainer | coins/item/note: Label; icon: TextureRect; display(row: Dictionary) -> void; current Resource terms only |

LifeQuestBookController.configure(owner_panel: NpcPanel, main: Node), reset(), queue_render(), select(key: String), filter(id: StringName) -> void; selected_key: String, active_filter: StringName. Owns only transient selection/filter. Hidden queue renders nothing; opening refreshes. Tutorial step/social/inventory signals queue deferred render after transactions/emitting Buttons complete. Main closes/reset journal book UI on New Game/load/title. No persisted UI flags.

QuestBookSnapshot.capture(main: Node) -> Dictionary: entries plus actual NPC friendship rows. Each entry has a view key (onboarding or delivery:<existing quest id>), existing data id when applicable, tutorial bool, title/description keys, giver id, status, current progress/target, objective snapshots, Resource reward fields. Onboarding uses actual seven boolean STEP_KEYS/flags, no giver/reward. Delivery uses registered QuestManager/QuestData, current bag amounts and actual completion flag; possession is not delivery history. QuestBookPresenter.render(book: LifeQuestBook, snapshot: Dictionary, filter: StringName, key: String, main: Node) -> String returns the retained/first visible selection. No mutations/rewards/talk/simulation/roll/save.

Tree: common tabs -> wood/paper HBox(left filters, scrollable list, compact real friendship summary; right independently scrollable detail/objectives/rewards with fixed disabled pin/map controls) -> fixed Q/E/Escape hint plate. All3 enabled tabs remain0/1/2; Daily/pin/map/XP/deadlines/quest-tier metadata unavailable, no T binding. Original nearby dialogue alone accepts/delivers/pays. Native journal ui_* pass-through in NpcSystem/UiCoordinator prevents Space/Tab world interception, no dialogue behavior change. Existing clock/world modal owner/prior hold/day-end precedence remain.

Manual F5/J: select/filter actual onboarding/delivery entries, compare flags/current bag/Resource rewards/giver/points; nearby NPC accept/deliver still pays exactly once, book refreshes afterward. Check full/shortage/ready/done/empty states, Bag/Character/Quest Q/E/J/Close, native focus/scroll, old saves/new-game/load/title, vi/en/three sizes/long text. No scene-tree/Inspector/project-setting edits needed. Current production has one delivery quest; UI overflow tests may repeat display snapshots only, never domain content.

## Phase8.6h notebook branch

LifeQuestBook adds story_button:Button and nullable story_sheet:LifeStoryNotebook. Book controller owns LifeStoryNotebookController; configure/open/close/reset/is_open/queue_render are transient VIEW APIs. Ecology open closes story; story open closes ecology; existing ecology reset also drops story so NpcPanel.show_quest_book always returns to quests. New/load/title book reset and deferred hidden cleanup free the lazy branch. Native J/Q/E/Esc and all three existing tabs/quest counts remain. Six small shared-theme scenes compose a header, independently scrolling objective and milestone lists/rows, and fixed Back. No new InputMap or editor setup.

## Phase8.6i optional pages

The lazy notebook objective scroll contains six small page_link Buttons before objectives. Only available pages enable; read markers come from StoryState. page_requested(page_id:StringName) routes to Main.story_moment_flow; opening the separate shared-theme modal closes the journal through UiCoordinator. Cancel/Esc returns to a fresh notebook, confirmation alone acknowledges captured revision. Tab/Enter stay native; other journal/world shortcuts are held. Lifecycle closes without reopening or acknowledging. No new key, editor scene setup or reward.
