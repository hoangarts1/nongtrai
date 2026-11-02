## LifeButtonBase — localized native Button; gallery previews change theme variations only.
class_name LifeButtonBase
extends Button

@export var text_key: StringName = &"UI_CONTINUE"
var _base_variation: StringName

func _ready() -> void:
	_base_variation = theme_type_variation
	LifeTheme.bind(self)
	_refresh()

func set_caption(key: StringName) -> void:
	text_key = key
	_refresh()

func set_preview_state(state: StringName) -> void:
	disabled = state == &"disabled"
	theme_type_variation = StringName("%sPreview%s" % [_base_variation,String(state).capitalize()]) if state in [&"hover",&"pressed"] else _base_variation

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		_refresh()

func _refresh() -> void:
	text = tr(String(text_key))
