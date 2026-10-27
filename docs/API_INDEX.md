# API INDEX — THE LIFE

Public methods and signals of every system. Agents read THIS instead of scanning code, and update it at the end of every task. Source of truth for each entry is the `## API:` header at the top of the script.

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
- Notes: the logical grid is Vector2i on the XZ plane; one cell is 1 metre.

## GrayBoxWorld  (scripts/view/gray_box_world.gd)
- func pick_cell(screen_position: Vector2) -> Variant — projects a screen point onto the ground plane and returns a Vector2i cell or null
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
- func serialize() -> Dictionary — saves seed, current weather and forecast
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
- func set_target(target_node: Node3D) -> void — assigns the node followed by the rig
- Notes: follows with exponential smoothing and clamps the camera center to the gray-box map bounds.

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
- func advance_day() -> void — advances each planted crop by one day if watered, then resets moisture
- func can_harvest(cell: Vector2i) -> bool — returns true once the crop has matured
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
- func get_cell_view(cell: Vector2i) -> MeshInstance3D — returns the placeholder soil view
- func get_crop_view(cell: Vector2i) -> MeshInstance3D — returns the crop root view
- func get_crop_label(cell: Vector2i) -> Label3D — retains the legacy billboard growth-status label for compatibility
- Notes: label text still refreshes from `FarmGridState.plot_changed`, but the label stays hidden because CropInspector provides the readable status/timer surface.

## FeedbackPopup  (scripts/view/feedback_popup.gd)
- func show_message(message: String) -> void — displays a short animated result message

## SaveService  (scripts/core/save_service.gd)
- func save_game(payload: Dictionary, slot: int = 1) -> bool — writes the v4 envelope with clock, player, inventory, farm, onboarding quests, profile, weather, wallet and social, atomically with three backups
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
- func get_cell_view(cell: Vector2i) -> MeshInstance3D — returns the visible soil placeholder for a cell
- func get_crop_view(cell: Vector2i) -> MeshInstance3D — returns the crop placeholder for a cell
- func pick_crop(screen_position: Vector2, camera: Camera3D) -> Variant — selects the visible bounds of a crop mesh or returns null
- Notes: view-only; cell positions come from GridMath and plot rules remain in FarmGridState. Crop root bounds remain selectable while children render a crop-family-specific sprout, growing or mature form; labels are hidden in favor of CropInspector.

## CropPresentation  (scripts/view/crop_presentation.gd)
- static func render(crop: MeshInstance3D, crop_id: StringName, growth_ratio: float, crop_color: Color, withered: bool, watered: bool, cell: Vector2i) -> void — rebuilds a view-only crop root and its family-specific child meshes from existing plot data
- static func clear(crop: MeshInstance3D) -> void — removes only presentation meshes from an empty crop root
- Notes: supports roots, tomato, corn, wheat, pumpkin, cabbage and pea silhouettes plus a wilted state. It owns no crop state, timers, inventory changes or save data.

## WorldArtFactory  (scripts/view/world_art_factory.gd)
- static func add_decorative_cottage(parent: Node3D, cottage_name: String, origin: Vector3, size: Vector3, wall_color: Color, roof_color: Color) -> MeshInstance3D — adds a non-interactive cottage visual
- static func add_ground_dressing(parent: Node3D) -> Node3D — adds non-colliding grass tufts and home-to-bin path stones
- static func build_cottage(anchor: MeshInstance3D, size: Vector3, wall_color: Color, roof_color: Color) -> void — decorates an existing home anchor while retaining its world transform
- static func build_market(anchor: MeshInstance3D) -> void — decorates the existing SeedShop anchor as a seed market stall
- static func decorate_shipping_bin(anchor: MeshInstance3D) -> void — decorates the existing shipping-bin anchor
- static func add_rock_cluster(parent: Node3D, cluster_name: String, origin: Vector3, stone_color: Color) -> Node3D — adds a non-colliding, view-only rock/moss group outside playable farm cells
- Notes: no marker, collision, interaction or gameplay ownership changes. All meshes and materials are constructed locally at runtime.
- Notes: the gray-box scene places the 6×6 grid inside the 6 m × 6 m `FarmPlot`; target green means reachable and red means outside tool reach.

## SoilPresentation  (scripts/view/soil_presentation.gd)
- static func render(soil: MeshInstance3D, tilled: bool, watered: bool, cell: Vector2i) -> void — adds only view-level furrows and a transparent moisture sheen; FarmGridState remains the source of truth

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
- func close() -> void — resumes the game clock and unlocks player movement
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
- static func is_player_near_interactable(player_position: Vector3, interactable_position: Vector3, reach: float) -> bool — checks flat XZ distance against interaction reach
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
- `NpcActor.configure(social: NpcSocialState, npc: NpcData)`, `reset_position()`: interpolate the domain route via GridMath, hide on arrival home, display localized name/prompt.
- `DataValidator.validate_npc_world(data, items, quests, locale_paths) -> PackedStringArray`: unique ids, references, schedule bounds, reachable destinations, friendship limits, merchant prices and translation coverage. tools/validate_data.gd includes this gate.

## UiCoordinator / UiLayout (scripts/view/ui_coordinator.gd, ui_layout.gd)
- `UiCoordinator.configure(main: Node) -> void`: registers the nine existing modal surfaces, applies the runtime theme/layout, and creates a view-only backdrop; no autoload or scene edits.
- `close_active() -> void`, `get_active_panel() -> Control`: closes through each panel's existing API and coordinates visibility, clock/player locking, prompts and secondary HUD. Start menu cannot be bypassed by gameplay shortcuts.
- `UiLayout.apply(main: Node) -> void`, `reflow(main: Node) -> void`: duplicated runtime Theme (18 px body, 24 px headings), large buttons, responsive rectangles, and deferred reflow after minimum-size changes.
- `HotbarPanel.refresh_readability() -> void`: rebuilds backing item selectors, but hides the item grid/caption during gameplay; only the four compact tool buttons are visible. `select_slot(slot_index: int) -> void` keeps numeric selection/API compatibility. `InventoryPanel` shows all items in a scrollable list with explicit Select buttons and a fixed close header.
- Modal shortcut contract: I/H/J/Ctrl+M replace the active modal; Esc closes it; E still closes seed shop/shipping bin. Help appears after New Game, separately from the start menu. Regular modals pause the game clock; debug menu preserves its clock controls.
- Backdrop is the first Main child for mouse hit order; render z_index alone is insufficient. Mouse events pass to GUI before key filters; mouse regression tests use press/release pairs in a separate SubViewport.

## Chibi presentation and entry flow (scripts/view/)
- `UiIcons.get_icon(icon_id: StringName) -> Texture2D`, `for_item(item_id: StringName) -> Texture2D`, `decorate(button: Button, icon_id: StringName, icon_only: bool = false) -> void`: caches 22 declared original SVG assets and maps current items to crop icons; labels/tooltips remain localized.
- `TitleBackdrop` (TextureRect): non-interactive generated illustration plus decorative motes, visible only while StartMenu is visible. Main constructs it in code.
- `StartMenu.apply_chibi_style() -> void`, `refresh_continue() -> void`: title styling and consistent slot-0/slot-1 Continue availability. Existing configure callback API remains compatible.
- `ChibiAvatar.configure(outfit: Color, with_hat: bool = true) -> void`: local procedural mesh and view-only idle/walk motion; does not change player/NPC state or collisions.
- `WorldPresentation.configure(main: Node) -> void`: decorates Player/House/SeedShop/ShippingBin anchors, decorative cottages, paths, homes, trees and exterior rock clusters; applies warm Forward+ filmic/soft-glow/fog lighting while preserving collision and gameplay authority.
- `HotbarPanel._unhandled_input` handles existing hotbar_1 through hotbar_9 only while visible. Full item selection/caption and 12-slot inventory state are preserved.

## CropInspector / compact HUD (scripts/view/crop_inspector.gd)
- `configure(farm: FarmGridState) -> void`, `show_cell(cell: Vector2i) -> void`: binds existing farm state and shows one click-selected crop without pausing time or mutating state. Local `action_requested(cell: Vector2i, action_id: StringName)` delegates Water/Harvest to the existing controller.
- `get_remaining_minutes() -> int`: game-minute estimate to the remaining growth-day morning boundary, assuming daily watering and a suitable season. Derived from FarmGridState.get_growth_remaining and GameClock constants; no new timer, growth path or saved state. Ready/withered plants show explicit status instead.
- `FarmView.pick_crop(screen_position: Vector2, camera: Camera3D) -> Variant`: projects visible crop mesh bounds to select the actual crop (or null), including a small sprout click margin. Ground picking remains the fallback. `get_crop_label` retains its API/text, but tiny repeated world labels are hidden.
- `ToolActionController.configure_crop_inspector(inspector)`, `perform_crop_action(cell, action_id)`: click inspection precedes mouse tool use; explicit panel actions validate player input/reach and reuse watering/harvest/inventory logic. Inspection itself never consumes items or harvests.
- `InventoryPanel.slot_selected(slot_index: int)`: emitted on a row's localized Select button; Main forwards it to HotbarPanel and inventory closes. Selection preserves all item quantities.

## ShippingBinPanel  (scripts/view/shipping_bin_panel.gd)
- func configure(inventory, wallet, player: Player, feedback: Node = null) -> void — binds inventory and wallet
- func open() -> void / func close() -> void / func toggle() -> void — modal visibility controls; locks player movement
- func is_open() -> bool — query panel open state
- signal item_sold(item_id: StringName, quantity: int, total_price: int) — emitted on successful sale

## SeedShopPanel  (scripts/view/seed_shop_panel.gd)
- func configure(inventory, wallet, player: Player, feedback: Node = null) -> void — binds inventory, wallet and player
- func open() -> void / func close() -> void / func toggle() -> void — modal visibility controls with seasonal seed filtering
- func is_open() -> bool — query panel open state
- func try_buy_item(item_id: StringName, quantity: int) -> bool — performs atomic purchase checking funds and inventory capacity
- signal item_purchased(item_id: StringName, quantity: int, total_price: int) — emitted on successful purchase

