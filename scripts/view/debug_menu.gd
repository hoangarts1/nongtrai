## DebugMenu — debug-only developer controls built from registered actions.
## API:
##   func register_action(label: String, callback: Callable) -> void
##   func configure(player_node: Player) -> void
class_name DebugMenu
extends PanelContainer

var _player: Player
var _actions: Array[Dictionary] = []
var _action_buttons: VBoxContainer
var _status_label: Label
var _inventory
var _farm_state: FarmGridState
var _farm_view: Node
var _save_callback: Callable
var _load_callback: Callable
var _weather: Object
var _wallet: Object

func _ready() -> void:
	if not OS.is_debug_build():
		queue_free()
		return
	visible = false
	_build_base_ui()
	_register_default_actions()

func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build() or not event.is_action_pressed("toggle_debug_menu"):
		return
	visible = not visible
	if _player != null:
		_player.movement_enabled = not visible and not GameClock.is_sleeping()
	get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
	if not visible:
		return
	_update_status()

func configure(player_node: Player) -> void:
	_player = player_node
	if visible:
		_player.movement_enabled = false

func configure_inventory(inventory) -> void:
	_inventory = inventory
	register_action(tr("UI_DEBUG_ADD_SEEDS"), func() -> void: _inventory.add_item(&"turnip_seed", 10))
	register_action(tr("UI_DEBUG_ADD_ALL_SEEDS"), _add_all_seeds)
	register_action(tr("UI_DEBUG_CLEAR_INVENTORY"), func() -> void: _inventory.clear())

func configure_wallet(wallet) -> void:
	_wallet = wallet
	register_action(tr("UI_DEBUG_ADD_COINS"), func() -> void: _wallet.call("add_coins", 500, &"debug_grant"))

func configure_farm(farm_state: FarmGridState, farm_view: Node) -> void:
	_farm_state = farm_state
	_farm_view = farm_view
	register_action(tr("UI_DEBUG_HOE_ALL"), _hoe_all)
	register_action(tr("UI_DEBUG_WATER_ALL"), _water_all)
	register_action(tr("UI_DEBUG_GROW_DAY"), _grow_one_day)
	register_action(tr("UI_DEBUG_RESET_FARM"), _reset_farm)

func configure_save_load(save_callback: Callable, load_callback: Callable) -> void:
	_save_callback = save_callback
	_load_callback = load_callback
	register_action(tr("UI_DEBUG_SAVE"), _save_callback)
	register_action(tr("UI_DEBUG_LOAD"), _load_callback)

func configure_weather(weather_state: Object) -> void:
	_weather = weather_state
	register_action(tr("UI_DEBUG_WEATHER_SUNNY"), func() -> void: _weather.call("force_weather", &"sunny"))
	register_action(tr("UI_DEBUG_WEATHER_RAIN"), func() -> void: _weather.call("force_weather", &"rain"))
	register_action(tr("UI_DEBUG_WEATHER_STORM"), func() -> void: _weather.call("force_weather", &"storm"))

func register_action(label: String, callback: Callable) -> void:
	_actions.append({"label": label, "callback": callback})
	if is_node_ready():
		_add_action_button(label, callback)

func _build_base_ui() -> void:
	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 14)
	add_child(margin)
	var column: VBoxContainer = VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	margin.add_child(column)
	var title: Label = Label.new()
	title.text = tr("UI_DEBUG_TITLE")
	title.add_theme_font_size_override("font_size", 18)
	var heading: HBoxContainer = HBoxContainer.new()
	column.add_child(heading)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(title)
	var close_button: Button = Button.new()
	close_button.text = tr("UI_CLOSE")
	close_button.pressed.connect(func() -> void: hide())
	heading.add_child(close_button)
	_status_label = Label.new()
	column.add_child(_status_label)
	var action_scroll: ScrollContainer = ScrollContainer.new()
	action_scroll.name = "ActionScroll"
	action_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	action_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(action_scroll)
	_action_buttons = VBoxContainer.new()
	_action_buttons.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_action_buttons.add_theme_constant_override("separation", 4)
	action_scroll.add_child(_action_buttons)
	for action: Dictionary in _actions:
		_add_action_button(action["label"] as String, action["callback"] as Callable)

func _add_action_button(label: String, callback: Callable) -> void:
	if _action_buttons == null:
		return
	var button: Button = Button.new()
	button.text = label
	button.pressed.connect(callback)
	_action_buttons.add_child(button)

func _register_default_actions() -> void:
	register_action(tr("UI_DEBUG_SET_0600"), func() -> void: _set_time(6, 0))
	register_action(tr("UI_DEBUG_SET_1200"), func() -> void: _set_time(12, 0))
	register_action(tr("UI_DEBUG_SET_2000"), func() -> void: _set_time(20, 0))
	register_action(tr("UI_DEBUG_SET_2330"), func() -> void: _set_time(23, 30))
	register_action(tr("UI_DEBUG_ADD_HOUR"), func() -> void: GameClock.advance_minutes(60))
	register_action(tr("UI_DEBUG_NEXT_DAY"), _start_next_day)
	register_action(tr("UI_DEBUG_PAUSE"), _toggle_pause)
	register_action(tr("UI_DEBUG_SPEED_X1"), func() -> void: GameClock.set_speed(1.0))
	register_action(tr("UI_DEBUG_SPEED_X5"), func() -> void: GameClock.set_speed(5.0))
	register_action(tr("UI_DEBUG_SPEED_X20"), func() -> void: GameClock.set_speed(20.0))
	register_action(tr("UI_DEBUG_MOVE_NEAR_HOME"), _move_near_house)

func _set_time(hour: int, minute_in_hour: int) -> void:
	GameClock.set_time(hour, minute_in_hour)

func _toggle_pause() -> void:
	if GameClock.is_sleeping():
		return
	GameClock.paused = not GameClock.paused

func _start_next_day() -> void:
	if GameClock.is_sleeping():
		return
	GameClock.sleep_to_morning()

func _move_near_house() -> void:
	if _player != null:
		_player.global_position = Vector3(11.0, 0.0, 8.0)

func _hoe_all() -> void:
	if _farm_state == null:
		return
	for z: int in range(6):
		for x: int in range(6):
			_farm_state.till_cell(Vector2i(x, z))

func _water_all() -> void:
	if _farm_state == null:
		return
	for z: int in range(6):
		for x: int in range(6):
			_farm_state.water_cell(Vector2i(x, z))

func _grow_one_day() -> void:
	if _farm_state == null:
		return
	var simulator: Object = preload("res://scripts/domain/day_simulator.gd").new()
	simulator.call("simulate_day", _farm_state)

func _reset_farm() -> void:
	if _farm_state != null:
		_farm_state.reset()

func _add_all_seeds() -> void:
	if _inventory == null:
		return
	var seed_items: Array[Resource] = DataRegistry.get_seed_items()
	for seed_data: Resource in seed_items:
		if seed_data != null:
			_inventory.add_item(seed_data.get("item_id"), 5)

func _update_status() -> void:
	if _player == null:
		return
	if GameClock.is_sleeping():
		_player.movement_enabled = false
	_status_label.text = "%s %d  %s\n%s: (%.1f, %.1f, %.1f)\n%s: %d  %s: x%.0f  %s" % [
		tr("UI_DEBUG_TIME_DAY"),
		GameClock.day_index + 1,
		GameClock.format_time(GameClock.minute),
		tr("UI_DEBUG_TIME_PLAYER"),
		_player.global_position.x,
		_player.global_position.y,
		_player.global_position.z,
		tr("UI_DEBUG_TIME_FPS"),
		Engine.get_frames_per_second(),
		tr("UI_DEBUG_TIME_SPEED"),
		GameClock.time_speed,
		"PAUSED" if GameClock.paused else "RUNNING"
	]
