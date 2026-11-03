# API INDEX — THE LIFE

## ISO-5 inventory APIs (2026-11-03, D40)

Current save version is **6**. Historical milestone entries below describe their original deliveries.

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
- func set_target(target_node: Player) -> void — assigns the node followed by the rig
- Notes: drives the player's child Camera2D with data-owned smoothing, center bounds and documented zoom actions.

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
- func get_cell_view(cell: Vector2i) -> Polygon2D — returns the placeholder soil view
- func get_crop_view(cell: Vector2i) -> Sprite2D — returns the crop root view
- func get_crop_label(cell: Vector2i) -> Label — retains the legacy billboard growth-status label for compatibility
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

