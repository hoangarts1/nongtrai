## HudButtonBar — compatible registration adapter for supported round HUD buttons.
## API:
##   func register_button(button_id: StringName, label: String, callback: Callable, enabled_check: Callable = Callable()) -> Button
##   func set_button_active(button_id: StringName, active: bool) -> void
##   func get_button(button_id: StringName) -> Button
class_name HudButtonBar
extends PanelContainer

var _buttons: Dictionary = {}
var _enabled_checks: Dictionary = {}
var bar: LifeHudShortcutBar

func _ready() -> void:
	LifeTheme.bind(self,&"LifeHudClearPanel")
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar = preload("res://ui/hud/shortcut_bar.tscn").instantiate() as LifeHudShortcutBar
	add_child(bar)

func _process(_delta: float) -> void:
	for button_id: StringName in _buttons:
		var enabled_check: Callable = _enabled_checks.get(button_id,Callable())
		if enabled_check.is_valid():
			(_buttons[button_id] as Button).disabled = not bool(enabled_check.call())

func register_button(button_id: StringName, label: String, callback: Callable, enabled_check: Callable = Callable()) -> Button:
	if _buttons.has(button_id):
		push_error("HUD button already registered: %s" % button_id)
		return _buttons[button_id] as Button
	var action: StringName = &"pause" if button_id==&"pause" else StringName("open_"+String(button_id))
	var button: Button = bar.create_button(button_id,label,action)
	button.toggle_mode = true
	button.pressed.connect(callback)
	_buttons[button_id] = button
	_enabled_checks[button_id] = enabled_check
	if button_id==&"journal":
		bar.move_child(button.get_parent(),1)
	return button

func set_button_active(button_id: StringName, active: bool) -> void:
	if _buttons.has(button_id):
		(_buttons[button_id] as Button).button_pressed = active

func get_button(button_id: StringName) -> Button:
	return _buttons.get(button_id) as Button
