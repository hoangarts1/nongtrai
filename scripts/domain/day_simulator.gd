## DaySimulator — advances farm state once at the morning boundary.
## API:
##   func simulate_day(farm_state: FarmGridState) -> void
class_name DaySimulator
extends RefCounted

func simulate_day(farm_state: FarmGridState) -> void:
	if farm_state == null:
		return
	farm_state.advance_day()
