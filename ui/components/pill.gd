## LifePill — localized formatted display text.
class_name LifePill
extends PanelContainer

@export var text_key: StringName = &"UI_KIT_DAY"
var display_value: int = 3
var caption: Label

func _ready() -> void:
	LifeTheme.bind(self,&"LifePill")
	caption = Label.new()
	caption.name = "Caption"
	add_child(caption)
	_refresh()

func set_value(value: int) -> void:
	display_value = value
	_refresh()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		_refresh()

func _refresh() -> void:
	if caption != null:
		caption.text = tr(String(text_key)) % display_value
