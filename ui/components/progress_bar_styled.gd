## LifeProgressBar — styled read-only progress; values are supplied by its caller.
class_name LifeProgressBar
extends ProgressBar

@export var tone: StringName = &"green"

func _ready() -> void:
	show_percentage = false
	set_tone(tone)

func set_tone(value: StringName) -> void:
	tone = value
	LifeTheme.bind(self,StringName("LifeProgress"+("Blue" if tone==&"blue" else ("Gold" if tone==&"gold" else "Green"))))

func set_displayed_value(current: int, maximum: int) -> void:
	max_value = maxi(1,maximum)
	value = clampi(current,0,maximum)
