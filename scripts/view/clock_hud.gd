## ClockHud — small gray-box readout for validating GameClock behavior.
extends Label

func _ready() -> void:
	GameClock.time_changed.connect(_on_time_changed)
	_on_time_changed(GameClock.day_index, GameClock.minute)

func _on_time_changed(day_index: int, minute: int) -> void:
	text = "D%d  %s" % [day_index + 1, GameClock.format_time(minute)]
