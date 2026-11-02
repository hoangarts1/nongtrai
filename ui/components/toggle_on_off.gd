## LifeToggle — native toggle presentation; caller handles the toggled signal.
class_name LifeToggle
extends CheckButton

func _ready() -> void:
	LifeTheme.bind(self,&"LifeToggle")
	toggled.connect(_on_toggled)
	_refresh()

func _on_toggled(_pressed: bool) -> void:
	_refresh()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		_refresh()

func _refresh() -> void:
	text = tr("UI_KIT_ON" if button_pressed else "UI_KIT_OFF")
