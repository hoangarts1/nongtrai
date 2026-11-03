# ISO-3 modular HUD contract

Approved by owner: “Duyệt ISO-3, bắt đầu triển khai”. All new files below are under `ui/hud/`. Main keeps existing direct public node paths and view APIs; thin adapters delegate to the new views. No domain or save state moves into UI.

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
