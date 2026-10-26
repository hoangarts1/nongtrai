## CropInspector — click-selected crop details and conditional game-clock countdown.
## API:
##   func configure(farm: FarmGridState) -> void
##   func show_cell(cell: Vector2i) -> void
##   func get_remaining_minutes() -> int
##   signal action_requested(cell: Vector2i, action_id: StringName)
class_name CropInspector
extends PanelContainer

signal action_requested(cell: Vector2i, action_id: StringName)

var title_label: Label
var countdown_label: Label
var estimate_label: Label
var water_label: Label
var note_label: Label
var action_button: Button
var _farm: FarmGridState
var _cell: Vector2i
var _action_id: StringName = &""

func _ready() -> void:
	name = "CropInspector"
	visible = false
	_build_ui()

func configure(farm: FarmGridState) -> void:
	_farm = farm
	_farm.plot_changed.connect(_on_plot_changed)
	GameClock.time_changed.connect(_on_time_changed)

func show_cell(cell: Vector2i) -> void:
	_cell = cell
	_refresh()
	if not StringName(_farm.get_plot(cell).get("crop_id", &"")).is_empty():
		show()

func get_remaining_minutes() -> int:
	if bool(_farm.get_plot(_cell).get("withered", false)):
		return 0
	var remaining_days: int = _farm.get_growth_remaining(_cell)
	if remaining_days <= 0:
		return 0
	var target: int = (GameClock.day_index + remaining_days) * GameClock.MINUTES_PER_DAY + GameClock.MORNING_MINUTE
	var current: int = GameClock.day_index * GameClock.MINUTES_PER_DAY + GameClock.minute
	return maxi(0, target - current)

func _refresh() -> void:
	var plot: Dictionary = _farm.get_plot(_cell)
	var crop_id: StringName = plot.get("crop_id", &"")
	if crop_id.is_empty():
		hide()
		return
	var crop: Resource = DataRegistry.get_crop(crop_id)
	if crop == null:
		hide()
		return
	title_label.text = tr(String(crop.get("display_name_key")))
	var withered: bool = bool(plot.get("withered", false))
	var ready: bool = not withered and _farm.can_harvest(_cell)
	var remaining_days: int = _farm.get_growth_remaining(_cell)
	var watered: bool = bool(plot.get("watered", false))
	water_label.text = tr("UI_CROP_WATERED" if watered else "CROP_STATUS_NEEDS_WATER")
	note_label.text = tr("UI_CROP_ESTIMATE_NOTE")
	_action_id = &"harvest" if ready else &"water"
	action_button.text = tr("UI_TOOL_HARVEST" if ready else "UI_TOOL_WATER")
	action_button.disabled = withered or (not ready and watered)
	if withered:
		countdown_label.text = tr("CROP_STATUS_WITHERED")
		estimate_label.text = tr("UI_CROP_WITHERED_NOTE")
		note_label.text = ""
	elif ready:
		countdown_label.text = tr("CROP_STATUS_READY")
		estimate_label.text = tr("UI_CROP_READY_NOTE")
		note_label.text = ""
	else:
		var minutes: int = get_remaining_minutes()
		var days: int = minutes / GameClock.MINUTES_PER_DAY
		var hours: int = (minutes % GameClock.MINUTES_PER_DAY) / 60
		countdown_label.text = tr("UI_CROP_COUNTDOWN") % [days, hours, minutes % 60]
		estimate_label.text = tr("UI_CROP_ESTIMATE_AT") % [GameClock.day_index + remaining_days + 1, GameClock.format_time(GameClock.MORNING_MINUTE)]

func _on_plot_changed(cell: Vector2i) -> void:
	if visible and cell == _cell:
		_refresh()

func _on_time_changed(_day_index: int, _minute: int) -> void:
	if visible:
		_refresh()

func _build_ui() -> void:
	var margin: MarginContainer = MarginContainer.new()
	for side: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 12)
	add_child(margin)
	var column: VBoxContainer = VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	margin.add_child(column)
	var heading: HBoxContainer = HBoxContainer.new()
	column.add_child(heading)
	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 20)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	heading.add_child(title_label)
	var close: Button = Button.new()
	close.name = "CloseCropInspector"
	close.text = "×"
	close.tooltip_text = tr("UI_CLOSE")
	close.pressed.connect(hide)
	heading.add_child(close)
	countdown_label = _label(column, "", 24)
	estimate_label = _label(column, "", 16)
	water_label = _label(column, "", 16)
	note_label = _label(column, "", 16)
	note_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	action_button = Button.new()
	action_button.name = "CropAction"
	action_button.custom_minimum_size.y = 36
	action_button.pressed.connect(_request_action)
	column.add_child(action_button)

func _request_action() -> void:
	action_requested.emit(_cell, _action_id)
	if visible:
		_refresh()

func _label(parent: Node, text: String, font_size: int) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	parent.add_child(label)
	return label
