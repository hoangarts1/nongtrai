# ISO-3 modular HUD contract

## Phase6.5h2b actual water amount beside toolbar caption (D78)

No .tscn/Theme/font/right-card/region/HotbarPanel/UiCoordinator edit. LifeHudToolbar script adds centered StatusRow HBox; existing caption Panel now named CaptionPanel with same public caption reference/text, plus new WaterMeter (LifeHudWaterMeter). Existing frame/eight slots/TOOLS/request/display/signals/selection/hidden adapter paths retain behavior. StatusRow shares caption-row height; overall toolbar rectangle stays. Exact generated subtree is in watering.md.

LifeHudWaterMeter.display(charges:int,capacity:int) reads actual Main can through LifeHudPresenter's local Runtime.water_changed connection. Existing watering_can icon and LifeHudCaption/CaptionText theme variations are reused. Amount is localized WATER_CAN_COUNT; empty tooltip is gentle guidance. Live locale, reset/load/known40 capacity and0/partial/full reflect authoritative state. Cached display values are not a gameplay owner; no can mutation occurs in layout/render or locale changes.

Pointer-ignore meter/row preserve qualified wheel/map zoom and GUI input. Modal/title visibility follows existing HotbarPanel. Verify vi/en800/1152/1600 count/caption/slots and original C3 selected-item captions; right cards have no extra row. Native capture/owner and complete-gate results in PROGRESS. No new shortcut or purchase UI. Main's savev10 integration includes actual charges; old standalone/infinite notes below are historical.

## D72-C4 live-language label/feedback correction (D76)

No scene/tree/Inspector/InputMap/Theme/localization-file edit. Existing WorldPresentation-created House/SeedShop/ShippingBin art labels and NpcSystem.homes labels respond to the existing translation notification, using current profile name/NpcData and existing keys. The same nodes/positions/colors/colliders/appearance and paused animation phases remain. Requesting redraw updates the decorative label pill while paused; it does not reconfigure/reset art. Empty/unconfigured/teardown states are guarded. Player-authored names stay unchanged.

Existing HudRoot.toasts dismisses old formatted messages on an actual locale change. Hide immediately during tree notification, free captured old IDs afterward; show_message flushes only dismissed IDs before adding new cards. Three-second/max-two and same-locale lifetime stay unchanged. Old deferred timer IDs cannot affect replacements. Public view APIs/signals remain; no event replay/metadata/Settings/domain/save change. Earlier startup-language residue described below is the historical C1/C3 limitation corrected here for these named labels and visible toasts, not a claim about every other UI/debug string.

Manual: on one running game with visible feedback, use existing pause/settings Apply to switch vi->en->vi; player/shop/bin/NPC-home signs change without reopening game, old toast disappears, subsequent feedback uses chosen language. Same-language Apply keeps existing feedback under normal max-two policy. Inspect paused pill text/geometry and preserve current player name/location/appearance/items/coins/crops/jobs/NPC state. No editor wiring. Full measured proof/status in PROGRESS.

## D72-C3 current toolbar selection (D75)

Existing node tree/scene/public signals/methods stay unchanged. Eight buttons comprise four tools0-3 (hoe/shovel/watering/harvest), then four item buttons4-7. Display selection uses the same four-tool offset as request; caption/tooltip/icon/quantity and selected style correspond to the real item. Invalid/empty/out-of-window selection clears selected styling and resets caption through the existing UI_TOOL_SEED translation. No new label, key, Resource, asset or Theme binding.

HotbarPanel select/remap derives pages from actual four item buttons: bag0-3/page0,4-7/page4,8-11/page8. Legacy physical9 still selects bag8, now visible button4 (key5); the previous display offset/page5 defect below is historical and corrected by D75. Native5-8/clicks/F-selection and page-local Shift/toolbar wheel resolve the same actual stacks; empty last-page slots cannot request nonexistent items. Domain state and camera/modal/placement behavior remain unchanged. No editor wiring/Inspector step. Manual: select first seed (button5, not harvest), cross bag3->4/7->8, try9/F/sort/discard, scroll both ways on partial pages, inspect vi/en caption/icon/quantity and empty bag fallback. Full proof in PROGRESS.

ISO-11 replaces only NpcJournal's script-created content branch with the modular Quest book; root/header/tab2/HUD lock remain. Seven real onboarding flags and actual delivery state are read-only; current pinned HUD onboarding is unchanged and T remains unbound. Original NPC dialogue alone accepts/delivers/rewards. Existing modal owner/prior hold/day-end precedence remain; see quest_book.md.

ISO-10 registers CharacterScreen through Main.character_flow before inventory attach/UiCoordinator configure. Existing common tabs/Q/E reach Character; no new HUD shortcut or InputMap action. World/interactive HUD remain locked under the same modal owner; title/tutorial/sleep/day-end guards and prior-hold restoration remain. Seven read-only scene pairs reuse actual profile/NPC portraits; see character.md.

ISO-9 registers MorningBulletin with the existing exclusive modal owner. Main wires morning_flow after day_end_flow and before UiCoordinator.configure; only the existing completed rollover queues presentation. Interactive HUD/world input is suppressed while visible, prior pause restores on dismissal, native GUI keys win over world shortcuts and day-end remains primary. No HUD binding/InputMap/bus changes. See morning_bulletin.md.

ISO-8b changes only creation mode within the existing start modal: wide two-panel form/preview, native six-choice rows, no new HUD binding. World/HUD lock remains UiCoordinator-owned; see character_creation.md. No game state before Start.

ISO-8a updates StartMenu's script-built internals only (start_menu.md). Main/StartMenu and gameplay HUD paths stay unchanged; title/profile/settings share the existing start modal and world lock. No new HUD shortcut, gameplay state or InputMap action.

ISO-7 keeps all HUD/toolbar APIs and adds a modular wide pause/settings consumer (pause_menu.md). UiCoordinator still hides interactive HUD during pause; settings own only drafts. Native GUI navigation wins over overlapping Tab/Space world shortcuts inside this modal. DayEndSheet retains precedence. No scene, InputMap, signal-bus or game-state changes.

ISO-6b1 keeps the same HUD/toolbar/InputMap. The existing inspector note shows real repeat growth; dryness warnings win when applicable. Seed choice/quantity remains the actual inventory; repeat harvest does not consume a seed. Bag unit sale captions read the approved updated ItemData. No house-upgrade or fertilizer shortcut is added.

ISO-6a adds the actual dry-day warning to CropInspector's existing note_label only; no HUD scene, toolbar, shortcut, modal or InputMap change. note_label refreshes on locale/plot changes and clears after successful watering. The withered state disables actions even for previously ripe crops. See gray_box_world.md/D41 for the data/domain owner and day-boundary order.

ISO-5 keeps toolbar/shortcut APIs and adds InventoryPanel's modular 40-cell screen plus shared journal header (inventory.md). F explicitly selects an existing stack; sort/discard remap surviving toolbar selection without another tool action. Q/E are modal-only. DayEndSheet retains precedence.

Approved by owner: “Duyệt ISO-3, bắt đầu triển khai”. All new files below are under `ui/hud/`. Main keeps existing direct public node paths and view APIs; thin adapters delegate to the new views. No domain or save state moves into UI.

ISO-4 registers DayEndSheet with the same modal owner. During summary review the interactive HUD is hidden, result toasts follow existing modal suppression, and world input is locked. LifeDayEndFlow owns domain journal/guard states; the sheet/presenter only display them. Clock/coins/quest/toolbar APIs and Main's existing paths remain compatible. See day_end.md.

| Scene/script | Responsibility / runtime children |
|---|---|
| hud_root / LifeHudRoot | non-interactive full-rect shell; RightColumn VBox -> ClockCard, WalletFrame/CoinLabel; ToastStack |
| clock_card / LifeHudClockCard | wood frame -> paper -> weather/date row, season/year, ClockArc, time, forecast |
| clock_arc / LifeHudClockArc | draws sun/moon/rain and time-of-day arc only |
| quest_card / LifeHudQuestCard | pinned paper -> title, actual completed/total, up to three existing checklist rows |
| toolbar / LifeHudToolbar | selected caption over wood frame -> eight ToolbarSlot buttons |
| toolbar_slot / LifeHudToolbarSlot | native Button icon plus Key/Quantity Labels; no inventory ownership |
| shortcut_bar / LifeHudShortcutBar | native round buttons for supported inventory/journal/help/pause actions |
| toast_stack / LifeHudToastStack | up to two ToastCard children, bounded timers |
| toast_card / LifeHudToastCard | themed pill -> icon and wrapped message |

Helpers: LifeHudParts constructs localized/theme-driven text and texture Controls; LifeHudFrame draws decorative grain/studs from shared palette; LifeHudRegions applies viewport anchors to existing adapter roots and HUD right column/stack. LifeHudPresenter observes existing state/signals and coordinates visibility; it owns no game state. Layout and binding are separate scripts, each small and focused.

Public view APIs: ClockCard.display(day, day_in_season, year, season_text, minute, weather_id, forecast_text); QuestCard.display(keys, completed); Toolbar.display(slots, selected_inventory, active_tool, window_start), tool_requested(id), item_requested(index); ToolbarSlot.display(key, texture, quantity, selected, title); ToastStack.show_message(message, icon_id), clear(); HudRoot contains typed clock_card, coins, toasts. Presenter.configure(main), sync(modal, title), show_message(message, icon_id). All setters return void. Components are read-only displays/request emitters.

Main's ClockHud/WeatherHud/WalletHud Labels retain text compatibility but are hidden in active composition. QuestPanel, HotbarPanel and HudButtonBar retain direct paths/public methods; existing legacy hotbar child paths are retained hidden for compatibility. Current D75 toolbar maps1/2/3/4 to hoe/shovel/watering/harvest and5–8 to four displayed inventory stacks;9 selects legacy inventory index8 and pages it into view. Inventory selection outside the window repositions it without dropping state. B/I/Tab open inventory, J journal, H help and Escape pause; K/M remain unsupported; existing Q/E modal navigation follows the implemented Bag/Character/Quest shell. No stamina/event/reward/count data is fabricated.

Layer order: world CanvasLayer 0 (existing), HUD Main CanvasLayer 1, existing interaction CanvasLayer 2; modal backdrop at Main z80, panels81 and toast82. Full-screen shell/decorative children ignore mouse input. Toolbar/shortcut buttons stop clicks; modal owner hides interactive HUD and suppresses world input. No reference PNG is loaded at runtime. New scenes use the shared Theme and script-built container children; no per-node StyleBox overrides.

## D72-C1 wheel ownership and wood-frame review (D73)

No scene/InputMap/Theme edit. HotbarPanel recognizes pressed native wheel over toolbar/with Shift, computes one existing slot request and marks handled. CameraRig yields those GUI/Shift events; map wheel only zooms. Legacy tool_next/tool_prev remain unbound action IDs. Existing modal visibility/movement locks and bag scroll/native controls remain. Current four tool slots are hoe/shovel/watering/harvest then four item-window slots. Inherited wood/stud drawing is retained; frame_wood_9slice PNG is a validated offline draft, not a new Theme texture binding.

D72-C1 cycle detail: HotbarPanel uses actual tool/selected inventory/window rather than the legacy display active_index, skips absent item slots and safely wraps into/out of the four displayed stacks. Historical C1 limitation, corrected by D75 above: the protected toolbar item highlight/caption offset marked the preceding slot although the actual selected item was correct. See PROGRESS for regression evidence and the scoped follow-up boundary.

## Phase6.5h3 capacity notification (D79)

No HUD source/scene/Theme/slot/caption/layout edit. Existing Runtime.water_changed after completed upgrade refreshes the existing actual meter to remaining/40, without free water. New game resets20/20; v10 load restores actual amount. Modal uses UiCoordinator for input/Player lock, preventing manual water/refill while open or transaction busy. See watering_upgrade.md.
