## LifeKeyHint — displays a binding from existing InputMap, never registers an action.
class_name LifeKeyHint
extends PanelContainer

@export var action: StringName = &"interact"
var caption: Label

func _ready() -> void:
	LifeTheme.bind(self,&"LifeKeyHint")
	caption = Label.new()
	caption.name = "Caption"
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(caption)
	set_action(action)

func set_action(value: StringName) -> void:
	action = value
	if caption != null:
		caption.text = action_text(action)

static func action_text(value: StringName) -> String:
	if not InputMap.has_action(value):
		return ""
	for event: InputEvent in InputMap.action_get_events(value):
		if event is InputEventKey:
			var key: InputEventKey = event as InputEventKey
			var code: int = key.physical_keycode if key.physical_keycode != 0 else key.keycode
			return OS.get_keycode_string(code)
	return ""
