# API INDEX — THE LIFE

Public methods and signals of every system. Agents read THIS instead of scanning code, and update it at the end of every task. Source of truth for each entry is the `## API:` header at the top of the script.

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
- Notes: placeholder view only; it owns no gameplay state.

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
- crop_id: StringName — stable crop identifier used for all saved state and registry lookups
- seed_item: StringName — item required to plant the crop
- product_item: StringName — item produced when harvested
- yield_qty: int — number of product items produced on a completed harvest
- growth_days: int — number of watered days required to mature
- water_need: int — target watering requirement for the crop lifecycle
- seasons: Array[StringName] — seasons in which the crop can grow
- Notes: this is a data Resource; scripts must not contain crop balance numbers or rules.

## FarmGridState  (scripts/domain/farm_grid_state.gd)
- func get_plot(cell: Vector2i) -> Dictionary — returns a defensive copy of one plot's current state
- func till_cell(cell: Vector2i) -> bool — tills an unworked plot; returns false if the plot is already tilled
- func plant_crop(cell: Vector2i, crop_id: StringName) -> bool — plants a crop on a tilled empty plot; returns false if invalid
- func water_cell(cell: Vector2i) -> bool — marks the plot as watered when it is planted and needs water
- func advance_day() -> void — advances each planted crop by one day if watered, then resets moisture
- func can_harvest(cell: Vector2i) -> bool — returns true once the crop has matured
- func harvest_cell(cell: Vector2i) -> Dictionary — removes the crop and returns the harvest payload
- func serialize() -> Dictionary — saves plot state for save/load
- func deserialize(data: Dictionary) -> void — restores plot state from the save payload
- signal plot_changed(cell: Vector2i) — emitted whenever a plot mutates
- Notes: does not touch UI; all view updates listen to signals from the world state.

## FarmView  (scripts/view/farm_view.gd)
- func configure(farm_state: FarmGridState) -> void — binds the placeholder view to the farm domain state
- func get_cell_view(cell: Vector2i) -> MeshInstance3D — returns the visible soil placeholder for a cell
- func get_crop_view(cell: Vector2i) -> MeshInstance3D — returns the crop placeholder for a cell
- Notes: view-only; cell positions come from GridMath and plot rules remain in FarmGridState.

## ItemData  (scripts/data/item_data.gd)
- item_id: StringName — stable data identifier
- display_name: String — localized-ready display name
- max_stack: int — maximum quantity in one slot

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

<!-- Example of a finished entry (delete when real ones exist):

## EconomyService  (scripts/domain/economy/economy_service.gd)
- func try_spend(amount: int, reason: StringName, key: StringName = &"") -> bool   — false if not enough coins
- func earn(amount: int, reason: StringName, key: StringName = &"") -> void
- signal coins_changed(new_total: int, delta: int, reason: StringName)             — via Events
- Notes: coins are int; every change is written to Ledger with a reason; only this class changes coins.
-->
