## LifeDialogueChoices — GUI requests only, with stable Close and stale-view guards.
class_name LifeDialogueChoices
extends VBoxContainer

signal requested(id: StringName)
signal closed()
var close_button: Button
var revision: int = 0
var _buttons: Array[Button] = []
var _enabled: Dictionary = {}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_constant_override("separation", 12)
	close_button = LifePauseParts.button(self, &"UI_NPC_CLOSE")
	close_button.custom_minimum_size.y = 48
	close_button.pressed.connect(func() -> void: closed.emit())

func display(actions: Array[Dictionary]) -> void:
	revision += 1
	_enabled.clear()
	for button: Button in _buttons:
		remove_child(button)
		button.queue_free()
	_buttons.clear()
	for action: Dictionary in actions:
		var id: StringName = StringName(action.get("id", &""))
		if id.is_empty() or _enabled.has(id):
			continue
		_enabled[id] = bool(action.get("enabled", true))
		var button: Button = LifePauseParts.button(self, &"", &"LifePrimary" if _buttons.is_empty() else &"LifeSecondary")
		button.name = String(id)
		button.text = String(action.get("text", ""))
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.custom_minimum_size.y = 60
		button.disabled = not _enabled[id]
		button.pressed.connect(_request.bind(id, revision))
		move_child(button, _buttons.size())
		_buttons.append(button)
	close_button.text = tr("UI_NPC_CLOSE")

func _request(id: StringName, token: int) -> void:
	if token == revision and is_visible_in_tree() and bool(_enabled.get(id, false)):
		requested.emit(id)
