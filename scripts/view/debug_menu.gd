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
	register_action("Thêm 10 hạt củ cải", func() -> void: _inventory.add_item(&"turnip_seed", 10))
	register_action("Xóa kho", func() -> void: _inventory.clear())

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
	title.text = "DEBUG MENU  (Ctrl+M)"
	title.add_theme_font_size_override("font_size", 22)
	column.add_child(title)
	_status_label = Label.new()
	column.add_child(_status_label)
	_action_buttons = VBoxContainer.new()
	_action_buttons.add_theme_constant_override("separation", 4)
	column.add_child(_action_buttons)
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
	register_action("06:00", func() -> void: _set_time(6, 0))
	register_action("12:00", func() -> void: _set_time(12, 0))
	register_action("20:00", func() -> void: _set_time(20, 0))
	register_action("23:30", func() -> void: _set_time(23, 30))
	register_action("+1 giờ", func() -> void: GameClock.advance_minutes(60))
	register_action("Sang ngày mới", _start_next_day)
	register_action("Tạm dừng / tiếp tục", _toggle_pause)
	register_action("Tốc độ x1", func() -> void: GameClock.set_speed(1.0))
	register_action("Tốc độ x5", func() -> void: GameClock.set_speed(5.0))
	register_action("Tốc độ x20", func() -> void: GameClock.set_speed(20.0))
	register_action("Dịch chuyển gần nhà", _move_near_house)

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
		_player.global_position = Vector3(5.5, 0.0, 2.5)

func _update_status() -> void:
	if _player == null:
		return
	if GameClock.is_sleeping():
		_player.movement_enabled = false
	_status_label.text = "Ngày %d  %s\nPlayer: (%.1f, %.1f, %.1f)\nFPS: %d  Tốc độ: x%.0f  %s" % [
		GameClock.day_index + 1,
		GameClock.format_time(GameClock.minute),
		_player.global_position.x,
		_player.global_position.y,
		_player.global_position.z,
		Engine.get_frames_per_second(),
		GameClock.time_speed,
		"PAUSED" if GameClock.paused else "RUNNING"
	]
