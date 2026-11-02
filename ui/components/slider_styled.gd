## LifeSlider — shared-theme native slider; no settings/gameplay ownership.
class_name LifeSlider
extends HSlider

func _ready() -> void:
	LifeTheme.bind(self)
