## ClockHud — small gray-box readout for validating GameClock behavior.
extends Label

func _ready() -> void:
	GameClock.time_changed.connect(_on_time_changed)
	_on_time_changed(GameClock.day_index, GameClock.minute)

func _on_time_changed(day_index: int, minute: int) -> void:
	text = tr("UI_CLOCK_DAY_TIME") % [day_index + 1, GameClock.format_time(minute), _period_key(minute)]

func _period_key(minute: int) -> String:
	var hour: int = floori(float(posmod(minute, 1440)) / 60.0)
	if hour < 7:
		return tr("UI_TIME_DAWN")
	if hour < 12:
		return tr("UI_TIME_MORNING")
	if hour < 18:
		return tr("UI_TIME_AFTERNOON")
	if hour < 20:
		return tr("UI_TIME_DUSK")
	return tr("UI_TIME_NIGHT")
