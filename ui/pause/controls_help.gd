## LifeControlsHelp — read-only binding labels derived from current InputMap.
class_name LifeControlsHelp
extends VBoxContainer

const ACTIONS: Array[StringName] = [&"move_up",&"move_down",&"move_left",&"move_right",&"interact",&"use_tool",&"open_inventory",&"open_journal",&"open_help",&"pause"]
const KEYS: Array[StringName] = [&"PAUSE_MOVE_UP",&"PAUSE_MOVE_DOWN",&"PAUSE_MOVE_LEFT",&"PAUSE_MOVE_RIGHT",&"PAUSE_INTERACT",&"PAUSE_USE_TOOL",&"UI_INVENTORY_TITLE",&"PAUSE_JOURNAL",&"PAUSE_HELP",&"UI_PAUSE_TITLE"]
var _labels: Array[Label] = []
var _bindings: Array[Label] = []

func _ready() -> void:
	for index: int in range(ACTIONS.size()):
		var row: HBoxContainer = HBoxContainer.new()
		add_child(row)
		_labels.append(LifePauseParts.label(row,KEYS[index]))
		var value: Label = LifeHudParts.label(row,&"LifeText16")
		value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		_bindings.append(value)
	refresh()

func refresh() -> void:
	for index: int in range(ACTIONS.size()):
		_labels[index].text = tr(String(KEYS[index]))
		var values: PackedStringArray = []
		for event: InputEvent in InputMap.action_get_events(ACTIONS[index]):
			if event is InputEventKey:
				var key: InputEventKey = event as InputEventKey
				var code: int = key.physical_keycode if key.physical_keycode != 0 else key.keycode
				values.append(OS.get_keycode_string(code))
			elif event is InputEventMouseButton:
				values.append(tr("UI_BIND_MOUSE_LEFT") if (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT else event.as_text())
		_bindings[index].text = " / ".join(values)

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and not _labels.is_empty():
		refresh()
