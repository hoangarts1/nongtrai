## WeatherProfile — probabilities and visual effects for each weather id.
extends Resource
class_name WeatherProfile

@export var entries: Array[Dictionary] = []

func get_entry(weather_id: StringName) -> Dictionary:
	for entry: Dictionary in entries:
		if StringName(entry.get("id", "")) == weather_id:
			return entry
	return {}
