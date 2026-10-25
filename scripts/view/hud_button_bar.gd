## HudButtonBar — shared bottom-corner button bar for player-facing HUD actions.
## API:
##   func register_button(button_id: StringName, label: String, callback: Callable, enabled_check: Callable = Callable()) -> Button
##   func set_button_active(button_id: StringName, active: bool) -> void
##   func get_button(button_id: StringName) -> Button
class_name HudButtonBar
extends PanelContainer

var _button_row: HBoxContainer
var _buttons: Dictionary = {}
var _enabled_checks: Dictionary = {}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()

func _process(_delta: float) -> void:
	for button_id: StringName in _buttons:
		var enabled_check: Callable = _enabled_checks.get(button_id, Callable())
		if enabled_check.is_valid():
			(_buttons[button_id] as Button).disabled = not bool(enabled_check.call())

func register_button(
	button_id: StringName,
	label: String,
	callback: Callable,
	enabled_check: Callable = Callable()
) -> Button:
	if _buttons.has(button_id):
		push_error("HUD button already registered: %s" % button_id)
		return _buttons[button_id] as Button
	var button: Button = Button.new()
	button.name = String(button_id)
	button.text = label
	button.tooltip_text = tr("UI_INV_BUTTON_TOOLTIP") if button_id == &"inventory" else label
	button.custom_minimum_size = Vector2(86, 56)
	button.toggle_mode = true
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.pressed.connect(callback)
	_button_row.add_child(button)
	_buttons[button_id] = button
	_enabled_checks[button_id] = enabled_check
	return button

func set_button_active(button_id: StringName, active: bool) -> void:
	if not _buttons.has(button_id):
		return
	var button: Button = _buttons[button_id] as Button
	button.button_pressed = active

func get_button(button_id: StringName) -> Button:
	return _buttons.get(button_id) as Button

func _build_ui() -> void:
	var margin: MarginContainer = MarginContainer.new()
	for side: StringName in [&"margin_left", &"margin_top", &"margin_right", &"margin_bottom"]:
		margin.add_theme_constant_override(side, 8)
	add_child(margin)
	_button_row = HBoxContainer.new()
	_button_row.add_theme_constant_override("separation", 6)
	margin.add_child(_button_row)
