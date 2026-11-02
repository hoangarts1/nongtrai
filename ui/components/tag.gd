## LifeTag — localized new/main badge, with a shared Theme variant.
class_name LifeTag
extends PanelContainer

@export var text_key: StringName = &"UI_KIT_NEW"
@export var tone: StringName = &"new"
var caption: Label

func _ready() -> void:
	LifeTheme.bind(self,&"LifeTagMain" if tone == &"main" else &"LifeTagNew")
	caption = Label.new()
	caption.name = "Caption"
	add_child(caption)
	_refresh()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		_refresh()

func _refresh() -> void:
	if caption != null:
		caption.text = tr(String(text_key)).to_upper()
