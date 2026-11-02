## LifeBanner — localized title strip, with green/red/blue Theme variants.
class_name LifeBanner
extends PanelContainer

@export var text_key: StringName = &"UI_GAME_TITLE"
@export var tone: StringName = &"green"
var caption: Label

func _ready() -> void:
	caption = Label.new()
	caption.name = "Caption"
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.theme_type_variation = &"LifeTitle"
	add_child(caption)
	set_tone(tone)
	_refresh()

func set_caption(key: StringName) -> void:
	text_key = key
	_refresh()

func set_tone(value: StringName) -> void:
	tone = value
	LifeTheme.bind(self,StringName("LifeBanner"+("Red" if tone==&"red" else ("Blue" if tone==&"blue" else "Green"))))

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		_refresh()

func _refresh() -> void:
	if caption != null:
		caption.text = tr(String(text_key))
