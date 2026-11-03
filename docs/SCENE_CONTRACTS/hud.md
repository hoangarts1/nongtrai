# ISO-3 modular HUD contract

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

Main's ClockHud/WeatherHud/WalletHud Labels retain text compatibility but are hidden in active composition. QuestPanel, HotbarPanel and HudButtonBar retain direct paths/public methods; existing legacy hotbar child paths are retained hidden for compatibility. New toolbar maps 1/2/3 to hoe/water/harvest, 4–8 to a five-stack inventory window; 9 selects legacy inventory index 8. Inventory selection outside the window repositions it without dropping state. B/I/Tab open inventory, J journal, H help and Escape pause; K/M and Q/E modal tabs remain unsupported. No stamina/event/reward/count data is fabricated.

Layer order: world CanvasLayer 0 (existing), HUD Main CanvasLayer 1, existing interaction CanvasLayer 2; modal backdrop at Main z80, panels81 and toast82. Full-screen shell/decorative children ignore mouse input. Toolbar/shortcut buttons stop clicks; modal owner hides interactive HUD and suppresses world input. No reference PNG is loaded at runtime. New scenes use the shared Theme and script-built container children; no per-node StyleBox overrides.
